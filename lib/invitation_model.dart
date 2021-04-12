import 'package:flutter/material.dart';

/// Message is class defining message data (id and text)
class InvitationModel {
  String from;

  /// Class constructor
  InvitationModel({required this.from});
}

/// ChatMessage is base abstract class for outgoing and incoming message widgets
abstract class InvitationViewModel extends Widget {
  /// Message content
  InvitationModel get model;

  /// Controller of animation for invitation widget
  AnimationController get animationController;
}
