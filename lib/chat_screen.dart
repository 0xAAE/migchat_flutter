import 'dart:async';

import 'package:flutter/material.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';

import 'bandwidth_buffer.dart';
import 'chat_model.dart';
import 'chat_widget.dart';
import 'post_model.dart';
import 'post_widget_incoming.dart';
import 'post_widget_outgoing.dart';
import 'chat_service.dart';
import 'invitation_model.dart';
import 'user_model.dart';
import 'user_widget.dart';

/// Host screen widget - main window
class ChatScreen extends StatefulWidget {
  ChatScreen() : super(key: new ObjectKey("Main window"));

  @override
  State createState() => ChatScreenState();
}

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
  final List<PostViewModel> _posts = <PostViewModel>[];

  /// Look at the https://codelabs.developers.google.com/codelabs/flutter/#4
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  final StreamController _usersStreamController =
      StreamController<List<User>>();
  final List<UserWidget> _users = <UserWidget>[];

  final StreamController _chatsStreamController =
      StreamController<List<Chat>>();
  final List<ChatWidget> _chats = <ChatWidget>[];

  final StreamController _invitationsStreamController =
      StreamController<Invitation>();

  int _selectedUser = -1;

  int _selectedChat = -1;

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
        onSendPostOk: onSendPostOk,
        onSendPostError: onSendPostError,
        onUsersUpdated: onUsersUpdated,
        onInvitation: onInvitation,
        onChatsUpdated: onChatsUpdated,
        onPost: onPost,
        onRecvError: onRecvError,
        name: 'Alexander',
        shortName: '0xAAE');
  }

  @override
  void dispose() {
    // close Chat client service
    _service.shutdown();

    // close bandwidth buffer
    _bandwidthBuffer.stop();

    // free UI resources
    for (PostViewModel view in _posts) view.animationController.dispose();
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
                        return GestureDetector(
                            child: _users[index],
                            onTap: () {
                              setState(() {
                                if (_selectedUser != index) {
                                  if (_selectedUser != -1) {
                                    _users[_selectedUser].select(false);
                                  }
                                  _users[index].select(true);
                                  _selectedUser = index;
                                }
                                if (_selectedChat != -1) {
                                  _chats[_selectedChat].select(false);
                                  _selectedChat = -1;
                                }
                              });
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
                        return GestureDetector(
                          child: _chats[index],
                          onTap: () {
                            setState(() {
                              if (_selectedChat != index) {
                                if (_selectedChat != -1) {
                                  _chats[_selectedChat].select(false);
                                }
                                _chats[index].select(true);
                                _selectedChat = index;
                              }
                              if (_selectedUser != -1) {
                                _users[_selectedUser].select(false);
                                _selectedUser = -1;
                              }
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
              flex: 4,
              child: Column(children: [
                // posts
                Flexible(
                  child: StreamBuilder<List<PostModel>>(
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
                          itemBuilder: (_, int index) => _posts[index],
                          itemCount: _posts.length);
                    },
                  ),
                ),
                // --------------------
                Divider(height: 1.0),
                // post composer
                Container(
                  decoration: BoxDecoration(color: Theme.of(context).cardColor),
                  child: _buildTextComposer(),
                ),
              ])),
        ],
      ),
    );
  }

  /// Look at the https://codelabs.developers.google.com/codelabs/flutter/#4
  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                maxLines: null,
                textInputAction: TextInputAction.send,
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _isComposing ? _handleSubmitted : null,
                decoration: InputDecoration.collapsed(hintText: "Send a post"),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null),
            ),
          ],
        ),
      ),
    );
  }

  /// 'new outgoing message created' event
  void _handleSubmitted(String text) {
    _textController.clear();
    _isComposing = false;

    // create new message from input text
    var message = OutgoingPostModel(text: text, id: '');

    // send message to the display stream through the bandwidth buffer
    _bandwidthBuffer.send(message);

    // async send message to the server
    _service.sendPost(message);
  }

  /// 'outgoing message sent to the server' event
  void onSendPostOk(OutgoingPostModel message) {
    debugPrint("message \"${message.text}\" sent to the server");
    // send updated message to the display stream through the bandwidth buffer
    _bandwidthBuffer.send(message);
  }

  /// 'failed to send message' event
  void onSendPostError(PostModel message, String error) {
    debugPrint(
        "FAILED to send message \"${message.text}\" to the server: $error");
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
        "invitation received from ${invitation.fromUserId} to ${invitation.chatId}");
    _service.enterChat(invitation.chatId);
    _invitationsStreamController.add(invitation);
  }

  /// 'failed to receive messages' event
  void onRecvError(String error) {
    debugPrint("FAILED to receive messages from the server: $error");
  }

  /// 'new incoming message received from the server' event
  void onPost(Post post) {
    debugPrint("received post from the server: ${post.text}");
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
    posts.forEach((model) {
      // check if message with the same ID is already existed
      var i = _posts.indexWhere((item) => item.model.id == model.id);
      if (i != -1) {
        // found
        var chatMessage = _posts[i];
        if (chatMessage is OutgoingPostWidget) {
          assert(model is OutgoingPostModel,
              "message must be MessageOutcome type");
          // update status for outgoing message (from UNKNOWN to SENT)
          chatMessage.controller.setStatus((model as OutgoingPostModel).status);
        }
      } else {
        // new message
        PostViewModel chatMessage;
        var animationController = AnimationController(
          duration: Duration(milliseconds: 700),
          vsync: this,
        );
        switch (model.runtimeType) {
          case OutgoingPostModel:
            // add new outgoing message
            chatMessage = OutgoingPostWidget(
              model: model as OutgoingPostModel,
              animationController: animationController,
            );
            break;
          default:
            // add new incoming message
            chatMessage = IncomingPostWidget(
              model: model,
              animationController: animationController,
            );
            break;
        }
        _posts.insert(0, chatMessage);

        // look at the https://codelabs.developers.google.com/codelabs/flutter/#6
        chatMessage.animationController.forward();
      }
    });
  }

  void _addChats(List<Chat> chats) {
    chats.forEach((chat) {
      var model = ChatModel.from(chat);
      // new chat widget
      var widget = ChatWidget(
          animationController: AnimationController(
            duration: Duration(milliseconds: 700),
            vsync: this,
          ),
          model: model);
      // check if chat widget with the same ID already exists
      var i = _chats.indexWhere((item) => item.model.id == model.id);
      if (i != -1) {
        _chats.removeAt(i);
        _chats.insert(i, widget);
      } else {
        _chats.insert(0, widget);
      }
      // look at the https://codelabs.developers.google.com/codelabs/flutter/#6
      widget.animationController.forward();
    });
  }

  void _addUsers(List<User> users) {
    users.forEach((user) {
      var model = UserModel.from(user);
      // new user
      var widget = UserWidget(
          animationController: AnimationController(
            duration: Duration(milliseconds: 700),
            vsync: this,
          ),
          model: model);
      // check if user widget with the same ID already exists
      var i = _users.indexWhere((item) => item.model.id == model.id);
      if (i != -1) {
        // found
        _users.removeAt(i);
        _users.insert(i, widget);
      } else {
        _users.insert(0, widget);
      }
      // look at the https://codelabs.developers.google.com/codelabs/flutter/#6
      widget.animationController.forward();
    });
  }
}
