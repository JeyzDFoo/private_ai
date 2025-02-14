import 'dart:convert';
import 'dart:io';
import 'package:mac_desktop/chat_model.dart';
import 'package:path_provider/path_provider.dart';

void saveChat(SavedChat chat) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/chat_history_${chat.uid}.json';
  final file = File(filePath);

  // Ensure the directory exists
  await file.create(recursive: true);

  await file.writeAsString(jsonEncode(chat.toJson()));
  print("Chat history saved to ${file.path}");
}

Future<List<SavedChat>> readLocalHistory() async {
  final List<SavedChat> savedChats = [];
  final directory = await getApplicationDocumentsDirectory();
  final files = directory.listSync();
  return Future.wait(files.map((file) async {
    if (file is File && file.path.endsWith('.json')) {
      final contents = await file.readAsString();
      if (contents.isNotEmpty) {
        final savedChat = SavedChat.fromJson(jsonDecode(contents));

        savedChats.add(savedChat);
      }
    }
  })).then((_) => savedChats);
}

Future<void> deleteChat(SavedChat savedchat) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/chat_history_${savedchat.uid}.json';
  final file = File(filePath);
  if (await file.exists()) {
    await file.delete();
  }
}
