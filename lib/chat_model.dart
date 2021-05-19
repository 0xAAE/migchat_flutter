import 'dart:math';

import 'package:flutter/material.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:migchat_flutter/user_model.dart';
import 'package:intl/intl.dart';
import 'invitation_model.dart';
import 'chat_screen.dart';
import 'post_model.dart';

const int NO_CHAT_ID = 0;
const int HISTORY_PAGE_LENGTH = 10;

class ChatModel {
  int id;
  bool permanent;
  String description;
  List<int> userIds;
  List<InvitationModel> invitations;
  DateTime created;
  ResolveUserName resolveUserName;
  ResolveChatName resolveChatName;
  HistoryLoader historyLoader;
  int historyDelayed;
  bool _viewed = false;
  final List<PostModel> posts = <PostModel>[];

  /// Class constructors

  ChatModel.from(ChatUpdate update, ResolveUserName resolveUserName,
      ResolveChatName resolveChatName, HistoryLoader historyLoader)
      : id = update.chat.id.toInt(),
        permanent = update.chat.permanent,
        description = update.chat.description,
        userIds = update.chat.users.map((v) => v.toInt()).toList(),
        created = DateTime.fromMillisecondsSinceEpoch(
            update.chat.created.toInt() * 1000),
        invitations = <InvitationModel>[],
        historyDelayed = update.currentlyPosts.toInt(),
        resolveUserName = resolveUserName,
        resolveChatName = resolveChatName,
        historyLoader = historyLoader;

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

  append(PostModel post) {
    posts.insert(0, post);
  }

  int get totalPosts => posts.length + historyDelayed;

  PostModel getPost(int idx) {
    var max = totalPosts;
    if (idx >= max) {
      throw RangeError.range(idx, 0, max - 1);
    }
    if (idx > posts.length - HISTORY_PAGE_LENGTH && historyDelayed > 0) {
      var toLoad = min(HISTORY_PAGE_LENGTH, historyDelayed);
      debugPrint(
          '$name: loading $toLoad most recent old posts ($historyDelayed is available)');
      var loaded =
          historyLoader(id, historyDelayed - toLoad, HISTORY_PAGE_LENGTH);
      var length = loaded.length;
      assert(toLoad == length);
      debugPrint('$name: $length posts were loaded');
      posts.addAll(loaded);
      if (historyDelayed > length) {
        historyDelayed -= length;
        if (historyDelayed > 0) {
          debugPrint('$name: $historyDelayed older posts are unreceived yet');
        }
      } else {
        debugPrint(
            '$name: loaded length $length exceeds expected $historyDelayed');
        historyDelayed = 0;
      }
    }
    assert(idx < posts.length);
    return posts[idx];
  }
}

abstract class ChatViewModel extends Widget {
  ChatModel get model;

  /// Controller of animation for widget
  AnimationController get animationController;
}
