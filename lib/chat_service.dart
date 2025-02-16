import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mac_desktop/chat_model.dart';

Future<void> sendMessageToServer(
  String content,
  List<ChatMessage> messages,
  ScrollController scrollController,
  Function(ChatMessage) onMessageReceived,
) async {
  final request = http.Request(
    'POST',
    Uri.parse('http://localhost:11434/api/chat'),
  );
  request.headers['Content-Type'] = 'application/json';

  final messageList = messages
      .map((msg) => {
            'role': msg.role,
            'content': msg.content,
          })
      .toList();

  request.body = jsonEncode({
    'model': "deepseek-r1:8b", //'llama3.2',
    'messages': messageList,
  });

  final response = await request.send();

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
        onMessageReceived(chatMessage);
        buffer.clear();
      }
    }
  } else {
    throw Exception(
        'Failed to get response from server: ${response.statusCode}');
  }
}
