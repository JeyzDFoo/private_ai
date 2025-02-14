import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mac_desktop/chat_model.dart';
import 'package:mac_desktop/chat_service.dart';
import 'package:mac_desktop/disk_operations.dart';

class ChatFlow extends StatefulWidget {
  final ScrollController scrollController;
  final SavedChat currentChat;
  final TextEditingController controller;
  final FocusNode focusNode;
  final StreamSubscription<String>? responseSubscription;
  final VoidCallback onNewChat;

  const ChatFlow({
    super.key,
    required this.scrollController,
    required this.currentChat,
    required this.controller,
    required this.focusNode,
    required this.responseSubscription,
    required this.onNewChat,
  });

  @override
  State<ChatFlow> createState() => _ChatFlowState();
}

class _ChatFlowState extends State<ChatFlow> {
  late SavedChat currentChat;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentChat = widget.currentChat;
  }

  @override
  void didUpdateWidget(ChatFlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentChat != oldWidget.currentChat) {
      setState(() {
        currentChat = widget.currentChat;
      });
    }
  }

  void _sendMessage(String content) async {
    if (content.isEmpty) return;

    setState(() {
      currentChat.messages.add(ChatMessage(role: 'user', content: content));
      isLoading = true;
    });

    widget.controller.clear();
    widget.focusNode.requestFocus();

    try {
      await sendMessageToServer(
          content, currentChat.messages, widget.scrollController,
          (chatMessage) {
        setState(() {
          if (currentChat.messages.isNotEmpty &&
              currentChat.messages.last.role == 'assistant') {
            currentChat.messages[currentChat.messages.length - 1] = ChatMessage(
              role: 'assistant',
              content:
                  '${currentChat.messages.last.content}${chatMessage.content}',
            );
          } else {
            currentChat.messages.add(chatMessage);
          }
        });

        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );

        // Save current chat
        saveChat(currentChat);
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _startNewChat() {
    setState(() {
      currentChat = SavedChat(name: 'New Chat', messages: []);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 4,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: currentChat.messages.length,
              itemBuilder: (context, index) {
                final message = currentChat.messages[index];
                return ListTile(
                  title: Text(
                    message.content,
                    textAlign: message.role == 'user'
                        ? TextAlign.right
                        : TextAlign.left,
                  ),
                  tileColor: message.role == 'user'
                      ? Colors.purple[50]
                      : Colors.blueGrey[200],
                );
              },
            ),
          ),
          if (isLoading) CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Container(
              color: Colors.grey[200],
              child: Column(
                children: [
                  TextButton(
                    onPressed: _startNewChat,
                    child: Text("New Chat"),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          focusNode: widget.focusNode,
                          decoration: InputDecoration(
                            labelText: 'Type your message',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            widget.responseSubscription?.cancel();
                          },
                          onSubmitted: (value) => _sendMessage(value),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () => _sendMessage(widget.controller.text),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
