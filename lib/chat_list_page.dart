import 'package:flutter/material.dart';
import 'chat_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Silakan login untuk melihat chat'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Chats', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUser.uid)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data?.docs ?? [];

          return Column(
            children: [
              Expanded(
                child: chats.isEmpty
                    ? const Center(child: Text('no message'))
                    : ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat =
                              chats[index].data() as Map<String, dynamic>;
                          final participants =
                              chat['participants'] as List<dynamic>;
                          final otherUserId = participants.firstWhere(
                            (id) => id != currentUser.uid,
                          ) as String;

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(otherUserId)
                                .get(),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData) {
                                return const ListTile(
                                  leading: CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text('Loading...'),
                                );
                              }

                              final userData = userSnapshot.data?.data()
                                      as Map<String, dynamic>? ??
                                  {};
                              final userName =
                                  userData['name'] ?? 'Unknown User';
                              final avatarUrl = userData['avatarUrl'] ?? '';

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(avatarUrl),
                                  backgroundColor: Colors.grey[300],
                                ),
                                title: Text(
                                  userName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  chat['lastMessage'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatTimestamp(chat['lastMessageTime']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatDetailPage(
                                        receiverId: otherUserId,
                                        name: userName,
                                        avatarUrl: avatarUrl,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Dummy Data
class ChatItem {
  final String name;
  final String message;
  final String time;
  final int unreadCount;
  final String avatarUrl;

  ChatItem(
      this.name, this.message, this.time, this.unreadCount, this.avatarUrl);
}

List<ChatItem> chatItems = [
  ChatItem('Karina', 'Minusnya dimana ya kak?', '19:45', 2, '/images/rina.jpg'),
  ChatItem('Ravi', 'Bisa nego tipis ya kak', '18:41', 0, '/images/ravi.jpg'),
  ChatItem('Archen', 'Permisi, bisa lihat kondisi realnya kak?', '17:45', 2,
      '/images/archen.jpg'),
  ChatItem('Kak Gem', 'kak, jual kata-kata?', '17:20', 0, '/images/gem.png'),
  ChatItem('Wildan', 'baik kak, sampai bertemu di lokasi ya', '16:31', 0,
      '/images/wildan.jpg'),
  ChatItem('Amiera', 'Minusnya apa ya kak?', '12:42', 2, '/images/amiera.jpg'),
  ChatItem('Denis', 'Kak, bisa dikirim ke lokasi aku ga ya?', '12:03', 0,
      '/images/don.png'),
];
