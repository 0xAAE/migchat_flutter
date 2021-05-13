import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_model.dart';
import 'chat_widget.dart';
import 'post_model.dart';
import 'post_composer_widget.dart';
import 'post_widget_incoming.dart';
import 'post_widget_outgoing.dart';
import 'chat_service.dart';
import 'user_model.dart';
import 'current_user_screen.dart';
import 'layout/adaptive.dart';

typedef String ResolveUserName(int userId);
typedef String ResolveChatName(int chatId);

const String NO_NAME = '?';

/// Host screen widget - main window
class ChatScreen extends StatefulWidget {
  ChatScreen() : super(key: new ObjectKey('Main window'));

  @override
  State createState() => ChatScreenState();
}

const int NOT_SELECTED = -1;
const int NOT_FOUND = -1;

class Selection {
  int chat = NOT_SELECTED;
  bool get chatSelected => chat != NOT_SELECTED;

  void reset() {
    chat = NOT_SELECTED;
  }
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

  UserModel _currentUser =
      UserModel(name: '', shortName: '', created: DateTime.now());

  Selection _current = Selection();

  bool _registered = false;
  bool _onlyFavorites = false;
  bool _newChatNameInProgress = false;

  ChatScreenState();

  @override
  void initState() {
    super.initState();
    // initialize Chat client service
    _service = ChatService(
        onRegistered: (int idUser, DateTime created) {
          setState(() {
            _currentUser.id = idUser;
            _currentUser.created = created;
            _registered = true;
          });
          _saveUser(_currentUser.name, _currentUser.shortName);
        },
        onSendPostOk: onSendPostOk,
        onSendPostError: onSendPostError,
        onCreateChatOk: onCreateChatOk,
        onCreateChatError: onCreateChatError,
        onUsersUpdated: onUsersUpdated,
        onInvitation: onInvitation,
        onChatsUpdated: onChatsUpdated,
        onPost: onPost,
        onRecvError: onRecvError);
    // try load last settings
    _initUser();
  }

  void _reset() {
    _service.shutdown();
    setState(() {
      _current.reset();
      _chats.clear();
      _users.clear();
      _posts.clear();
    });
  }

