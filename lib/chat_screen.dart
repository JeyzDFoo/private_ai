import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

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

    setState(() {
      _isLoading = false;
    });

    try {
      final request = http.Request(
        'POST',
        Uri.parse('http://localhost:11434/api/chat'),
      );
      request.headers['Content-Type'] = 'application/json';

      // Include the previous messages in the request body
      final messages = _messages
          .map((msg) => {
                'role': msg.role,
                'content': msg.content,
              })
          .toList();

      request.body = jsonEncode({
        'model': 'llama3.2', //'deepseek-r1:1.5b',
        'messages': messages,
      });

      final response = await request.send();

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseStream = response.stream.transform(utf8.decoder);
        StringBuffer buffer = StringBuffer();

        _responseSubscription = responseStream.listen((chunk) {
          buffer.write(chunk);
          final decodedChunk = jsonDecode(buffer.toString());
          if (decodedChunk is Map) {
            final chatMessage = ChatMessage(
              role: decodedChunk['message']['role'],
              content: decodedChunk['message']['content'],
            );
            print('role: ${chatMessage.role}, content: ${chatMessage.content}');
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

            buffer.clear();
          }
        }, onDone: () {
          setState(() {
            _isLoading = false;
          });

          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      } else {
        print('Failed to get response from server: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      setState(() {
        _isLoading = false;
      });
      return;
    } on http.ClientException catch (e) {
      print('ClientException: $e');
      setState(() {
        _isLoading = false;
      });
      return;
    } on FormatException catch (e) {
      print('FormatException: $e');
      setState(() {
        _isLoading = false;
      });
      return;
    } catch (e) {
      print('Unexpected error: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Private Chat'),
      ),
      body: Column(
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
    );
  }
}

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});
}
