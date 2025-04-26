class CompletedOrder {
  final String id;
  final String storeId;
  final String storeName;
  final String productId;
  final String productName;
  final String productImage;
  final double originalPrice;
  final double discountedPrice;
  final double totalPrice;
  final DateTime completedDate;
  int? sellerRating;
  int? productRating;

  CompletedOrder({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.originalPrice,
    required this.discountedPrice,
    required this.totalPrice,
    required this.completedDate,
    this.sellerRating,
    this.productRating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeId': storeId,
      'storeName': storeName,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'totalPrice': totalPrice,
      'completedDate': completedDate.toIso8601String(),
      'sellerRating': sellerRating,
      'productRating': productRating,
    };
  }

  factory CompletedOrder.fromMap(Map<String, dynamic> map, String docId) {
    return CompletedOrder(
      id: docId,
      storeId: map['storeId'] ?? '',
      storeName: map['storeName'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      originalPrice: (map['originalPrice'] ?? 0).toDouble(),
      discountedPrice: (map['discountedPrice'] ?? 0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      completedDate: DateTime.parse(map['completedDate']),
      sellerRating: map['sellerRating'],
      productRating: map['productRating'],
    );
  }
} 