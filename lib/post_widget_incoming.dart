import 'package:flutter/material.dart';

import 'post_model.dart';

/// Incoming message author name
const String _server = "Server";

/// ChatMessageIncoming is widget to display incoming from server message
class IncomingPostWidget extends StatelessWidget implements PostViewModel {
  /// Incoming message content
  final PostModel model;

  /// Controller of animation for message widget
  final AnimationController animationController;

  /// Constructor
  IncomingPostWidget({required this.model, required this.animationController})
      : super(key: new ObjectKey(model));

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
                  Text(_server, style: Theme.of(context).textTheme.subtitle1),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text(model.text),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                  backgroundColor: Colors.pink.shade600,
                  child: Text(_server[0])),
            ),
          ],
        ),
      ),
    );
  }
}
