import 'package:flutter/material.dart';
import 'chat_screen.dart';

/// main is entry point of Flutter application
void main() {
  runApp(MiGChatApp());
}

/// MiGChatApp is Flutter application
class MiGChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MiGChat",
      home: ChatScreen(),
    );
  }
}
