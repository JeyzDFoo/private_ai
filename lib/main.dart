import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ollama/ollama.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

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
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

final serverAddress = Uri(port: 11434, host: "127.0.0.1", scheme: 'http');
int chatIndex = 0;

class ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;

  void _sendMessage(String content) async {
    if (content.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: content));
      chatIndex++;
      _isLoading = true;
    });

    _controller.clear();

    try {
      final request = http.Request(
        'POST',
        Uri.parse('http://localhost:11434/api/chat'),
      );
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'model': 'llama3.2',
        'messages': [
          {'role': 'user', 'content': content}
        ],
      });

      final response = await request.send();

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseStream = response.stream.transform(utf8.decoder);
        StringBuffer buffer = StringBuffer();

        await for (var chunk in responseStream) {
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
                print('Adding to last message: ${_messages.last.content}');
                _messages[_messages.length - 1] = ChatMessage(
                  role: 'assistant',
                  content: '${_messages.last.content} ${chatMessage.content}',
                );
              } else {
                _messages.add(chatMessage);
              }
            });
            buffer.clear();
          }
        }
        setState(() {
          _isLoading = false;
        });

        // Scroll to the bottom after a new message is added
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
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
                      ? Colors.blue[50]
                      : Colors.grey[200],
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
                    decoration: InputDecoration(
                      labelText: 'Type your message',
                      border: OutlineInputBorder(),
                    ),
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
