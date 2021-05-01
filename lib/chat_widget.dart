import 'package:flutter/material.dart';

import 'chat_model.dart';

/// ChatMessageIncoming is widget to display incoming from server message
class ChatWidget extends StatelessWidget implements ChatViewModel {
  /// Incoming message content
  final ChatModel model;

  final bool isSelected;

  final String letter;

  /// Controller of animation for message widget
  final AnimationController animationController;

  /// Constructor
  ChatWidget(
      {required this.model,
      required this.isSelected,
      required this.letter,
      required this.animationController})
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
                      backgroundColor: Colors.cyan.shade600,
                      child: Text(letter)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(model.name,
                          style: Theme.of(context).textTheme.subtitle1),
                      Container(
                        margin: EdgeInsets.only(top: 5.0),
                        child: Text(model.members),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: IconButton(
                    icon: const Icon(Icons.info_outline),
                    tooltip: "Chat was created on ${model.createdText}",
                    onPressed: () => {
                      debugPrint("Chat was created on ${model.createdText}")
                    },
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
