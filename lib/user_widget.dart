import 'package:flutter/material.dart';

import 'user_model.dart';

/// ChatMessageIncoming is widget to display incoming from server message
class UserWidget extends StatefulWidget implements UserViewModel {
  /// Incoming message content
  final UserModel model;

  /// Controller of animation for message widget
  final AnimationController animationController;

  final _UserWidgetStateProxy proxy = _UserWidgetStateProxy();

  /// Constructor
  UserWidget({required this.model, required this.animationController})
      : super(key: new ObjectKey(model.id));

  void select(bool on) {
    proxy.select(on);
  }

  _UserWidgetState createState() => _UserWidgetState(proxy: proxy);
}

class _UserWidgetStateProxy {
  void Function(bool sel)? onChanged;

  void select(bool on) {
    if (onChanged != null) {
      onChanged!(on);
    }
  }
}

class _UserWidgetState extends State<UserWidget> {
  bool _isSelected = false;

  final _UserWidgetStateProxy proxy;

  _UserWidgetState({required this.proxy});

  @override
  Widget build(BuildContext context) {
    proxy.onChanged = (on) {
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
