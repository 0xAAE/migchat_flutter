import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';

/// Message is class defining message data (id and text)
class PostModel {
  String id = Uuid().v4();
  String text;

  PostModel(this.text) : id = Uuid().v4();
  PostModel.from(Post post) : text = post.text;
}

/// ChatMessage is base abstract class for outgoing and incoming message widgets
abstract class PostViewModel extends Widget {
  /// Message content
  PostModel get model;

  /// Controller of animation for message widget
  AnimationController get animationController;
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
      {required String text,
      required String id,
      this.status = PostStatus.UNKNOWN})
      : super(text);
}
