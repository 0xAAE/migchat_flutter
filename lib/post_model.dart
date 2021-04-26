import 'package:flutter/material.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';

/// Message is class defining message data (id and text)
class PostModel {
  int id;
  int userId;
  int chatId;
  String text;
  bool _viewed = false;

  bool get viewed => _viewOnce();

  PostModel(
      {required this.id,
      required this.userId,
      required this.chatId,
      required this.text});

  PostModel.from(Post post)
      : text = post.text,
        userId = post.userId.toInt(),
        chatId = post.chatId.toInt(),
        id = post.id.toInt();

  bool _viewOnce() {
    if (_viewed) {
      return true;
    } else {
      _viewed = true;
      return false;
    }
  }
}

/// Outgoing message statuses
/// UNKNOWN - message just created and is not sent yet
/// SENT - message is sent to the server successfully
enum PostStatus { UNKNOWN, SENT, RETRYING }

const int NO_POST_ID = 0;

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
      : super(id: NO_POST_ID, userId: userId, chatId: chatId, text: text);

  OutgoingPostModel.from(PostModel post, PostStatus status)
      : status = status,
        super(
            id: post.id,
            userId: post.userId,
            chatId: post.chatId,
            text: post.text);
}

abstract class PostViewModel extends Widget {
  /// Message content
  PostModel get model;

  /// Controller of animation for message widget
  AnimationController get animationController;
}
