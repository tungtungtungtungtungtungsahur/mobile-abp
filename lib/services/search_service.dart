import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // search product by name
  static Stream<List<Map<String, dynamic>>> searchProducts(String query) {
    if (query.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList());
  }

  // Filter products by product name
  static List<QueryDocumentSnapshot<Map<String, dynamic>>> filterProducts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> products,
    String query,
  ) {
    if (query.isEmpty) {
      return products;
    }

    // Get current user ID
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return [];
    }

    // Convert both query and product names to lowercase for case-insensitive comparison
    final lowercaseQuery = query.toLowerCase().trim();
    
    return products.where((doc) {
      final product = doc.data();
      final sellerId = product['sellerId']?.toString();
      
      // Skip if this is the current user's product
      if (sellerId == currentUserId) {
        return false;
      }

      final name = product['name']?.toString().toLowerCase() ?? '';
      
      // split kata2 di search dan product name
      final productWords = name.split(' ');
      final queryWords = lowercaseQuery.split(' ');
      
      // ngecheck apakah kata di search ada di product name
      return queryWords.every((queryWord) => 
        productWords.any((productWord) => productWord.contains(queryWord))
      );
    }).toList();
  }
} 