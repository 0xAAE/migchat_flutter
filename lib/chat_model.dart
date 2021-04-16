import 'package:flutter/material.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:migchat_flutter/user_model.dart';
import 'invitation_model.dart';

const int NO_CHAT_ID = 0;

class ChatModel {
  int id;
  bool permanent;
  String description;
  List<String> users;
  List<InvitationModel> invitations;

  /// Class constructor
  ChatModel.from(
      Chat chat, List<UserModel> knownUsers, UserModel registeredUser)
      : id = chat.id.toInt(),
        permanent = chat.permanent,
        description = chat.description,
        users = <String>[],
        invitations = <InvitationModel>[] {
    updateUsers(chat, knownUsers, registeredUser);
  }

  void updateUsers(
      Chat chat, List<UserModel> knownUsers, UserModel registeredUser) {
    users.clear();
    for (var userId in chat.users) {
      int id = userId.toInt();
      var idx = knownUsers.indexWhere((u) => u.id == id);
      if (idx >= 0) {
        users.add(knownUsers[idx].shortName);
      } else {
        if (id == registeredUser.id) {
          users.add(registeredUser.shortName);
        } else {
          users.add(userId.toString());
        }
      }
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
