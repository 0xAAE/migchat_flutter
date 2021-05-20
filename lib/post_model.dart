import 'package:flutter/material.dart';
import 'package:migchat_flutter/chat_model.dart';
import 'package:migchat_flutter/user_model.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:intl/intl.dart';

const int NO_POST_ID = 0;

/// Message is class defining message data (id and text)
class PostModel {
  int id;
  int userId;
  int chatId;
  String text;
  bool _viewed = false;
  DateTime created;

  bool get viewed => _viewOnce();

  PostModel(
      {required this.id,
      required this.userId,
      required this.chatId,
      required this.text,
      required this.created});

  PostModel.from(Post post)
      : text = post.text,
        userId = post.userId.toInt(),
        chatId = post.chatId.toInt(),
        id = post.id.toInt(),
        created =
            DateTime.fromMillisecondsSinceEpoch(post.created.toInt() * 1000);

  PostModel.stub()
      : chatId = NO_CHAT_ID,
        userId = NO_USER_ID,
        created = DateTime.fromMillisecondsSinceEpoch(0),
        id = NO_POST_ID,
        text = '';

  bool _viewOnce() {
    if (_viewed) {
      return true;
    } else {
      _viewed = true;
      return false;
    }
  }

  String _formatCreated() {
    final DateFormat formatter = DateFormat('dd.MM.yyyy H:mm');
    return formatter.format(created);
  }

  String get createdText => _formatCreated();

  bool get isStub => (id == NO_POST_ID) && (chatId == NO_CHAT_ID);
}

/// Outgoing message statuses
/// UNKNOWN - message just created and is not sent yet
/// SENT - message is sent to the server successfully
enum PostStatus { UNKNOWN, SENT, RETRYING }

/// MessageOutgoing is class defining message data (id and text) and status
class OutgoingPostModel extends PostModel {
  /// Outgoing message status
  PostStatus status;

  /// Constructor
  OutgoingPostModel(
      {required int userId,
      required int chatId,
      required String text,
      this.status = PostStatus.UNKNOWN})
      : super(
            id: NO_POST_ID,
            userId: userId,
            chatId: chatId,
            text: text,
            created: DateTime.now());

  OutgoingPostModel.from(PostModel post, PostStatus status)
      : status = status,
        super(
            id: post.id,
            userId: post.userId,
            chatId: post.chatId,
            text: post.text,
            created: post.created);
}

abstract class PostViewModel extends Widget {
  /// Message content
  PostModel get model;

  /// Controller of animation for message widget
  AnimationController get animationController;
}
