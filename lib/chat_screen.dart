import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mac_desktop/chat_model.dart';
import 'package:mac_desktop/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final List<SavedChat> savedChats;
  final Function updateHistory;
  const ChatScreen(
      {super.key, required this.updateHistory, required this.savedChats});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  StreamSubscription<String>? _responseSubscription;

  void _sendMessage(String content) async {
    if (content.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: content));
      _isLoading = true;
    });

    _controller.clear();
    _focusNode.requestFocus();

    try {
      await sendMessageToServer(content, _messages, _scrollController,
          (chatMessage) {
        setState(() {
          if (_messages.isNotEmpty && _messages.last.role == 'assistant') {
            _messages[_messages.length - 1] = ChatMessage(
              role: 'assistant',
              content: '${_messages.last.content}${chatMessage.content}',
            );
          } else {
            _messages.add(chatMessage);
          }
        });

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadChatHistory(SavedChat savedChat) {
    setState(() {
      _messages.clear();
      _messages.addAll(savedChat.messages);
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
    widget.updateHistory(_messages);
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: widget.savedChats.length,
                  itemBuilder: (context, index) {
                    final savedChat = widget.savedChats[index];
                    return ListTile(
                      title: Text(savedChat.name),
                      onTap: () => _loadChatHistory(savedChat),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Flexible(
          flex: 4,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
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
              if (_isLoading) CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          labelText: 'Type your message',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _responseSubscription?.cancel();
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        onSubmitted: (value) => _sendMessage(value),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
