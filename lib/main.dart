import 'package:flutter/material.dart';
import 'package:mac_desktop/chat_model.dart';
import 'package:mac_desktop/chat_screen.dart';
import 'package:path_provider/path_provider.dart'; // Add this line
import 'dart:io'; // Add this line
import 'dart:convert'; // Add this line

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  List<ChatMessage>? chathistory = [];

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
                    if (chathistory != null) {
                      saveChat(chathistory!);
                    }
                  },
                  icon: Icon(Icons.save)),
              IconButton(
                  onPressed: () async {
                    List<SavedChat> history = await readLocalHistory();
                    // Handle the loaded history as needed
                  },
                  icon: Icon(Icons.refresh))
            ],
          ),
          body: ChatScreen(updateHistory: updateChatHistory, savedChats: [])),
    );
  }

  void saveChat(List<ChatMessage> chatHistory) async {
    final directory = await getApplicationDocumentsDirectory();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final file = File('${directory.path}/chat_history_$id.json');
    final savedChat =
        SavedChat(name: 'chat_history_$id', messages: chatHistory);

    await file.writeAsString(jsonEncode(savedChat.toJson()));
    print("Chat history saved to ${file.path}");
  }

  Future<List<SavedChat>> readLocalHistory() async {
    final List<SavedChat> savedChats = [];
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();
    return Future.wait(files.map((file) async {
      if (file is File && file.path.endsWith('.json')) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          final savedChat = SavedChat.fromJson(jsonDecode(contents));
          if (savedChat != null) {
            savedChats.add(savedChat);
          }
        }
      }
    })).then((_) => savedChats);
  }
}
