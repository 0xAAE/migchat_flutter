import 'dart:async';

import 'package:flutter/material.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';

import 'chat_model.dart';
import 'chat_widget.dart';
import 'post_model.dart';
import 'post_composer_widget.dart';
import 'post_widget_incoming.dart';
import 'post_widget_outgoing.dart';
import 'chat_service.dart';
import 'user_model.dart';
import 'layout/adaptive.dart';

typedef String ResolveUserName(int userId);
typedef String ResolveChatName(int chatId);

/// Host screen widget - main window
class ChatScreen extends StatefulWidget {
  ChatScreen({required this.name, required this.shortName})
      : super(key: new ObjectKey("Main window"));

  final String name;
  final String shortName;

  @override
  State createState() => ChatScreenState(
      registeredUser: UserModel(
          id: 0, name: name, shortName: shortName, created: DateTime.now()));
}

const int NOT_SELECTED = -1;
const int NOT_FOUND = -1;

class Selection {
  int _selectedChat = NOT_SELECTED;

  int get chat => _selectedChat;

  set chat(int i) => _selectedChat = i;

  bool get chatSelected => _selectedChat != NOT_SELECTED;
}

/// State for ChatScreen widget
class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  /// Chat client service
  late ChatService _service;

  /// Chat posts list to display into ListView
  final List<PostModel> _posts = <PostModel>[];

  final List<UserModel> _users = <UserModel>[];

  final List<ChatModel> _chats = <ChatModel>[];

  final StreamController _invitationsStreamController =
      StreamController<Invitation>();

  late UserModel registeredUser;

  Selection _current = Selection();

  bool _registered = false;
  bool _onlyFavorites = false;
  bool _newChatNameInProgress = false;

  ChatScreenState({required this.registeredUser});

  @override
  void initState() {
    super.initState();
    // initialize Chat client service
    _service = ChatService(
        onRegistered: (int idUser, DateTime created) {
          setState(() {
            registeredUser.id = idUser;
            registeredUser.created = created;
            _registered = true;
          });
        },
        onSendPostOk: onSendPostOk,
        onSendPostError: onSendPostError,
        onUsersUpdated: onUsersUpdated,
        onInvitation: onInvitation,
        onChatsUpdated: onChatsUpdated,
        onPost: onPost,
        onRecvError: onRecvError,
        name: registeredUser.name,
        shortName: registeredUser.shortName);
  }

  @override
  void dispose() {
    // close Chat client service
    _service.shutdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("displaying ${_chats.length} chats");
    var selChatId =
        _current.chat == NOT_SELECTED ? NO_CHAT_ID : _chats[_current.chat].id;
    var filteredPosts = _posts.where((_p) => _p.chatId == selChatId);
    var filteredCount = filteredPosts.length;
    debugPrint("displaying $filteredCount posts");
    final isDesktop = isDisplayDesktop(context);
    if (isDesktop) {
      return Scaffold(
          appBar: _buildAppBar(),
          body: Row(
            children: [
              Column(
                children: [
                  Expanded(child: _buildChatsDrawer(_chats, _current)),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(
                  child:
                      _buildBodyWidget(_current.chatSelected, filteredPosts)),
            ],
          ));
    } else {
      return Scaffold(
        appBar: _buildAppBar(),
        body: _buildBodyWidget(_current.chatSelected, filteredPosts),
        drawer: _buildChatsDrawer(_chats, _current),
        // floatingActionButton: FloatingActionButton(
        //   heroTag: 'Add',
        //   onPressed: () {},
        //   tooltip: GalleryLocalizations.of(context).starterAppTooltipAdd,
        //   child: Icon(
        //     Icons.add,
        //     color: Theme.of(context).colorScheme.onSecondary,
        //   ),
        // ),
      );
    }
  }

  Widget _buildPostWidget(PostModel model) {
    // new message
    PostViewModel widget;
    var animationController = AnimationController(
      duration: Duration(milliseconds: !model.viewed ? 700 : 0),
      vsync: this,
    );
    switch (model.runtimeType) {
      case OutgoingPostModel:
        // add new outgoing message
        widget = OutgoingPostWidget(
          model: model as OutgoingPostModel,
          animationController: animationController,
          userName: registeredUser.shortName,
        );
        break;
      default:
        // add new incoming message
        widget = IncomingPostWidget(
          model: model,
          animationController: animationController,
          resolveUserName: userShortName,
        );
        break;
    }
    widget.animationController.forward();
    return widget;
  }

  Widget _buildChatsDrawer(Iterable<ChatModel> chats, Selection sel) {
    return Drawer(
      child: SafeArea(
        child: ListView.builder(
            padding: EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) {
              var item = chats.elementAt(index);
              var animationController = AnimationController(
                duration: Duration(milliseconds: !item.viewed ? 700 : 0),
                vsync: this,
              );
              var widget = ChatWidget(
                animationController: animationController,
                model: item,
                isSelected: sel.chat == index,
                letter: chatName(item.id)[0],
              );
              animationController.forward();
              return GestureDetector(
                child: widget,
                onTap: () {
                  if (sel.chat != index) {
                    setState(() {
                      sel.chat = index;
                    });
                  }
                },
              );
            },
            itemCount: chats.length),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
          "${registeredUser.shortName} (${registeredUser.name}) ${!_registered ? '* not logged in yet' : 'online'}"),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              _newChatNameInProgress = true;
            });
          },
          tooltip: 'Create new chat',
        ),
        //Spacer(flex: 10),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchInChats,
          tooltip: 'Search through all chats',
        ),
        IconButton(
            icon: _onlyFavorites
                ? const Icon(Icons.favorite)
                : const Icon(Icons.favorite_border),
            onPressed: onToggleFavourites,
            tooltip: 'Display only favourites'),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              _newChatNameInProgress = true;
            });
          },
          tooltip: 'Create new chat',
        ),
        //Spacer(flex: 1)
      ],
    );
  }

  Widget _buildBodyWidget(bool enableComposer, Iterable<PostModel> posts) {
    return Column(children: [
      // posts
      Flexible(
        child: ListView.builder(
            padding: EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder: (_, int index) =>
                _buildPostWidget(posts.elementAt(index)),
            itemCount: posts.length),
      ),
      // --------------------
      Divider(height: 1.0),
      // post composer
      Container(
        decoration: BoxDecoration(color: Theme.of(context).cardColor),
        child: PostComposerWidget(
          enabled: enableComposer,
          onSubmit: onSubmitPost,
        ),
      ),
    ]);
  }

  Widget _buildNewChatWidget() {
    return TextFormField(
      maxLength: 50,
      decoration: const InputDecoration(
        icon: Icon(Icons.chat),
        labelText: 'New chat name *',
        hintText: 'How to display new chat in list',
        // enabledBorder: UnderlineInputBorder(
        //   borderSide: BorderSide(color: Color(0xFF6200EE)),
        // ),
      ),
      onFieldSubmitted: onCreateChat,
    );
  }

  // Widget _old_build(BuildContext context) {
  //   debugPrint("displaying ${_chats.length} chats");
  //   var selChatId =
  //       _current.chat == NOT_SELECTED ? NO_CHAT_ID : _chats[_current.chat].id;
  //   var filteredPosts = _posts.where((_p) => _p.chatId == selChatId);
  //   var filteredCount = filteredPosts.length;
  //   debugPrint("displaying $filteredCount posts");
  //   return Scaffold(
  //     appBar: AppBar(
  //         title: Text(
  //             "MiGChat - ${registeredUser.shortName} (${registeredUser.name}) ${!_registered ? '* not logged in yet' : 'online'}")),
  //     body: Row(
  //       children: <Widget>[
  //         // users + chats
  //         Flexible(
  //           child: Column(children: [
  //             // chats
  //             Flexible(
  //               child: ListView.builder(
  //                   padding: EdgeInsets.all(8.0),
  //                   reverse: true,
  //                   itemBuilder: (_, int index) {
  //                     var animationController = AnimationController(
  //                       duration: Duration(
  //                           milliseconds: !_chats[index].viewed ? 700 : 0),
  //                       vsync: this,
  //                     );
  //                     var widget = ChatWidget(
  //                       animationController: animationController,
  //                       model: _chats[index],
  //                       isSelected: _selectedChat == index,
  //                       letter: chatName(_chats[index].id)[0],
  //                     );
  //                     animationController.forward();
  //                     return GestureDetector(
  //                       child: widget,
  //                       onTap: () {
  //                         if (_selectedChat != index) {
  //                           setState(() {
  //                             _selectedChat = index;
  //                           });
  //                         }
  //                       },
  //                     );
  //                   },
  //                   itemCount: _chats.length),
  //             ),
  //             if (_newChatNameInProgress)
  //               TextFormField(
  //                 maxLength: 50,
  //                 decoration: const InputDecoration(
  //                   icon: Icon(Icons.chat),
  //                   labelText: 'New chat name *',
  //                   hintText: 'How to display new chat in list',
  //                   // enabledBorder: UnderlineInputBorder(
  //                   //   borderSide: BorderSide(color: Color(0xFF6200EE)),
  //                   // ),
  //                 ),
  //                 onFieldSubmitted: onCreateChat,
  //               ),
  //             BottomAppBar(
  //                 color: Colors.blue,
  //                 child: IconTheme(
  //                   data: IconThemeData(
  //                       color: Theme.of(context).colorScheme.onPrimary),
  //                   child: Row(
  //                     children: <Widget>[
  //                       IconButton(
  //                         icon: const Icon(Icons.menu),
  //                         onPressed: onNavigationMenu,
  //                         tooltip: 'Open navigation menu',
  //                       ),
  //                       IconButton(
  //                         icon: const Icon(Icons.search),
  //                         onPressed: onSearchInChats,
  //                         tooltip: 'Search through all chats',
  //                       ),
  //                       IconButton(
  //                           icon: _onlyFavorites
  //                               ? const Icon(Icons.favorite)
  //                               : const Icon(Icons.favorite_border),
  //                           onPressed: onToggleFavourites,
  //                           tooltip: 'Display only favourites'),
  //                       Spacer(flex: 10),
  //                       IconButton(
  //                         icon: const Icon(Icons.add),
  //                         onPressed: () {
  //                           setState(() {
  //                             _newChatNameInProgress = true;
  //                           });
  //                         },
  //                         tooltip: 'Create new chat',
  //                       ),
  //                       Spacer(
  //                         flex: 1,
  //                       )
  //                     ],
  //                   ),
  //                 )),
  //           ]),
  //         ),
  //         // ------------------
  //         VerticalDivider(width: 1.0),
  //         // posts + composer
  //         Expanded(
  //             flex: 2,
  //             child: Column(children: [
  //               // posts
  //               Flexible(
  //                 child: ListView.builder(
  //                     padding: EdgeInsets.all(8.0),
  //                     reverse: true,
  //                     itemBuilder: (_, int index) =>
  //                         _buildPostWidget(filteredPosts.elementAt(index)),
  //                     itemCount: filteredCount),
  //               ),
  //               // --------------------
  //               Divider(height: 1.0),
  //               // post composer
  //               Container(
  //                 decoration: BoxDecoration(color: Theme.of(context).cardColor),
  //                 child: PostComposerWidget(
  //                   enabled: _selectedChat != NOT_SELECTED,
  //                   onSubmit: onSubmitPost,
  //                 ),
  //               ),
  //             ])),
  //       ],
  //     ),
  //   );
  // }

  /// 'new outgoing message created' event
  void onSubmitPost(String text) {
    assert(_current.chatSelected);

    // create new message from input text
    var post = OutgoingPostModel(
        text: text,
        userId: registeredUser.id,
        chatId: _chats[_current.chat].id,
        status: PostStatus.UNKNOWN);

    debugPrint("new outgoing post ${post.text.trim()} -> display stream");
    _addPost(post);

    // async send message to the server
    _service.sendPost(post);

    setState(() {});
  }

  void onSearchInChats() {
    debugPrint('Searching in chats is not implemented yet');
  }

  void onToggleFavourites() {
    setState(() {
      _onlyFavorites = !_onlyFavorites;
    });
    debugPrint('Toggling favourites is not implemented yet');
  }

  void onCreateChat(String name) {
    setState(() {
      _newChatNameInProgress = false;
    });
    debugPrint('Creating new chat ${name.trim()}');
    _service.createChat(name);
  }

  String userShortName(int userId) {
    if (userId == registeredUser.id) {
      return registeredUser.shortName;
    }
    var i = _users.indexWhere((_u) => _u.id == userId);
    if (i != NOT_FOUND) {
      return _users[i].shortName;
    } else {
      return userId.toString();
    }
  }

  String userName(int userId) {
    if (userId == registeredUser.id) {
      return registeredUser.name;
    }
    var i = _users.indexWhere((_u) => _u.id == userId);
    if (i != NOT_FOUND) {
      return _users[i].name;
    } else {
      return userId.toString();
    }
  }

  String chatName(int chatId) {
    var idxChat = _chats.indexWhere((_c) => _c.id == chatId);
    if (idxChat != NOT_FOUND) {
      if (_chats[idxChat].description.length > 0) {
        return _chats[idxChat].description;
      } else {
        var idxId =
            _chats[idxChat].userIds.indexWhere((id) => id != registeredUser.id);
        if (idxId == NOT_FOUND) {
          return '';
        } else {
          return userShortName(_chats[idxChat].userIds[idxId]);
        }
      }
    } else {
      return chatId.toString();
    }
  }

  /// 'outgoing message sent to the server' event
  void onSendPostOk(OutgoingPostModel post) {
    debugPrint("post \"${post.text.trim()}\" sent to the server");
  }

  /// 'failed to send message' event
  void onSendPostError(PostModel message, String error) {
    debugPrint(
        "FAILED to send message \"${message.text.trim()}\" to the server: $error");
  }

  void onUsersUpdated(UpdateUsers update) {
    update.added.forEach((user) {
      // check if user with the same ID already exists
      var i = _users.indexWhere((item) => item.id == user.id.toInt());
      if (i != NOT_FOUND) {
        //todo: found
      } else {
        var model = UserModel.from(user);
        setState(() {
          _users.add(model);
        });
        // create chat with user
        _service.createDialogWith(model.id);
      }
    });
    for (var id in update.online) {
      var i = _users.indexWhere((_u) => _u.id == id.toInt());
      if (i != NOT_FOUND) {
        setState(() {
          _users[i].online = true;
        });
      }
    }
    for (var id in update.offline) {
      var i = _users.indexWhere((_u) => _u.id == id.toInt());
      if (i != NOT_FOUND) {
        setState(() {
          _users[i].online = false;
        });
      }
    }
  }

  void onChatsUpdated(UpdateChats update) {
    setState(() {
      if (update.updated.length > 0) {
        _addChats(update.updated);
      }
      for (var id in update.gone) {
        _chats.removeWhere((c) => c.id == id.toInt());
      }
    });
  }

  void onInvitation(Invitation invitation) {
    debugPrint(
        "invitation received from ${invitation.fromUserId} to ${invitation.chatId}, accepting");
    _service.enterChat(invitation.chatId.toInt());
    _invitationsStreamController.add(invitation);
  }

  /// 'failed to receive messages' event
  void onRecvError(String error) {
    debugPrint("FAILED to receive messages from the server: $error");
  }

  /// 'new incoming message received from the server' event
  void onPost(Post post) {
    debugPrint(
        'post \"${post.text.trim()}\" from the server --> display stream');
    _addPost(PostModel.from(post));
    setState(() {});
  }

  /// this methods is called to display new (outgoing or incoming) message or
  /// update status of existing outgoing message
  void _addPost(PostModel post) {
    debugPrint(
        'new ${post.id == NO_POST_ID ? 'unconfirmed' : ''} post to display, "${post.text.trim()}"');
    if (post.id == NO_POST_ID) {
      if (post.userId != registeredUser.id) {
        debugPrint('proto violation, get incoming post without ID, ignoring');
      } else {
        // test if it is already seen before
        var i = _posts.indexWhere((_p) =>
            _p.userId == post.userId &&
            _p.chatId == post.chatId &&
            _p.text == post.text);
        if (i == NOT_FOUND) {
          // own post which is still unknown
          setState(() {
            _posts.insert(0, OutgoingPostModel.from(post, PostStatus.UNKNOWN));
          });
          debugPrint('recent unconfirmed outgoing post added to  display');
        } else {
          debugPrint('ignoring duplicated unconfirmed outgoing post');
        }
      }
    } else {
      // post with actual ID
      // test if duplicated
      if (_posts.indexWhere((_p) => _p.id == post.id) == NOT_FOUND) {
        // test if there is our recent post
        var iNoIdYet = _posts.indexWhere((_p) =>
            _p.id == NO_POST_ID &&
            _p.userId == registeredUser.id &&
            _p.chatId == post.chatId &&
            _p.text == post.text);
        if (iNoIdYet != NOT_FOUND) {
          // found own recent post, update only id & status
          setState(() {
            var upd = _posts[iNoIdYet];
            upd.id = upd.id;
            // must be outgoing post, update status
            assert(upd is OutgoingPostModel);
            var asOutgoing = upd as OutgoingPostModel;
            asOutgoing.status = PostStatus.SENT;
          });
          debugPrint('recent outgoing post has been updated');
        } else {
          // not found, add new post to display
          if (post.userId == registeredUser.id) {
            // own post which is still unknown
            setState(() {
              _posts.insert(0, OutgoingPostModel.from(post, PostStatus.SENT));
            });
            debugPrint('recent outgoing added to display');
          } else {
            // other's post
            setState(() {
              _posts.insert(0, post);
            });
            debugPrint('incoming post added to display');
          }
        }
      } else {
        // already known post, ignore
        debugPrint('ignoring duplicated post');
      }
    }
  }

  void _addChats(List<Chat> chats) {
    chats.forEach((chat) {
      // check if chat widget with the same ID already exists
      var i = _chats.indexWhere((item) => item.id == chat.id.toInt());
      if (i != NOT_FOUND) {
        _chats[i].userIds = chat.users.map((v) => v.toInt()).toList();
      } else {
        _chats.insert(0, ChatModel.from(chat, userShortName, chatName));
      }
    });
  }
}
