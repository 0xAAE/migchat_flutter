import 'dart:async';

import 'package:flutter/material.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';

import 'bandwidth_buffer.dart';
import 'chat_model.dart';
import 'chat_widget.dart';
import 'post_model.dart';
import 'post_composer_widget.dart';
import 'post_widget_incoming.dart';
import 'post_widget_outgoing.dart';
import 'chat_service.dart';
//import 'invitation_model.dart';
import 'user_model.dart';
import 'user_widget.dart';

/// Host screen widget - main window
class ChatScreen extends StatefulWidget {
  ChatScreen() : super(key: new ObjectKey("Main window"));

  @override
  State createState() => ChatScreenState();
}

const int NOT_SELECTED = -1;
const int NOT_FOUND = -1;

/// State for ChatScreen widget
class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  /// Chat client service
  late ChatService _service;

  /// Look at the https://github.com/flutter/flutter/issues/26375
  late BandwidthBuffer _bandwidthBuffer;

  /// Stream controller to add posts to the ListView
  final StreamController _postsStreamController =
      StreamController<List<PostModel>>();

  /// Chat posts list to display into ListView
  final List<PostModel> _posts = <PostModel>[];

  final StreamController _usersStreamController =
      StreamController<List<User>>();
  final List<UserModel> _users = <UserModel>[];

  final StreamController _chatsStreamController =
      StreamController<List<Chat>>();
  final List<ChatModel> _chats = <ChatModel>[];

  final StreamController _invitationsStreamController =
      StreamController<Invitation>();

  UserModel registeredUser =
      UserModel(id: 0, shortName: '0xAAE', name: 'Alexander Avramenko');

  int _selectedUser = NOT_SELECTED;

  int _selectedChat = NOT_SELECTED;

  @override
  void initState() {
    super.initState();

    // initialize bandwidth buffer for chat posts display
    _bandwidthBuffer = BandwidthBuffer<PostModel>(
      duration: Duration(milliseconds: 500),
      onReceive: onReceivedFromBuffer,
    );
    _bandwidthBuffer.start();

    // initialize Chat client service
    _service = ChatService(
        onRegistered: (int idUser) {
          registeredUser.id = idUser;
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
    // close bandwidth buffer
    _bandwidthBuffer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MiGChat")),
      body: Row(
        children: <Widget>[
          // users + chats
          Flexible(
            child: Column(children: [
              // users
              Flexible(
                  child: StreamBuilder<List<User>>(
                key: ObjectKey(_usersStreamController),
                stream: _usersStreamController.stream as Stream<List<User>>,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      break;
                    case ConnectionState.active:
                    case ConnectionState.done:
                      _addUsers(snapshot.data);
                  }
                  return ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      reverse: true,
                      itemBuilder: (_, int index) {
                        var milliseconds = _selectedUser == index ? 700 : 0;
                        var widget = UserWidget(
                          animationController: AnimationController(
                            duration: Duration(milliseconds: milliseconds),
                            vsync: this,
                          ),
                          model: _users[index],
                          isSelected: _selectedUser == index,
                        );
                        // look at the https://codelabs.developers.google.com/codelabs/flutter/#6
                        widget.animationController.forward();
                        return GestureDetector(
                            child: widget,
                            onTap: () {
                              if (_selectedUser != index) {
                                setState(() {
                                  _selectedUser = index;
                                  _selectedChat = NOT_SELECTED;
                                });
                              }
                            });
                      },
                      itemCount: _users.length);
                },
              )),
              // -----------
              Divider(height: 1.0),
              // chats
              Flexible(
                  child: StreamBuilder<List<Chat>>(
                key: ObjectKey(_chatsStreamController),
                stream: _chatsStreamController.stream as Stream<List<Chat>>,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      break;
                    case ConnectionState.active:
                    case ConnectionState.done:
                      _addChats(snapshot.data);
                  }
                  return ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      reverse: true,
                      itemBuilder: (_, int index) {
                        var milliseconds = _selectedChat == index ? 700 : 0;
                        var widget = ChatWidget(
                            animationController: AnimationController(
                              duration: Duration(milliseconds: milliseconds),
                              vsync: this,
                            ),
                            model: _chats[index],
                            isSelected: _selectedChat == index);
                        // look at the https://codelabs.developers.google.com/codelabs/flutter/#6
                        widget.animationController.forward();
                        return GestureDetector(
                          child: widget,
                          onTap: () {
                            setState(() {
                              _selectedChat = index;
                              _selectedUser = NOT_SELECTED;
                            });
                          },
                        );
                      },
                      itemCount: _chats.length);
                },
              )),
            ]),
          ),
          // ------------------
          VerticalDivider(width: 1.0),
          // posts + composer
          Expanded(
              flex: 2,
              child: Column(children: [
                // posts
                Flexible(
                  child: StreamBuilder<List<PostModel>>(
                    key: ObjectKey(_postsStreamController),
                    stream: _postsStreamController.stream
                        as Stream<List<PostModel>>,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          break;
                        case ConnectionState.active:
                        case ConnectionState.done:
                          _addPosts(snapshot.data);
                      }
                      return ListView.builder(
                          padding: EdgeInsets.all(8.0),
                          reverse: true,
                          itemBuilder: (_, int index) =>
                              _buildPostWidget(_posts[index]),
                          itemCount: _posts.length);
                    },
                  ),
                ),
                // --------------------
                Divider(height: 1.0),
                // post composer
                Container(
                  decoration: BoxDecoration(color: Theme.of(context).cardColor),
                  child: PostComposerWidget(
                    enabled: _selectedChat != NOT_SELECTED,
                    onSubmit: _onSubmitPost,
                  ),
                ),
              ])),
        ],
      ),
    );
  }

  /// 'new outgoing message created' event
  void _onSubmitPost(String text) {
    assert(_selectedChat != NOT_SELECTED);

    // create new message from input text
    var post = OutgoingPostModel(
        text: text,
        userId: registeredUser.id,
        chatId: _chats[_selectedChat].id,
        status: PostStatus.UNKNOWN);

    // send message to the display stream through the bandwidth buffer
    _bandwidthBuffer.send(post);

    // async send message to the server
    _service.sendPost(post);
  }

  /// 'outgoing message sent to the server' event
  void onSendPostOk(OutgoingPostModel message) {
    debugPrint("message \"${message.text.trim()}\" sent to the server");
    // send updated message to the display stream through the bandwidth buffer
    _bandwidthBuffer.send(message);
  }

  /// 'failed to send message' event
  void onSendPostError(PostModel message, String error) {
    debugPrint(
        "FAILED to send message \"${message.text.trim()}\" to the server: $error");
  }

  void onUsersUpdated(UpdateUsers update) {
    for (var user in update.added) {
      debugPrint(
          "user has registered on the server: ${user.shortName} (${user.name})");
      _usersStreamController.add(update.added);
    }
    for (var user in update.gone) {
      debugPrint(
          "user has gone from the server: ${user.shortName} (${user.name})");
    }
  }

  void onChatsUpdated(UpdateChats update) {
    for (var chat in update.added) {
      debugPrint(
          "new ${chat.permanent ? 'permanent' : ''} chat has been created: ${chat.description}");
      _chatsStreamController.add(update.added);
    }
    for (var chat in update.gone) {
      debugPrint("chat has been deleted: ${chat.description}");
    }
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
    debugPrint("received post from the server: \"${post.text.trim()}\"");
    // send updated message to the display stream through the bandwidth buffer
    _bandwidthBuffer.send(PostModel.from(post));
  }

  /// this event means 'the message (or messages) can be displayed'
  /// Look at the https://github.com/flutter/flutter/issues/26375
  void onReceivedFromBuffer(List<PostModel> posts) {
    // send message(s) to the ListView stream
    _postsStreamController.add(posts);
  }

  /// this methods is called to display new (outgoing or incoming) message or
  /// update status of existing outgoing message
  void _addPosts(List<PostModel> posts) {
    posts.forEach((post) {
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
            _posts.insert(0, OutgoingPostModel.from(post, PostStatus.UNKNOWN));
            debugPrint('recent unconfirmed outgoing post added to  display');
          } else {
            debugPrint('ignoring duplicated unconfirmed outgoing post');
          }
        }
      } else {
        // post with actual ID
        // test if duplicated
        var i = _posts.indexWhere((_p) => _p.id == post.id);
        if (i == NOT_FOUND) {
          // test if there is our recent post
          i = _posts.indexWhere((_p) =>
              _p.id == NO_POST_ID &&
              _p.userId == registeredUser.id &&
              _p.chatId == post.chatId &&
              _p.text == post.text);
          if (i != NOT_FOUND) {
            // found own recent post, update only id & status
            _posts[i].id = post.id;
            // must be outgoing post, update status
            assert(_posts[i] is OutgoingPostModel);
            var asOutgoing = _posts[i] as OutgoingPostModel;
            asOutgoing.status = PostStatus.SENT;
            debugPrint('recent outgoing post has been updated');
          } else {
            // not found, add new post to display
            if (post.userId == registeredUser.id) {
              // own post which is still unknown
              _posts.insert(0, OutgoingPostModel.from(post, PostStatus.SENT));
              debugPrint('recent outgoing added to display');
            } else {
              // other's post
              _posts.insert(0, post);
              debugPrint('incoming post added to display');
            }
          }
        } else {
          // already known post, ignore
          debugPrint('ignoring duplicated post');
        }
      }
    });
  }

  PostViewModel _buildPostWidget(PostModel model, {bool animated = false}) {
    // new message
    PostViewModel widget;
    var animationController = AnimationController(
      duration: Duration(milliseconds: animated ? 700 : 0),
      vsync: this,
    );
    switch (model.runtimeType) {
      case OutgoingPostModel:
        // add new outgoing message
        widget = OutgoingPostWidget(
          model: model as OutgoingPostModel,
          animationController: animationController,
        );
        break;
      default:
        // add new incoming message
        widget = IncomingPostWidget(
          model: model,
          animationController: animationController,
        );
        break;
    }
    widget.animationController.forward();
    return widget;
  }

  void _addChats(List<Chat> chats) {
    chats.forEach((chat) {
      // check if chat widget with the same ID already exists
      var i = _chats.indexWhere((item) => item.id == chat.id.toInt());
      if (i != NOT_FOUND) {
        _chats[i].updateUsers(chat, _users, registeredUser);
      } else {
        _chats.insert(0, ChatModel.from(chat, _users, registeredUser));
      }
    });
  }

  void _addUsers(List<User> users) {
    users.forEach((user) {
      // check if user widget with the same ID already exists
      var i = _users.indexWhere((item) => item.id == user.id.toInt());
      if (i != NOT_FOUND) {
        //todo: found
      } else {
        _users.insert(0, UserModel.from(user));
      }
    });
  }
}
