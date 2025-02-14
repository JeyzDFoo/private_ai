import 'package:flutter/material.dart';
import 'package:mac_desktop/chat_model.dart';
import 'package:mac_desktop/chat_screen.dart'; // Add this line
import 'package:mac_desktop/saved_chat.dart'; // Add this line
import 'package:path_provider/path_provider.dart'; // Add this line
import 'dart:io'; // Add this line
import 'dart:convert'; // Add this line

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
                    saveChat(chathistory);
                  },
                  icon: Icon(Icons.save)),
              IconButton(
                  onPressed: () async {
                    List<ChatMessage> history = await fetchChatHistory();
                    updateChatHistory(history);
                  },
                  icon: Icon(Icons.refresh))
            ],
          ),
          body: ChatScreen(updateHistory: updateChatHistory)),
    );
  }

  void saveChat(List<ChatMessage> chatHistory) async {
    final directory = await getApplicationDocumentsDirectory();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final file = File('${directory.path}/chat_history_$id.json');
    final savedChat = SavedChat(
      id: id,
      name: 'Chat $id',
      chatMessages: chatHistory,
      time: DateTime.now().toIso8601String(),
    );
    await file.writeAsString(jsonEncode(savedChat.toJson()));
    print("Chat history saved to ${file.path}");
  }

  Future<List<ChatMessage>> fetchChatHistory() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/chat_history.txt');
    if (await file.exists()) {
      final chatData = await file.readAsString();
      final savedChat = SavedChat.fromJson(jsonDecode(chatData));
      return savedChat.chatMessages;
    } else {
      return [];
    }
  }
}
