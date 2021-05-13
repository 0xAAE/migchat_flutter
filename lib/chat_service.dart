import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:grpc/grpc.dart';

import 'proto/generated/migchat.pbgrpc.dart' as grpc;
import 'post_model.dart';

/// CHANGE TO IP ADDRESS OF YOUR SERVER IF IT IS NECESSARY
const serverIP = 'milkiway.asuscomm.com';
const serverPort = 15150;

/// ChatService client implementation
class ChatService {
  /// Flag is indicating that client is shutting down
  bool _isShutdown = false;

  /// registered user
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

  // calls handlers

  final void Function(OutgoingPostModel model) onSendPostOk;
  final void Function(OutgoingPostModel model, String error) onSendPostError;
  final void Function(grpc.Chat chat) onCreateChatOk;
  final void Function(String name, String error) onCreateChatError;

  // incoming streams handlers

  final void Function(int userId, DateTime created) onRegistered;
  final void Function(grpc.Invitation invitation) onInvitation;
  final void Function(grpc.UpdateUsers update) onUsersUpdated;
  final void Function(grpc.UpdateChats update) onChatsUpdated;
  final void Function(grpc.Post post) onPost;

  /// Event is raised when message receiving is failed
  final void Function(String error) onRecvError;

  /// Constructor
  ChatService(
      {required this.onRegistered,
      required this.onSendPostOk,
      required this.onSendPostError,
      required this.onCreateChatOk,
      required this.onCreateChatError,
      required this.onUsersUpdated,
      required this.onInvitation,
      required this.onChatsUpdated,
      required this.onPost,
      required this.onRecvError});

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
    _userId = null;
    _isShutdown = false;
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

  void register({required String shortName, required String name}) {
    if (_userId != null || _isShutdown) {
      return;
    }
    var request = grpc.UserInfo(name: name, shortName: shortName);
    grpc.ChatRoomServiceClient(_getSender()).register(request).then((response) {
      _userId = response.registration.userId;
      onRegistered(response.registration.userId.toInt(),
          DateTime.fromMillisecondsSinceEpoch(response.created.toInt()));
      _startListeningUsers();
      _startListeningInvitations();
      _startListeningChats();
      _startListeningPosts();
    }).catchError((e) {
      if (!_isShutdown) {
        _shutdownSend();
        // retry registering later
        Future.delayed(Duration(seconds: 10), () {
          if (!_isShutdown) {
            register(shortName: shortName, name: name);
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
        throw Exception('users updates stream from the server has been closed');
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
        throw Exception('invitations stream from the server has been closed');
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
        throw Exception('chats updates stream from the server has been closed');
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
            'incoming posts stream from the server has been closed');
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
      var post = grpc.Post(
          userId: _userId, chatId: Int64(model.chatId), text: model.text);
      grpc.ChatRoomServiceClient(_getSender()).createPost(post).then((_) {
        model.status = PostStatus.UNKNOWN;
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
      var request = grpc.ChatReference(chatId: Int64(chatId), userId: _userId);
      grpc.ChatRoomServiceClient(_getSender())
          .enterChat(request)
          .catchError((e) {
        if (!_isShutdown) {
          if (e is GrpcError) {
            if (e.codeName == 'ALREADY_EXISTS') {
              debugPrint('already in the chat');
            } else {
              debugPrint('failed enter chat, ${e.message}');
            }
          } else {
            Future.delayed(Duration(seconds: 30), () {
              if (!_isShutdown) {
                enterChat(chatId);
              }
            });
          }
        }
      });
    }
  }

  void createChat(String name) {
    if (_userId == null) {
      Future.delayed(Duration(seconds: 30), () {
        if (!_isShutdown) {
          createChat(name);
        }
      });
    } else {
      var request = grpc.ChatInfo(
        userId: _userId,
        autoEnter: true,
        description: name,
        permanent: true,
      );
      grpc.ChatRoomServiceClient(_getSender())
          .createChat(request)
          .then((chat) => onCreateChatOk(chat))
          .catchError((e) {
        if (!_isShutdown) {
          if (e is GrpcError) {
            debugPrint('failed to create chat, ${e.message}');
            onCreateChatError(name, e.message ?? 'failed to create chat');
          } else {
            Future.delayed(Duration(seconds: 30), () {
              if (!_isShutdown) {
                createChat(name);
              }
            });
          }
        }
      });
    }
  }

  void createDialogWith(int userId) {
    if (_userId == null) {
      Future.delayed(Duration(seconds: 30), () {
        if (!_isShutdown) {
          createDialogWith(userId);
        }
      });
    } else {
      var request = grpc.ChatInfo(
          userId: _userId,
          autoEnter: true,
          description: '', // important thing!
          permanent: false, // also important!
          desiredUsers: <Int64>[Int64(userId)]);
      grpc.ChatRoomServiceClient(_getSender())
          .createChat(request)
          .catchError((e) {
        if (!_isShutdown) {
          if (e is GrpcError) {
            debugPrint('failed create chat, ${e.message}');
          } else {
            Future.delayed(Duration(seconds: 30), () {
              if (!_isShutdown) {
                createDialogWith(userId);
              }
            });
          }
        }
      });
    }
  }
}