  _requestUserInfo() async {
    var info = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CurrentUserScreen(_currentUser),
        ));
    if (info != null) {
      _currentUser.name = info.name;
      _currentUser.shortName = info.shortName;
    }
  }

  _initUser() async {
    SharedPreferences settings = await SharedPreferences.getInstance();
    var name = settings.getString('name') ?? '';
    var shortName = settings.getString('shortName') ?? '';
    if (name.length > 0 && shortName.length > 0) {
      setState(() {
        _currentUser.name = name;
        _currentUser.shortName = shortName;
      });
    } else {
      await _requestUserInfo();
    }
    _service.register(
        shortName: _currentUser.shortName, name: _currentUser.name);
  }

  _changeUser() async {
    var storedName = _currentUser.name;
    var storedShortName = _currentUser.shortName;
    await _requestUserInfo();
    if (storedName != _currentUser.name ||
        storedShortName != _currentUser.shortName) {
      debugPrint('User has changed, re-registering on server');
      _reset();
      _service.register(
          shortName: _currentUser.shortName, name: _currentUser.name);
    } else {
      debugPrint('User has not changed, continue with current registration');
    }
  }

  _saveUser(String name, String shortName) async {
    SharedPreferences settings = await SharedPreferences.getInstance();
    settings.setString('name', name);
    settings.setString('shortName', shortName);
  }

  @override
  void dispose() {
    // close Chat client service
    _service.shutdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var selChatId =
        _current.chat == NOT_SELECTED ? NO_CHAT_ID : _chats[_current.chat].id;
    var filteredPosts = _posts.where((_p) => _p.chatId == selChatId);
    var filteredCount = filteredPosts.length;
    final isDesktop = isDisplayDesktop(context);
    if (isDesktop) {
      return Scaffold(
          appBar: _buildAppBar(compact: false),
          body: Row(
            children: [
              Container(
                  // drawer max width is 304, got from experiment
                  width: 304, //double.infinity,
                  child: Column(
                    children: [
                      if (_newChatNameInProgress)
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: _buildNewChatWidget()),
                      Expanded(
                          child: _buildChatsDrawer(context, _chats, _current,
                              autoHide: false, withHeader: false)),
                    ],
                  )),
              const VerticalDivider(width: 1),
              Expanded(
                  child: _buildBodyWidget(
                      context, _current.chatSelected, filteredPosts)),
            ],
          ));
    } else {
      return Scaffold(
        appBar: _buildAppBar(compact: true),
        body: _buildBodyWidget(context, _current.chatSelected, filteredPosts,
            chatTitle: _current.chatSelected,
            newChatName: _newChatNameInProgress),
        drawer: _buildChatsDrawer(context, _chats, _current,
            autoHide: true, withHeader: true),
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

    // Ensure user registered on server, so info is available
    assert(_registered);

    switch (model.runtimeType) {
      case OutgoingPostModel:
        // add new outgoing message
        widget = OutgoingPostWidget(
          model: model as OutgoingPostModel,
          animationController: animationController,
          userName: _currentUser.shortName,
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

  Widget _buildChatsDrawer(
      BuildContext context, Iterable<ChatModel> chats, Selection sel,
      {required bool autoHide, required bool withHeader}) {
    return Drawer(
      child: SafeArea(
        child: ListView.builder(
            padding: EdgeInsets.all(8.0),
            //reverse: true,
            itemBuilder: (_, int idx) {
              // effective index
              int index = withHeader ? idx - 1 : idx;
              if (index < 0) {
                var defStyle =
                    TextStyle(color: Theme.of(context).secondaryHeaderColor);
                var nameStyle = Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.apply(color: defStyle.color) ??
                    defStyle;
                var shortStyle = Theme.of(context)
                        .textTheme
                        .headline4
                        ?.apply(color: defStyle.color) ??
                    defStyle;
                return DrawerHeader(
                    decoration:
                        BoxDecoration(color: Theme.of(context).primaryColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_currentUser.shortName, style: shortStyle),
                        Container(
                          margin: EdgeInsets.only(top: 5.0),
                          child: Text(_currentUser.name, style: nameStyle),
                        ),
                      ],
                    ));
              }
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
                    if (autoHide) {
                      Navigator.pop(context);
                    }
                  }
                },
              );
            },
            // counting header
            itemCount: chats.length + (withHeader ? 1 : 0)),
      ),
    );
  }

  AppBar _buildAppBar({required bool compact}) {
    var name = _currentUser.name;
    var shortName = _currentUser.shortName;
    String title = !compact
        ? '$shortName ($name) ${!_registered ? '* not logged in yet' : 'online'}'
        : '$shortName ${!_registered ? '* not logged in' : 'online'}';
    return AppBar(
      title: Text(title),
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
          icon: const Icon(Icons.logout),
          onPressed: () {
            _changeUser();
          },
          tooltip: 'Switch current user',
        ),
      ],
    );
  }

  Widget _buildBodyWidget(
    BuildContext context,
    bool enableComposer,
    Iterable<PostModel> posts, {
    bool chatTitle = false,
    bool newChatName = false,
  }) {
    return Column(children: [
      // new chat name
      if (newChatName)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildNewChatWidget(),
        ),
      // chat title
      // todo: pass current chat via args
      if (!newChatName && chatTitle && _current.chatSelected)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          width: double.infinity,
          child: Text(
            chatName(_chats[_current.chat].id),
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.left,
          ),
        ),
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
      maxLines: 1,
      decoration: const InputDecoration(
        icon: Icon(Icons.chat),
        helperText: 'Submit empty name to cancel',
        labelText: 'New chat name *',
        hintText: 'How to display new chat in list',
        // enabledBorder: UnderlineInputBorder(
        //   borderSide: BorderSide(color: Color(0xFF6200EE)),
        // ),
      ),
      onFieldSubmitted: onCreateChat,
    );
  }

  /// 'new outgoing message created' event
  void onSubmitPost(String text) {
    assert(_current.chatSelected);
    assert(_registered);

    // create new message from input text
    var post = OutgoingPostModel(
        text: text,
        userId: _currentUser.id,
        chatId: _chats[_current.chat].id,
        status: PostStatus.UNKNOWN);

    debugPrint('new outgoing post ${post.text.trim()} -> display stream');
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
    if (name.length > 0) {
      debugPrint('Creating new chat ${name.trim()}');
      _service.createChat(name);
    }
  }

  String userShortName(int userId) {
    if (userId == _currentUser.id) {
      return _currentUser.shortName;
    }
    var i = _users.indexWhere((_u) => _u.id == userId);
    if (i != NOT_FOUND) {
      return _users[i].shortName;
    } else {
      return userId.toString();
    }
  }

  String userName(int userId) {
    if (userId == _currentUser.id) {
      return _currentUser.name;
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
        var idxMember =
            _chats[idxChat].userIds.indexWhere((id) => id != _currentUser.id);
        if (idxMember == NOT_FOUND) {
          return NO_NAME;
        } else {
          return userShortName(_chats[idxChat].userIds[idxMember]);
        }
      }
    } else {
      return chatId.toString();
    }
  }

  /// 'outgoing message sent to the server' event
  void onSendPostOk(OutgoingPostModel post) {
    debugPrint('post "${post.text.trim()}" sent to the server');
  }

  /// 'failed to send message' event
  void onSendPostError(PostModel message, String error) {
    debugPrint(
        'FAILED to send message "${message.text.trim()}" to the server: $error');
  }

  void onCreateChatOk(Chat chat) {
    _addChats(<Chat>[chat]);
    var createdId = chat.id.toInt();
    _current.chat = _chats.indexWhere((c) => c.id == createdId);
    setState(() {});
  }

  void onCreateChatError(String name, String error) {
    debugPrint('FAILED to create chat: $error');
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
        'invitation received from ${invitation.fromUserId} to ${invitation.chatId}, accepting');
    _service.enterChat(invitation.chatId.toInt());
    _invitationsStreamController.add(invitation);
  }

  /// 'failed to receive messages' event
  void onRecvError(String error) {
    debugPrint('FAILED to receive messages from the server: $error');
  }

  /// 'new incoming message received from the server' event
  void onPost(Post post) {
    debugPrint('post "${post.text.trim()}" from the server --> display stream');
    _addPost(PostModel.from(post));
    setState(() {});
  }

  /// this methods is called to display new (outgoing or incoming) message or
  /// update status of existing outgoing message
  void _addPost(PostModel post) {
    debugPrint(
        'new ${post.id == NO_POST_ID ? 'unconfirmed' : ''} post to display, "${post.text.trim()}"');
    if (post.id == NO_POST_ID) {
      if (post.userId != _currentUser.id) {
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
            _p.userId == _currentUser.id &&
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
          if (post.userId == _currentUser.id) {
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
