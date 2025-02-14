import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mac_desktop/chat_model.dart';
import 'package:mac_desktop/disk_operations.dart';
import 'package:mac_desktop/saved_chats_list.dart';
import 'package:mac_desktop/chat_flow.dart'; // Add this import

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  StreamSubscription<String>? _responseSubscription;
  SavedChat currentChat = SavedChat(name: 'New Chat', messages: []);
  List<SavedChat> savedChats = [];

  void _loadChatHistory(SavedChat savedChat) {
    setState(() {
      currentChat = savedChat;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedChats();
  }

  void _loadSavedChats() async {
    final chats = await readLocalHistory();
    setState(() {
      savedChats.clear();
      savedChats.addAll(chats);
    });
  }

  @override
  void dispose() {
    _responseSubscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 350,
          child: SavedChatsList(
            loadChatHistory: _loadChatHistory,
          ),
        ),
        ChatFlow(
          scrollController: _scrollController,
          currentChat: currentChat,
          controller: _controller,
          focusNode: _focusNode,
          responseSubscription: _responseSubscription,
          onNewChat: () {
            setState(() {
              currentChat = SavedChat(name: 'New Chat', messages: []);
            });
          },
        ),
      ],
    );
  }
}
