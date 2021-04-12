import 'package:flutter/material.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:migchat_flutter/user_model.dart';
import 'invitation_model.dart';

class ChatModel {
  int id;
  bool permanent;
  String description;
  List<String> users;
  List<InvitationModel> invitations;

  /// Class constructor
  ChatModel.from(Chat chat)
      : id = chat.chatId,
        permanent = chat.permanent,
        description = chat.description,
        users = <String>[],
        invitations = <InvitationModel>[] {
    for (var userId in chat.users) {
      users.add(userId.toString());
    }
  }

  invitedBy(UserModel user) {
    invitations.add(InvitationModel(from: user.shortName));
  }

  String get members => users.join(', ');
}

abstract class ChatViewModel extends Widget {
  ChatModel get model;

  /// Controller of animation for widget
  AnimationController get animationController;
}
