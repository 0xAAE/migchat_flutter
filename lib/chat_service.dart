import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:grpc/grpc.dart';

import 'proto/generated/migchat.pbgrpc.dart' as grpc;
import 'post_model.dart';

/// CHANGE TO IP ADDRESS OF YOUR SERVER IF IT IS NECESSARY
const serverIP = "127.0.0.1";
const serverPort = 50051;

/// ChatService client implementation
class ChatService {
  /// Flag is indicating that client is shutting down
  bool _isShutdown = false;

  /// registered user_id
  Int64? _userId;

  /// gRPC client channel to send messages to the server
  ClientChannel? _clientSend;

  /// gRPC client channel to receive messages from the server
  ClientChannel? _postsRecv;

  /// gRPC client channel to receive invitations from the server
  ClientChannel? _invitationsRecv;

  /// gRPC client channel to receive users from the server
  ClientChannel? _usersRecv;

  /// gRPC client channel to receive chats from the server
  ClientChannel? _chatsRecv;

  // send methods

  final void Function(OutgoingPostModel model) onSendPostOk;
  final void Function(OutgoingPostModel model, String error) onSendPostError;

  // receive streams methods

  final void Function(grpc.Invitation invitation) onInvitation;
  final void Function(grpc.UpdateUsers update) onUsersUpdated;
  final void Function(grpc.UpdateChats update) onChatsUpdated;
  final void Function(grpc.Post post) onPost;

  /// Event is raised when message receiving is failed
  final void Function(String error) onRecvError;

  /// Constructor
  ChatService(
      {required this.onSendPostOk,
      required this.onSendPostError,
      required this.onUsersUpdated,
      required this.onInvitation,
      required this.onChatsUpdated,
      required this.onPost,
      required this.onRecvError,
      required String shortName,
      required String name}) {
    _register(shortName: shortName, name: name);
    _startListeningUsers();
    _startListeningInvitations();
    _startListeningChats();
    _startListeningPosts();
  }

  ClientChannel _getSender() {
    if (_clientSend == null) {
      _clientSend = ClientChannel(
        serverIP, // Your IP here or localhost
        port: serverPort,
        options: ChannelOptions(
          //TODO: Change to secure with server certificates
          credentials: ChannelCredentials.insecure(),
          idleTimeout: Duration(seconds: 10),
        ),
      );
    }
    return _clientSend!;
  }

  ClientChannel _getInvitationsListener() {
    if (_invitationsRecv == null) {
      // create new client
      _invitationsRecv = ClientChannel(
        serverIP, // Your IP here or localhost
        port: serverPort,
        options: ChannelOptions(
          //TODO: Change to secure with server certificates
          credentials: ChannelCredentials.insecure(),
          idleTimeout: Duration(seconds: 10),
        ),
      );
    }
    assert(_invitationsRecv != null);
    return _invitationsRecv!;
  }

  ClientChannel _getChatsListener() {
    if (_chatsRecv == null) {
      // create new client
      _chatsRecv = ClientChannel(
        serverIP, // Your IP here or localhost
        port: serverPort,
        options: ChannelOptions(
          //TODO: Change to secure with server certificates
          credentials: ChannelCredentials.insecure(),
          idleTimeout: Duration(seconds: 10),
        ),
      );
    }
    assert(_chatsRecv != null);
    return _chatsRecv!;
  }

  ClientChannel _getUsersListener() {
    if (_usersRecv == null) {
      // create new client
      _usersRecv = ClientChannel(
        serverIP, // Your IP here or localhost
        port: serverPort,
        options: ChannelOptions(
          //TODO: Change to secure with server certificates
          credentials: ChannelCredentials.insecure(),
          idleTimeout: Duration(seconds: 10),
        ),
      );
    }
    assert(_usersRecv != null);
    return _usersRecv!;
  }

  ClientChannel _getPostsListener() {
    if (_postsRecv == null) {
      // create new client
      _postsRecv = ClientChannel(
        serverIP, // Your IP here or localhost
        port: serverPort,
        options: ChannelOptions(
          //TODO: Change to secure with server certificates
          credentials: ChannelCredentials.insecure(),
          idleTimeout: Duration(seconds: 10),
        ),
      );
    }
    assert(_postsRecv != null);
    return _postsRecv!;
  }

  // Shutdown client
  Future<void> shutdown() async {
    if (_userId != null) {
      grpc.ChatRoomServiceClient(_getSender())
          .logout(grpc.Registration(userId: _userId))
          .then((_) {
        debugPrint('successfully logged out from the server');
      }).catchError((e) {
        debugPrint('failed to logout from the server');
      });
    }
    _isShutdown = true;
    _shutdownSend();
    _shutdownPosts();
    _shutdownChats();
    _shutdownUsers();
    _shutdownInvitations();
  }

  void _restart(int secs, void Function() func) {
    Future.delayed(Duration(seconds: secs), () {
      if (!_isShutdown) {
        func();
      }
    });
  }

  // Shutdown client (send channel)
  void _shutdownSend() {
    if (_clientSend != null) {
      _clientSend?.shutdown();
      _clientSend = null;
    }
  }

