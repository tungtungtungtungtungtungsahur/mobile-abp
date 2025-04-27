import 'package:flutter/material.dart';
import 'cart.dart';
import 'cart_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_detail_page.dart';

class DetailBarangShop extends StatelessWidget {
  final Map<String, dynamic> product;

  const DetailBarangShop({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = product['imageUrl']?.toString() ?? '';
    final name = product['name']?.toString() ?? 'No Name';
    final price = product['price']?.toString() ?? '0';
    final description = product['description']?.toString() ?? '-';
    final condition = product['condition']?.toString() ?? '-';
    final category = product['category']?.toString() ?? '-';
    final color = product['color']?.toString() ?? '-';
    final style = product['style']?.toString() ?? '-';
    final sellerId = product['sellerId']?.toString() ?? '';
    final createdAt = product['createdAt']?.toDate() ?? DateTime.now();
    final updatedAt = product['updatedAt']?.toDate();

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: sellerId.isNotEmpty
            ? FirebaseFirestore.instance.collection('users').doc(sellerId).snapshots()
            : null,
        builder: (context, sellerSnapshot) {
          final sellerData = sellerSnapshot.data?.data() as Map<String, dynamic>?;
          final sellerName = sellerData?['name'] ?? 'Unknown Seller';
          final sellerAvatar = sellerData?['avatarUrl'] ?? '';

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      AspectRatio(
                        aspectRatio: 1,
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                        const Center(child: Icon(Icons.broken_image, size: 80)),
                              )
                            : const Center(
                                child: Icon(Icons.image_not_supported, size: 80)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp $price',
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            // Seller Information
                            if (sellerId.isNotEmpty)
                                  Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundImage: sellerAvatar.isNotEmpty
                                                ? NetworkImage(sellerAvatar)
                                                : null,
                                            backgroundColor: Colors.grey[300],
                                            child: sellerAvatar.isEmpty
                                                ? const Icon(Icons.person)
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sellerName,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '@${sellerData?['username'] ?? 'unknown'}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                  ),
                            const SizedBox(height: 16),

                            // Product Details Section
                            const Text(
                              'Detail Produk',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow('Kategori', category),
                            _buildDetailRow('Kondisi', condition),
                            _buildDetailRow('Warna', color),
                            _buildDetailRow('Style', style),
                            const SizedBox(height: 16),

                            // Description Section
                            const Text(
                              'Deskripsi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(description),
                            const SizedBox(height: 16),

                            // Product Metadata
                            const Text(
                              'Informasi Tambahan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow('Dibuat', _formatDate(createdAt)),
                            if (updatedAt != null)
                              _buildDetailRow('Diperbarui', _formatDate(updatedAt)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add to cart logic
                          final productForCart = Map<String, dynamic>.from(product);
                          productForCart['id'] = product['productId'];
                          productForCart['sellerId'] = product['sellerId'] ?? 'unknown';
                          CartService.addToCart(productForCart);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const CartPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined),
                            SizedBox(width: 8),
                            Text('Keranjang'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailPage(
                                receiverId: sellerId,
                                name: sellerName,
                                avatarUrl: sellerAvatar,
                                productInfo: {
                                  'name': name,
                                  'price': price,
                                  'imageUrl': imageUrl,
                                  'description': description,
                                  'condition': condition,
                                  'sellerName': sellerName,
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline),
                            SizedBox(width: 8),
                            Text('Chat Penjual'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
