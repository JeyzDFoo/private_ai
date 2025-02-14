import 'package:mac_desktop/chat_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SavedChat {
  final String? id;
  final String? name;
  final List<ChatMessage> chatMessages;
  final String? time;
  final String? previousHash;

  SavedChat(
      {this.previousHash,
      String? id,
      this.name,
      required this.chatMessages,
      this.time})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory SavedChat.fromJson(Map<String, dynamic> json) {
    return SavedChat(
      id: json['id'],
      name: json['name'],
      chatMessages: (json['chatMessages'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e))
          .toList(),
      time: json['time'],
      previousHash: json['previousHash'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'chatMessages': chatMessages.map((e) => e.toJson()).toList(),
        'time': time,
        'hash': sha256
            .convert(utf8.encode(chatMessages.map((e) => e.content).join()))
            .toString(),
        'previousHash': previousHash,
      };
}
