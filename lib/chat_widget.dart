import 'package:flutter/material.dart';

import 'chat_model.dart';

/// ChatMessageIncoming is widget to display incoming from server message
class ChatWidget extends StatefulWidget implements ChatViewModel {
  /// Incoming message content
  final ChatModel model;

  /// Controller of animation for message widget
  final AnimationController animationController;

  /// Constructor
  ChatWidget({required this.model, required this.animationController})
      : super(key: new ObjectKey(model.id));

  void Function(bool sel)? onChanged;

  void select(bool on) {
    if (onChanged != null) {
      onChanged!(on);
    }
  }

  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
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
                      backgroundColor: Colors.cyan.shade600,
                      child: Text(widget.model.description[0])),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(widget.model.description,
                          style: Theme.of(context).textTheme.subtitle1),
                      Container(
                        margin: EdgeInsets.only(top: 5.0),
                        child: Text(widget.model.members),
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
