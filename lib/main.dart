import 'package:flutter/material.dart';
import 'package:mac_desktop/chat_screen.dart'; // Add this line

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  List<ChatMessage> chathistory = [];

  updateChatHistory(List<ChatMessage> messages) {
    chathistory = messages;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Private Ai Chat',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text('My Ai'),
            actions: [
              IconButton(
                  onPressed: () {
                    saveChat();
                  },
                  icon: Icon(Icons.save))
            ],
          ),
          body: ChatScreen(updateHistory: updateChatHistory)),
    );
  }

  void saveChat() {}
}
