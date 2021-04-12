import 'package:flutter/material.dart';

import 'post_model.dart';

/// Outgoing message author name
const String _name = "Me";

/// ChatMessageOutgoingController is 'Controller' class that allows change message properties
class OutgoingPostController {
  /// Outgoing message content
  OutgoingPostModel model;

  /// Controller raises this event when status has been changed
  late void Function(PostStatus oldStatus, PostStatus newStatus)
      onStatusChanged;

  /// Constructor
  OutgoingPostController({required this.model});

  /// setStatus is method to update status of the outgoing message
  /// It raises onStatusChanged event
  void setStatus(PostStatus newStatus) {
    var oldStatus = model.status;
    if (oldStatus != newStatus) {
      model.status = newStatus;
      onStatusChanged(oldStatus, newStatus);
    }
  }
}

/// ChatMessageOutgoing is widget to display outgoing to server message
class OutgoingPostWidget extends StatefulWidget implements PostViewModel {
  /// Outgoing message content
  final OutgoingPostModel model;

  /// Message state controller
  final OutgoingPostController controller;

  /// Controller of animation for message widget
  final AnimationController animationController;

  /// Constructor
  OutgoingPostWidget({required this.model, required this.animationController})
      : controller = OutgoingPostController(model: model),
        super(key: new ObjectKey(model.id));

  @override
  State createState() => OutgoingPostState(
      animationController: animationController, controller: controller);
}

/// State for ChatMessageOutgoing widget
class OutgoingPostState extends State<OutgoingPostWidget> {
  /// Message state controller
  final OutgoingPostController controller;

  /// Controller of animation for message widget
  final AnimationController animationController;

  /// Constructor
  OutgoingPostState(
      {required this.controller, required this.animationController}) {
    // Subscribe to event "message status has been changed"
    controller.onStatusChanged = onStatusChanged;
  }

  /// Subscription to event "message status has been changed"
  void onStatusChanged(PostStatus oldStatus, PostStatus newStatus) {
    setState(() {});
  }

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
              margin: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Text(_name[0])),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_name, style: Theme.of(context).textTheme.subtitle1),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text(controller.model.text),
                  ),
                ],
              ),
            ),
            Container(
              child: Icon(controller.model.status == PostStatus.SENT
                  ? Icons.done
                  : Icons.access_time),
            ),
          ],
        ),
      ),
    );
  }
}