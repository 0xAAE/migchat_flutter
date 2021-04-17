import 'package:flutter/material.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:migchat_flutter/user_model.dart';
import 'invitation_model.dart';
import 'chat_screen.dart';

const int NO_CHAT_ID = 0;

class ChatModel {
  int id;
  bool permanent;
  String description;
  List<int> userIds;
  List<InvitationModel> invitations;
  ResolveUserName resolveUserName;
  ResolveChatName resolveChatName;

  /// Class constructors

  // ChatModel(
  //     {required this.id,
  //     required this.permanent,
  //     required this.description,
  //     required this.resolveUserName,
  //     required this.resolveChatName})
  //     : userIds = <int>[],
  //       invitations = <InvitationModel>[];

  ChatModel.from(Chat chat, ResolveUserName resolveUserName,
      ResolveChatName resolveChatName)
      : id = chat.id.toInt(),
        permanent = chat.permanent,
        description = chat.description,
        userIds = chat.users.map((v) => v.toInt()).toList(),
        invitations = <InvitationModel>[],
        resolveUserName = resolveUserName,
        resolveChatName = resolveChatName;

  invitedBy(UserModel user) {
    invitations.add(InvitationModel(from: user.id));
  }

  String get members => userIds.map((id) => resolveUserName(id)).join(', ');

  String get name => resolveChatName(id);
}

abstract class ChatViewModel extends Widget {
  ChatModel get model;
}
