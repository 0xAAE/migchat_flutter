import 'package:flutter/material.dart';

import 'user_model.dart';

/// ChatMessageIncoming is widget to display incoming from server message
class UserWidget extends StatelessWidget implements UserViewModel {
  /// Incoming message content
  final UserModel model;

  /// Controller of animation for message widget
  final AnimationController animationController;

  final bool isSelected;

  /// Constructor
  UserWidget(
      {required this.model,
      required this.animationController,
      required this.isSelected})
      : super(key: new ObjectKey(model.id));

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        sizeFactor:
            CurvedAnimation(parent: animationController, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: Container(
          color: isSelected
              ? Theme.of(context).highlightColor
              : Theme.of(context).canvasColor,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                      backgroundColor: Colors.blueGrey.shade600,
                      child: Text(model.name[0])),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
              ],
            ),
          ),
        ));
  }
}
