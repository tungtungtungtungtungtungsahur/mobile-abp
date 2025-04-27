import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    // case insensitive (bisa kapital or not)
    final lowercaseQuery = query.toLowerCase().trim();
    
    return products.where((doc) {
      final name = doc.data()['name']?.toString().toLowerCase() ?? '';
      
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