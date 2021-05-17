import 'package:flutter/material.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:migchat_flutter/user_model.dart';
import 'package:intl/intl.dart';
import 'invitation_model.dart';
import 'chat_screen.dart';

const int NO_CHAT_ID = 0;

class ChatModel {
  int id;
  bool permanent;
  String description;
  List<int> userIds;
  List<InvitationModel> invitations;
  DateTime created;
  ResolveUserName resolveUserName;
  ResolveChatName resolveChatName;
  int historyDelayed;
  bool _viewed = false;

  /// Class constructors

  ChatModel.from(ChatUpdate update, ResolveUserName resolveUserName,
      ResolveChatName resolveChatName)
      : id = update.chat.id.toInt(),
        permanent = update.chat.permanent,
        description = update.chat.description,
        userIds = update.chat.users.map((v) => v.toInt()).toList(),
        created = DateTime.fromMillisecondsSinceEpoch(
            update.chat.created.toInt() * 1000),
        invitations = <InvitationModel>[],
        historyDelayed = update.currentlyPosts.toInt(),
        resolveUserName = resolveUserName,
        resolveChatName = resolveChatName;

  invitedBy(UserModel user) {
    invitations.add(InvitationModel(from: user.id));
  }

  bool _viewOnce() {
    if (_viewed) {
      return true;
    } else {
      _viewed = true;
      return false;
    }
  }

  String get members => userIds.map((id) => resolveUserName(id)).join(', ');

  String get name => resolveChatName(id);

  bool get viewed => _viewOnce();

  String _formatCreated() {
    final DateFormat formatter = DateFormat('dd.MM.yyyy H:mm');
    return formatter.format(created);
  }

  String get createdText => _formatCreated();
}

abstract class ChatViewModel extends Widget {
  ChatModel get model;

  /// Controller of animation for widget
  AnimationController get animationController;
}
