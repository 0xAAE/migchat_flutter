import 'package:flutter/material.dart';
import 'chat_screen.dart';

/// main is entry point of Flutter application
void main() {
  runApp(MiGChatApp());
}

/// MiGChatApp is Flutter application
class MiGChatApp extends StatelessWidget {
  final String name = 'Alexander Avramenko';
  final String shortName = '0xAAE';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MiGChat $shortName ($name)",
      home: ChatScreen(shortName: shortName, name: name),
    );
  }
}
