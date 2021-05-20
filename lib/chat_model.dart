import 'dart:math';

import 'package:flutter/material.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:migchat_flutter/user_model.dart';
import 'package:intl/intl.dart';
import 'invitation_model.dart';
import 'post_model.dart';

const int NO_CHAT_ID = 0;
const int HISTORY_PAGE_LENGTH = 10;

typedef void HistoryLoadedCallback(List<PostModel> posts);

abstract class ChatServiceProvider {
  String resolveUserName(int userId);
  String resolveChatName(int chatId);
  void loadChatHistory(
      int chatId, int idxFrom, int count, HistoryLoadedCallback handler);
  int get registeredUserId;
}

class ChatModel {
  int id;
  bool permanent;
  String description;
  List<int> userIds;
  List<InvitationModel> invitations;
  DateTime created;
  int historyAvailable;
  int historyInProgress = 0;
  bool _viewed = false;
  final List<PostModel> _posts = <PostModel>[];
  final ChatServiceProvider service;

  /// Class constructors

  ChatModel.from(ChatUpdate update, ChatServiceProvider service)
      : id = update.chat.id.toInt(),
        permanent = update.chat.permanent,
        description = update.chat.description,
        userIds = update.chat.users.map((v) => v.toInt()).toList(),
        created = DateTime.fromMillisecondsSinceEpoch(
            update.chat.created.toInt() * 1000),
        invitations = <InvitationModel>[],
        historyAvailable = update.currentlyPosts.toInt(),
        service = service;

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

  String get members =>
      userIds.map((id) => service.resolveUserName(id)).join(', ');

  String get name => service.resolveChatName(id);

  bool get viewed => _viewOnce();

  String _formatCreated() {
    final DateFormat formatter = DateFormat('dd.MM.yyyy H:mm');
    return formatter.format(created);
  }

  String get createdText => _formatCreated();

  int get totalPosts => _posts.length + historyAvailable + historyInProgress;

  void addOldPost(PostModel post) {
    switch (post.runtimeType) {
      case OutgoingPostModel:
        _posts.add(post);
        break;
      default:
        if (post.userId == service.registeredUserId) {
          _posts.add(OutgoingPostModel.from(post, PostStatus.SENT));
        } else {
          _posts.add(post);
        }
        break;
    }
  }

  void insertNewPost(PostModel post) {
    switch (post.runtimeType) {
      case OutgoingPostModel:
        _posts.insert(0, post);
        break;
      default:
        if (post.userId == service.registeredUserId) {
          _posts.insert(0, OutgoingPostModel.from(post, PostStatus.SENT));
        } else {
          _posts.insert(0, post);
        }
        break;
    }
  }

  static const int NOT_FOUND = -1;

  int findPost(bool Function(PostModel) pred) {
    return _posts.indexWhere((p) => pred(p));
  }

  void onHistoryLoaded(List<PostModel> loaded) {
    var length = loaded.length;
    assert(historyInProgress == length);
    historyInProgress = 0;
    debugPrint('$name: $length posts were loaded');
    for (var p in loaded.reversed) {
      addOldPost(p);
    }
    debugPrint(
        '$name: $historyAvailable older posts are still available to fetch');
  }

  PostModel getPost(int idx) {
    var max = totalPosts;
    if (idx >= max) {
      throw RangeError.range(idx, 0, max - 1);
    }
    if (idx > _posts.length - HISTORY_PAGE_LENGTH && historyAvailable > 0) {
      var toLoad = min(HISTORY_PAGE_LENGTH, historyAvailable);
      debugPrint(
          '$name: loading $toLoad most recent old posts ($historyAvailable is available)');
      var idxFrom = historyAvailable - toLoad;
      historyInProgress = toLoad;
      service.loadChatHistory(
          id, idxFrom, HISTORY_PAGE_LENGTH, onHistoryLoaded);
      historyAvailable = idxFrom;
    }
    if (idx >= _posts.length) {
      return PostModel.from(Post(text: "post is not loaded yet..."));
    }
    return _posts[idx];
  }
}

abstract class ChatViewModel extends Widget {
  ChatModel get model;

  /// Controller of animation for widget
  AnimationController get animationController;
}
