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
    final sellerName = sellerData['name'] ?? 'Unknown Seller';
    final sellerUsername = sellerData['username'] ?? 'unknown';
    final sellerAvatar = sellerData['avatarUrl'] ?? '';

    // Check if item already exists from the same seller
    final existingItem = await cartRef
        .where('productId', isEqualTo: product['id'])
        .where('sellerUsername', isEqualTo: sellerUsername)
        .get();

    if (existingItem.docs.isNotEmpty) {
      // Update quantity if item exists from the same seller
      await cartRef.doc(existingItem.docs.first.id).update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      // Add new item
      await cartRef.add({
        'productId': product['id'],
        'name': product['name'],
        'price': product['price'],
        'imageUrl': product['imageUrl'],
        'sellerId': product['sellerId'],
        'sellerUsername': sellerUsername,
        'seller': {
          'name': sellerName,
          'avatarUrl': sellerAvatar,
        },
        'quantity': 1,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
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

  // Update item quantity
  static Future<void> updateQuantity(String itemId, int quantity) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    if (quantity <= 0) {
      await removeFromCart(itemId);
      return;
    }

    await _firestore
        .collection('carts')
        .doc(currentUser.uid)
        .collection('items')
        .doc(itemId)
        .update({
      'quantity': quantity,
    });
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