  void _shutdownPosts() {
    if (_postsRecv != null) {
      _postsRecv?.shutdown();
      _postsRecv = null;
    }
  }

  void _shutdownUsers() {
    if (_usersRecv != null) {
      _usersRecv?.shutdown();
      _usersRecv = null;
    }
  }

  void _shutdownChats() {
    if (_chatsRecv != null) {
      _chatsRecv?.shutdown();
      _chatsRecv = null;
    }
  }

  void _shutdownInvitations() {
    if (_invitationsRecv != null) {
      _invitationsRecv?.shutdown();
      _invitationsRecv = null;
    }
  }

  void _register({required String shortName, required String name}) {
    if (_userId != null || _isShutdown) {
      return;
    }
    var request = grpc.UserInfo(name: name, shortName: shortName);
    grpc.ChatRoomServiceClient(_getSender()).register(request).then((response) {
      _userId = response.userId;
    }).catchError((e) {
      if (!_isShutdown) {
        _shutdownSend();
        // retry registering later
        Future.delayed(Duration(seconds: 10), () {
          if (!_isShutdown) {
            _register(shortName: shortName, name: name);
          }
        });
      }
    });
  }

  void _startListeningUsers() {
    if (_userId == null) {
      // wait until registered
      _restart(30, _startListeningUsers);
    } else {
      var stream = grpc.ChatRoomServiceClient(_getUsersListener())
          .getUsers(grpc.Registration(userId: _userId));
      stream.forEach((update) {
        onUsersUpdated(update);
      }).then((_) {
        // raise exception to start listening again
        throw Exception("users updates stream from the server has been closed");
      }).catchError((e) {
        if (!_isShutdown) {
          _shutdownUsers();
          onRecvError(e.toString());
          // start listening again
          _restart(30, _startListeningUsers);
        }
      });
    }
  }

  void _startListeningInvitations() {
    if (_userId == null) {
      // wait until registered
      _restart(30, _startListeningInvitations);
    } else {
      var stream = grpc.ChatRoomServiceClient(_getInvitationsListener())
          .getInvitations(grpc.Registration(userId: _userId));
      stream.forEach((invitation) {
        onInvitation(invitation);
      }).then((_) {
        // raise exception to start listening again
        throw Exception("invitations stream from the server has been closed");
      }).catchError((e) {
        if (!_isShutdown) {
          _shutdownInvitations();
          onRecvError(e.toString());
          // start listening again
          _restart(30, _startListeningInvitations);
        }
      });
    }
  }

  void _startListeningChats() {
    if (_userId == null) {
      // wait until registered
      _restart(30, _startListeningChats);
    } else {
      var stream = grpc.ChatRoomServiceClient(_getChatsListener())
          .getChats(grpc.Registration(userId: _userId));
      stream.forEach((update) {
        onChatsUpdated(update);
      }).then((_) {
        // raise exception to start listening again
        throw Exception("chats updates stream from the server has been closed");
      }).catchError((e) {
        if (!_isShutdown) {
          _shutdownChats();
          onRecvError(e.toString());
          // start listening again
          _restart(30, _startListeningChats);
        }
      });
    }
  }

  void _startListeningPosts() {
    if (_userId == null) {
      // wait until registered
      _restart(30, _startListeningPosts);
    } else {
      var stream = grpc.ChatRoomServiceClient(_getPostsListener())
          .getPosts(grpc.Registration(userId: _userId));
      stream.forEach((post) {
        onPost(post);
      }).then((_) {
        // raise exception to start listening again
        throw Exception(
            "incoming posts stream from the server has been closed");
      }).catchError((e) {
        if (!_isShutdown) {
          _shutdownPosts();
          onRecvError(e.toString());
          // start listening again
          _restart(30, _startListeningPosts);
        }
      });
    }
  }

  /// Send message to the server
  void sendPost(OutgoingPostModel model) {
    if (_userId == null) {
      Future.delayed(Duration(seconds: 30), () {
        if (!_isShutdown) {
          sendPost(model);
        }
      });
    } else {
      var post = grpc.Post(userId: _userId, chatId: 0, text: model.text);
      grpc.ChatRoomServiceClient(_getSender()).createPost(post).then((_) {
        model.status = PostStatus.SENT;
        onSendPostOk(model);
      }).catchError((e) {
        if (!_isShutdown) {
          model.status = PostStatus.RETRYING;
          onSendPostError(model, e.toString());
          Future.delayed(Duration(seconds: 30), () {
            if (!_isShutdown) {
              sendPost(model);
            }
          });
        }
      });
    }
  }

  void enterChat(int chatId) {
    if (_userId == null) {
      Future.delayed(Duration(seconds: 30), () {
        if (!_isShutdown) {
          enterChat(chatId);
        }
      });
    } else {
      var ref = grpc.ChatReference(chatId: chatId, userId: _userId);
      grpc.ChatRoomServiceClient(_getSender()).enterChat(ref).catchError((e) {
        if (!_isShutdown) {
          Future.delayed(Duration(seconds: 30), () {
            if (!_isShutdown) {
              enterChat(chatId);
            }
          });
        }
      });
    }
  }
}
