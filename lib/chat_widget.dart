import 'package:flutter/material.dart';

import 'chat_model.dart';

/// ChatMessageIncoming is widget to display incoming from server message
class ChatWidget extends StatelessWidget implements ChatViewModel {
  /// Incoming message content
  final ChatModel model;

  /// Controller of animation for message widget
  final AnimationController animationController;

  /// Constructor
  ChatWidget({required this.model, required this.animationController})
      : super(key: new ObjectKey(model.id));

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                  backgroundColor: Colors.cyan.shade600,
                  child: Text(model.description[0])),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(model.description,
                      style: Theme.of(context).textTheme.subtitle1),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text(model.members),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
