import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/completed_order.dart';

class CompletedOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'completed_orders';

  // Get completed orders for a specific user
  Stream<List<CompletedOrder>> getCompletedOrders(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('completedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CompletedOrder.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Submit ratings for a completed order
  Future<void> submitRatings(
      String orderId, int sellerRating, int productRating) async {
    await _firestore.collection(_collection).doc(orderId).update({
      'sellerRating': sellerRating,
      'productRating': productRating,
      'ratedAt': FieldValue.serverTimestamp(),
    });

    // Update the store's average rating
    final order = await _firestore.collection(_collection).doc(orderId).get();
    final storeId = order.data()?['storeId'];

    if (storeId != null) {
      final storeRef = _firestore.collection('stores').doc(storeId);
      await _firestore.runTransaction((transaction) async {
        final storeDoc = await transaction.get(storeRef);

        if (storeDoc.exists) {
          final currentRating = storeDoc.data()?['averageRating'] ?? 0.0;
          final totalRatings = storeDoc.data()?['totalRatings'] ?? 0;

          final newTotalRatings = totalRatings + 1;
          final newAverageRating =
              ((currentRating * totalRatings) + sellerRating) / newTotalRatings;

          transaction.update(storeRef, {
            'averageRating': newAverageRating,
            'totalRatings': newTotalRatings,
          });
        }
      });
    }

    // Update the product's average rating
    final productId = order.data()?['productId'];
    if (productId != null) {
      final productRef = _firestore.collection('products').doc(productId);
      await _firestore.runTransaction((transaction) async {
        final productDoc = await transaction.get(productRef);

        if (productDoc.exists) {
          final currentRating = productDoc.data()?['averageRating'] ?? 0.0;
          final totalRatings = productDoc.data()?['totalRatings'] ?? 0;

          final newTotalRatings = totalRatings + 1;
          final newAverageRating =
              ((currentRating * totalRatings) + productRating) /
                  newTotalRatings;

          transaction.update(productRef, {
            'averageRating': newAverageRating,
            'totalRatings': newTotalRatings,
          });
        }
      });
    }
  }
}
