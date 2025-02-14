import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mac_desktop/chat_model.dart';

Future<Stream<String>?> sendMessageToServer(List<ChatMessage> messages) async {
  try {
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
      'model': 'llama3.2',
      'messages': messageList,
    });

    final response = await request.send();

    if (response.statusCode == 200) {
      return response.stream.transform(utf8.decoder);
    } else {
      print('Failed to get response from server: ${response.statusCode}');
      return null;
    }
  } on SocketException catch (e) {
    print('SocketException: $e');
    return null;
  } on http.ClientException catch (e) {
    print('ClientException: $e');
    return null;
  } on FormatException catch (e) {
    print('FormatException: $e');
    return null;
  } catch (e) {
    print('Unexpected error: $e');
    return null;
  }
}
