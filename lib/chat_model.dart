import 'package:intl/intl.dart';

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  static Future<List<ChatMessage>> fromCSV(String data) async {
    return data.split('\n').map((message) {
      final parts = message.split(':');
      if (parts.length < 2) {
        return ChatMessage(role: 'unknown', content: 'Invalid message format');
      }
      return ChatMessage(role: parts[0], content: parts[1]);
    }).toList();
  }

  static List<ChatMessage> fromData(String chatData) {
    return chatData.split('\n').map((message) {
      final parts = message.split(':');
      if (parts.length < 2) {
        return ChatMessage(role: 'unknown', content: 'Invalid message format');
      }
      return ChatMessage(role: parts[0], content: parts[1]);
    }).toList();
  }
}

class SavedChat {
  String? uid;
  String name;
  List<ChatMessage> messages;

  SavedChat({required this.name, required this.messages, String? uid})
      : uid = uid ?? generateUID();

  factory SavedChat.fromJson(Map<String, dynamic> json) {
    return SavedChat(
      name: json['name'] as String,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      uid: json['uid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'messages': messages.map((e) => e.toJson()).toList(),
      'uid': uid,
    };
  }
}

String generateUID() {
  return DateFormat('yyyy-MMM-dd-HH-mm-ss').format(DateTime.now());
}
