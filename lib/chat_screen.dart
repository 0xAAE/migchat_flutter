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
  final List<PostModel> _posts = <PostModel>[];

  /// Look at the https://codelabs.developers.google.com/codelabs/flutter/#4
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  final StreamController _usersStreamController =
      StreamController<List<User>>();
  final List<UserModel> _users = <UserModel>[];

  final StreamController _chatsStreamController =
      StreamController<List<Chat>>();
  final List<ChatModel> _chats = <ChatModel>[];

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
                                  _selectedChat = -1;
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
                              _selectedUser = -1;
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
    var post = OutgoingPostModel(
        text: text,
        userId: _service.userId,
        chatId: _selectedChat,
        status: PostStatus.UNKNOWN);

    // send message to the display stream through the bandwidth buffer
    _bandwidthBuffer.send(post);

    // async send message to the server
    _service.sendPost(post);
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
    posts.forEach((post) {
      debugPrint('new post is received ${post.text}');
      // check if post is outgoing
      var i = _posts.indexWhere((item) =>
          item.userId == _service.userId &&
          item.chatId == post.chatId &&
          item.text == post.text);
      if (i != -1) {
        // found, update status
        assert(_posts[i] is OutgoingPostModel);
        var outgoing = _posts[i] as OutgoingPostModel;
        outgoing.status = PostStatus.SENT;
      } else {
        // post is unknown
        if (post.userId != _service.userId) {
          // other's post
          _posts.insert(0, post);
        } else {
          // own post which is still unknown
          _posts.insert(0, OutgoingPostModel.from(post, PostStatus.SENT));
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
      var i = _chats.indexWhere((item) => item.id == chat.chatId);
      if (i != -1) {
        //todo: found
      } else {
        _chats.insert(0, ChatModel.from(chat));
      }
    });
  }

  void _addUsers(List<User> users) {
    users.forEach((user) {
      // check if user widget with the same ID already exists
      var i = _users.indexWhere((item) => item.id == user.userId.toInt());
      if (i != -1) {
        //todo: found
      } else {
        _users.insert(0, UserModel.from(user));
      }
    });
  }
}
