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
