import 'package:flutter/material.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';

/// Message is class defining message data (id and text)
class UserModel {
  int id;
  String name;
  String shortName;
  bool online;

  /// Class constructors

  UserModel(
      {required this.id,
      required this.name,
      required this.shortName,
      this.online = true});

  UserModel.from(User user)
      : id = user.id.toInt(),
        name = user.name,
        shortName = user.shortName,
        online = true;
}

/// ChatMessage is base abstract class for outgoing and incoming message widgets
abstract class UserViewModel extends Widget {
  /// Message content
  UserModel get model;

  /// Controller of animation for message widget
  AnimationController get animationController;
}
