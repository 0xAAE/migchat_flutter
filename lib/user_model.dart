import 'package:flutter/material.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:intl/intl.dart';

const String NOT_SET = "?";

/// Message is class defining message data (id and text)
class UserModel {
  int id;
  String name;
  String shortName;
  DateTime created;
  bool online;

  /// Class constructors

  UserModel(
      {required this.name,
      required this.shortName,
      required this.created,
      this.id = 0,
      this.online = false}) {
    _ensureNames();
  }

  UserModel.from(User user)
      : id = user.id.toInt(),
        name = user.name,
        shortName = user.shortName,
        created =
            DateTime.fromMillisecondsSinceEpoch(user.created.toInt() * 1000),
        online = true {
    _ensureNames();
  }

  String _formatCreated() {
    final DateFormat formatter = DateFormat('dd.MM.yyyy');
    return formatter.format(created);
  }

  String get createdText => _formatCreated();

  void _ensureNames() {
    if (name.length == 0) {
      name = id.toString();
    }
    if (shortName.length == 0) {
      shortName = NOT_SET;
    }
  }
}

/// ChatMessage is base abstract class for outgoing and incoming message widgets
abstract class UserViewModel extends Widget {
  /// Message content
  UserModel get model;

  /// Controller of animation for message widget
  AnimationController get animationController;
}
