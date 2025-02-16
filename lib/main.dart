import 'package:flutter/material.dart';
import 'package:mac_desktop/chat_model.dart';
import 'package:mac_desktop/chat_screen.dart';
import 'package:mac_desktop/disk_operations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<ChatMessage>? chathistory = [];
  List<SavedChat>? savedChats = [];

  updateChatHistory(SavedChat currentChat) {
    saveChat(currentChat);
  }

  @override
  void initState() {
    super.initState();
    readLocalHistory().then((chats) {
      setState(() {
        savedChats = chats;
      });
    });
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
            title: Text('Jeyz ChatBot'),
          ),
          body: ChatScreen(),
        ));
  }
}
