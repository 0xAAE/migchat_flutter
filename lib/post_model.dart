import 'package:flutter/material.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';

/// Message is class defining message data (id and text)
class PostModel {
  int userId;
  int chatId;
  String text;

  PostModel({required this.userId, required this.chatId, required this.text});

  PostModel.from(Post post)
      : text = post.text,
        userId = post.userId.toInt(),
        chatId = post.chatId;
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
      : super(userId: userId, chatId: chatId, text: text);

  OutgoingPostModel.from(PostModel post, PostStatus status)
      : status = status,
        super(userId: post.userId, chatId: post.chatId, text: post.text);
}

abstract class PostViewModel extends Widget {
  /// Message content
  PostModel get model;

  /// Controller of animation for message widget
  AnimationController get animationController;
}
