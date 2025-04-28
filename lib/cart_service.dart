import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user's cart items
  static Stream<List<Map<String, dynamic>>> getCartItems() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('carts')
        .doc(currentUser.uid)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList());
  }

  // Add item to cart
  static Future<void> addToCart(Map<String, dynamic> product) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final cartRef =
        _firestore.collection('carts').doc(currentUser.uid).collection('items');

    // Get seller information from users collection
    final sellerDoc =
        await _firestore.collection('users').doc(product['sellerId']).get();

    final sellerData = sellerDoc.data() ?? {};
    final sellerName =
        sellerData['name'] ?? product['sellerName'] ?? 'Unknown Seller';
    final sellerUsername =
        sellerData['username'] ?? product['sellerUsername'] ?? 'unknown';
    final sellerAvatar =
        sellerData['avatarUrl'] ?? product['sellerAvatar'] ?? '';

    // Check if item already exists from the same seller
    final existingItem = await cartRef
        .where('productId', isEqualTo: product['id'])
        .where('sellerUsername', isEqualTo: sellerUsername)
        .get();

    if (existingItem.docs.isNotEmpty) {
      // If item exists, do nothing (prevent duplicate)
      return;
    }

    // Add new item
    await cartRef.add({
      'productId': product['id'],
      'name': product['name'],
      'price': product['price'],
      'images': product['images'],
      'sellerId': product['sellerId'],
      'sellerUsername': sellerUsername,
      'seller': {
        'name': sellerName,
        'avatarUrl': sellerAvatar,
      },
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove item from cart
  static Future<void> removeFromCart(String itemId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore
        .collection('carts')
        .doc(currentUser.uid)
        .collection('items')
        .doc(itemId)
        .delete();
  }

  // Clear cart
  static Future<void> clearCart() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final batch = _firestore.batch();
    final items = await _firestore
        .collection('carts')
        .doc(currentUser.uid)
        .collection('items')
        .get();

    for (var doc in items.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
