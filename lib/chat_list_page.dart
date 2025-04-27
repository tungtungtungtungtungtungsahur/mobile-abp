import 'package:flutter/material.dart';
import 'chat_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
            const Text('Pesan', style: TextStyle(fontWeight: FontWeight.bold)),
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

          return chats.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada pesan',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index].data() as Map<String, dynamic>;
                    final participants = chat['participants'] as List<dynamic>;
                    final otherUserId = participants.firstWhere(
                      (id) => id != currentUser.uid,
                      orElse: () => '',
                    ) as String;
                    if (otherUserId.isEmpty) {
                      // Skip rendering this chat if no other user found
                      return const SizedBox.shrink();
                    }

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
                        final userName = userData['name'] ?? 'Unknown User';
                        final avatarUrl = userData['avatarUrl'] ?? '';
                        final lastMessage = chat['lastMessage'] ?? '';
                        final lastMessageTime =
                            chat['lastMessageTime'] as Timestamp?;
                        final unreadCount = chat['unreadCount'] ?? 0;

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailPage(
                                  receiverId: otherUserId,
                                  name: userName,
                                  avatarUrl: avatarUrl,
                                  productInfo: chat['productInfo']
                                      as Map<String, dynamic>?,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundImage: (avatarUrl.isNotEmpty &&
                                        avatarUrl.startsWith('http'))
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                backgroundColor: Colors.grey[300],
                                child: (avatarUrl.isEmpty ||
                                        !avatarUrl.startsWith('http'))
                                    ? const Icon(Icons.person,
                                        color: Colors.white)
                                    : null,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (lastMessageTime != null)
                                    Text(
                                      _formatTimestamp(lastMessageTime),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Text(
                                lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final messageTime = timestamp.toDate();
    final difference = now.difference(messageTime);

    if (difference.inDays > 0) {
      final days = [
        'Minggu',
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu'
      ];
      return days[messageTime.weekday % 7];
    } else if (difference.inHours > 0) {
      return '${difference.inHours}j';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Baru saja';
    }
  }
}
