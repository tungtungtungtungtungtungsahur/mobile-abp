import 'package:flutter/material.dart';
import 'chat_detail_page.dart'; // Import halaman detail chat

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Chats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...chatItems.map((chat) => _buildChatTile(chat, context)).toList(),
        ],
      ),
    );
  }

  Widget _buildChatTile(ChatItem chat, BuildContext context) {
    final isUnread = chat.unreadCount > 0;
    final fontWeight = isUnread ? FontWeight.bold : FontWeight.normal;

    return ListTile(
      leading: GestureDetector(
        onTap: () {
          _showAvatarDialog(context, chat.avatarUrl);
        },
        child: CircleAvatar(
          backgroundColor: Colors.grey[300],
          backgroundImage: NetworkImage(chat.avatarUrl),
        ),
      ),
      title: Text(chat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        chat.message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: fontWeight),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(chat.time, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: fontWeight)),
          if (isUnread)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(name: chat.name, avatarUrl: chat.avatarUrl),
          ),
        );
      },
    );
  }

  void _showAvatarDialog(BuildContext context, String avatarUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Image.network(
                    avatarUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Dummy Data
class ChatItem {
  final String name;
  final String message;
  final String time;
  final int unreadCount;
  final String avatarUrl;

  ChatItem(this.name, this.message, this.time, this.unreadCount, this.avatarUrl);
}

List<ChatItem> chatItems = [
  ChatItem('Karina', 'Minusnya dimana ya kak?', '19:45', 2, '/images/rina.jpg'),
  ChatItem('Ravi', 'Bisa nego tipis ya kak', '18:41', 0, '/images/ravi.jpg'),
  ChatItem('Archen', 'Permisi, bisa lihat kondisi realnya kak?', '17:45', 2, '/images/archen.jpg'),
  ChatItem('Kak Gem', 'kak, jual kata-kata?', '17:20', 0, '/images/gem.png'),
  ChatItem('Wildan', 'baik kak, sampai bertemu di lokasi ya', '16:31', 0, '/images/wildan.jpg'),
  ChatItem('Amiera', 'Minusnya apa ya kak?', '12:42', 2, '/images/amiera.jpg'),
  ChatItem('Denis', 'Kak, bisa dikirim ke lokasi aku ga ya?', '12:03', 0, '/images/don.png'),
];