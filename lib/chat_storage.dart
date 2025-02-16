import 'package:shared_preferences/shared_preferences.dart';

class ChatStorage {
  static const String _chatKey = 'chat_messages';

  Future<void> saveChatMessages(List<String> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_chatKey, messages);
  }

  Future<List<String>?> loadChatMessages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_chatKey);
  }
}
