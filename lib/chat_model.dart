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
  String name;
  List<ChatMessage> messages;

  SavedChat({required this.name, required this.messages});

  factory SavedChat.fromJson(Map<String, dynamic> json) {
    return SavedChat(
      name: json['name'] as String,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }
}
