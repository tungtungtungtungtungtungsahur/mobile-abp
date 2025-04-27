import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatDetailPage extends StatefulWidget {
  final String receiverId;
  final String name;
  final String avatarUrl;
  final Map<String, dynamic>? productInfo;

  const ChatDetailPage({
    super.key,
    required this.receiverId,
    required this.name,
    required this.avatarUrl,
    this.productInfo,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _chatId;

  @override
  void initState() {
    super.initState();
    _getOrCreateChat();
    _markMessagesAsRead();
  }

  Future<void> _getOrCreateChat() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Create a unique chat ID by combining both user IDs and product info
    final users = [currentUser.uid, widget.receiverId]..sort();
    final productName = widget.productInfo?['name'] ?? '';
    _chatId = '${users.join('_')}_${productName.hashCode}';

    // Check if chat exists, if not create it
    final chatDoc = await _firestore.collection('chats').doc(_chatId).get();
    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(_chatId).set({
        'participants': [currentUser.uid, widget.receiverId],
        'productInfo': widget.productInfo,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final message = {
      'senderId': currentUser.uid,
      'receiverId': widget.receiverId,
      'message': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'productInfo': widget.productInfo,
    };

    // Add message to messages subcollection
    await _firestore
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .add(message);

    // Update last message in chat document
    await _firestore.collection('chats').doc(_chatId).update({
      'lastMessage': _messageController.text.trim(),
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  Future<void> _markMessagesAsRead() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final messages = await _firestore
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUser.uid)
        .where('read', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'read': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.avatarUrl),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${widget.productInfo?['sellerUsername'] ?? 'unknown'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          if (widget.productInfo != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.productInfo!['imageUrl'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 30),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productInfo!['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${widget.productInfo!['price'].toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == currentUser?.uid;
                    final timestamp = message['timestamp'] as Timestamp?;
                    final isRead = message['read'] ?? false;

                    // Check if this is the first message of the day
                    final bool showDate = index == messages.length - 1 || 
                        _isDifferentDay(
                          timestamp?.toDate(),
                          (messages[index + 1].data() as Map<String, dynamic>)['timestamp'] as Timestamp?,
                        );

                    return Column(
                      children: [
                        if (showDate)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatDate(timestamp?.toDate()),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        Align(
                          alignment:
                              isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['message'],
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      timestamp != null 
                                        ? '${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
                                        : '',
                                      style: TextStyle(
                                        color: isMe ? Colors.white70 : Colors.black54,
                                        fontSize: 10,
                                      ),
                                    ),
                                    if (isMe) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        isRead ? Icons.done_all : Icons.done,
                                        size: 14,
                                        color: isRead ? Colors.blue[100] : Colors.white70,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ketik pesan...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isDifferentDay(DateTime? date1, Timestamp? date2) {
    if (date1 == null || date2 == null) return true;
    return date1.year != date2.toDate().year ||
           date1.month != date2.toDate().month ||
           date1.day != date2.toDate().day;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);
    
    if (messageDate == today) {
      return 'Hari Ini';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Kemarin';
    } else {
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
