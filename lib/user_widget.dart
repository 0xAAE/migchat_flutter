import 'package:flutter/material.dart';

import 'user_model.dart';

/// ChatMessageIncoming is widget to display incoming from server message
class UserWidget extends StatefulWidget implements UserViewModel {
  /// Incoming message content
  final UserModel model;

  /// Controller of animation for message widget
  final AnimationController animationController;

  /// Constructor
  UserWidget({required this.model, required this.animationController})
      : super(key: new ObjectKey(model.id));

  void select(bool on) {
    onChanged!(on);
  }

  void Function(bool sel)? onChanged;

  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    widget.onChanged = (on) {
      setState(() {
        _isSelected = on;
      });
    };
    return SizeTransition(
        sizeFactor: CurvedAnimation(
            parent: widget.animationController, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: Container(
          color: _isSelected
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
                      child: Text(widget.model.name[0])),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(widget.model.shortName,
                          style: Theme.of(context).textTheme.subtitle1),
                      Container(
                        margin: EdgeInsets.only(top: 5.0),
                        child: Text(widget.model.name),
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
