import 'package:flutter/material.dart';

class PostComposerWidget extends StatefulWidget {
  final void Function(String text) onSubmit;

  final bool enabled;

  PostComposerWidget({required this.enabled, required this.onSubmit});

  @override
  State createState() => _PostComposerState();
}

class _PostComposerState extends State<PostComposerWidget> {
  /// Look at the https://codelabs.developers.google.com/codelabs/flutter/#4
  final TextEditingController _textController = TextEditingController();

  bool _inProgress = false;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                enabled: widget.enabled,
                maxLines: null,
                textInputAction: TextInputAction.send,
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _inProgress = text.length > 0;
                  });
                },
                onSubmitted: _inProgress ? _onSubmit : null,
                decoration: InputDecoration.collapsed(hintText: 'Send a post'),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _inProgress
                      ? () => _onSubmit(_textController.text)
                      : null),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit(String text) {
    _textController.clear();
    _inProgress = false;
    widget.onSubmit(text);
  }
}
