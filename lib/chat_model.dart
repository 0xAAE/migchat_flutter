import 'package:flutter/material.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:migchat_flutter/user_model.dart';
import 'invitation_model.dart';

/// Message is class defining message data (id and text)
class ChatModel {
  int id = 0;
  bool permanent = false;
  String description = '';
  List<String> users = <String>[];
  List<InvitationModel> invitations = <InvitationModel>[];

  /// Class constructor
  ChatModel.from(Chat chat) {
    id = chat.chatId;
    permanent = chat.permanent;
    description = chat.description;
    for (var userId in chat.users) {
      users.add(userId.toString());
    }
  }

  invitedBy(UserModel user) {
    invitations.add(InvitationModel(from: user.shortName));
  }
}

/// ChatMessage is base abstract class for outgoing and incoming message widgets
abstract class ChatViewModel extends Widget {
  /// Message content
  ChatModel get model;

  /// Controller of animation for message widget
  AnimationController get animationController;
}
