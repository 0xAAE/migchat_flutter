import 'package:flutter/material.dart';

import 'user_model.dart';

/// ChatMessageIncoming is widget to display incoming from server message
class UserWidget extends StatelessWidget implements UserViewModel {
  /// Incoming message content
  UserModel model;

  /// Controller of animation for message widget
  final AnimationController animationController;

  /// Constructor
  UserWidget({required this.model, required this.animationController})
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(model.shortName,
                      style: Theme.of(context).textTheme.subtitle1),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text(model.name),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                  backgroundColor: Colors.blueGrey.shade600,
                  child: Text(model.name[0])),
            ),
          ],
        ),
      ),
    );
  }
}
