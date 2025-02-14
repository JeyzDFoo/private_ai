import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:mac_desktop/chat_model.dart';
import 'package:mac_desktop/disk_operations.dart';

class SavedChatsList extends StatefulWidget {
  final Function(SavedChat) loadChatHistory;
  const SavedChatsList({super.key, required this.loadChatHistory});

  @override
  State<SavedChatsList> createState() => _SavedChatsListState();
}

class _SavedChatsListState extends State<SavedChatsList> {
  final TextEditingController _titleController = TextEditingController();
  int? _selectedIndex; // Add this line

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<SavedChat>>(
            future: readLocalHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final savedChats = List<SavedChat>.from(snapshot.data ?? []);
                return ListView.builder(
                  itemCount: savedChats.length,
                  itemBuilder: (context, index) {
                    final savedChat = savedChats[index];
                    _titleController.text = savedChat.name;
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ListTile(
                        tileColor: _selectedIndex == index
                            ? Colors.blue[100]
                            : Colors.purple[50], // Modify this line
                        title: Row(
                          children: [
                            Text(savedChat.name),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _selectedIndex = index; // Add this line
                          });
                          widget.loadChatHistory(savedChat);
                        },
                        trailing: IconButton(
                            onPressed: () async {
                              await deleteChat(savedChat);
                              setState(() {
                                savedChats.remove(savedChat);
                                if (_selectedIndex == index)
                                  _selectedIndex = null; // Add this line
                              });
                            },
                            icon: HeroIcon(HeroIcons.trash)),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
