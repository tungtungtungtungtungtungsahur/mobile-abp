import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Recreate chat database structure
  static Future<void> recreateChatDatabase() async {
    try {
      // Create chats collection if it doesn't exist
      final chatsRef = _firestore.collection('chats');
      final chatsSnapshot = await chatsRef.limit(1).get();

      if (chatsSnapshot.docs.isEmpty) {
        // Create a sample chat document
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          final sampleChatId =
              'sample_chat_${DateTime.now().millisecondsSinceEpoch}';

          // Create chat document
          await chatsRef.doc(sampleChatId).set({
            'participants': [currentUser.uid],
            'lastMessage': '',
            'lastMessageTime': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Create messages subcollection
          final messagesRef = chatsRef.doc(sampleChatId).collection('messages');
          await messagesRef.add({
            'senderId': currentUser.uid,
            'message': 'Selamat datang di chat!',
            'timestamp': FieldValue.serverTimestamp(),
            'read': true,
          });

          // Update last message
          await chatsRef.doc(sampleChatId).update({
            'lastMessage': 'Selamat datang di chat!',
            'lastMessageTime': FieldValue.serverTimestamp(),
          });
        }
      }

      print('Chat database structure recreated successfully');
    } catch (e) {
      print('Error recreating chat database: $e');
      rethrow;
    }
  }

  // Get chat messages
  static Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Send message
  static Future<void> sendMessage({
    required String chatId,
    required String message,
    required String receiverId,
    Map<String, dynamic>? productInfo,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final messageData = {
      'senderId': currentUser.uid,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'productInfo': productInfo,
    };

    // Add message to messages subcollection
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // Update last message in chat document
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUser.uid)
        .where('read', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'read': true});
    }
  }

  // Get or create chat
  static Future<String> getOrCreateChat({
    required String receiverId,
    Map<String, dynamic>? productInfo,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return '';

    // Create a unique chat ID
    final users = [currentUser.uid, receiverId]..sort();
    final productId = productInfo?['id']?.toString() ?? '';
    final productName = productInfo?['name']?.toString() ?? '';

    final chatId =
        '${users.join('_')}_${productId.isNotEmpty ? productId : productName.hashCode}';

    // Check if chat exists
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'participants': users,
        'productInfo': productInfo,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }
}
