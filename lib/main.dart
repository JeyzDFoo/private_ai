import 'package:flutter/material.dart';
import 'package:mac_desktop/chat_screen.dart'; // Add this line

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Private Ai Chat',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: ChatScreen(),
    );
  }
}
