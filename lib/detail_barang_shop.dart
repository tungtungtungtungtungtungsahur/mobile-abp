import 'package:flutter/material.dart';
import 'cart.dart';
import 'cart_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_detail_page.dart';
import 'dart:io';
import 'profile_barang.dart';
import 'visit_seller_shop.dart';

class DetailBarangShop extends StatefulWidget {
  final Map<String, dynamic> product;

  const DetailBarangShop({Key? key, required this.product}) : super(key: key);

  @override
  State<DetailBarangShop> createState() => _DetailBarangShopState();
}

class _DetailBarangShopState extends State<DetailBarangShop> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.product['images'] as List<dynamic>?;
    final name = widget.product['name']?.toString() ?? 'No Name';
    final price = widget.product['price']?.toString() ?? '0';
    final description = widget.product['description']?.toString() ?? '-';
    final condition = widget.product['condition']?.toString() ?? '-';
    final category = widget.product['category']?.toString() ?? '-';
    final color = widget.product['color']?.toString() ?? '-';
    final style = widget.product['style']?.toString() ?? '-';
    final sellerId = widget.product['sellerId']?.toString() ?? '';
    final createdAt = widget.product['createdAt']?.toDate() ?? DateTime.now();
    final updatedAt = widget.product['updatedAt']?.toDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: sellerId.isNotEmpty
            ? FirebaseFirestore.instance
                .collection('users')
                .doc(sellerId)
                .snapshots()
            : null,
        builder: (context, sellerSnapshot) {
          final sellerData =
              sellerSnapshot.data?.data() as Map<String, dynamic>?;
          final sellerName = sellerData?['name'] ?? 'Unknown Seller';
          final sellerUsername = sellerData?['username'] ?? 'unknown';
          final sellerAvatar = sellerData?['avatarUrl'] ?? '';

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image Gallery
                      AspectRatio(
                        aspectRatio: 1,
                        child: (images?.length ?? 0) > 0
                            ? Stack(
                                children: [
                                  // Main Image
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          child: Stack(
                                            children: [
                                              images![_currentImageIndex]
                                                      .toString()
                                                      .startsWith('http')
                                                  ? Image.network(
                                                      images![_currentImageIndex]
                                                          .toString(),
                                                      fit: BoxFit.contain,
                                                    )
                                                  : Image.file(
                                                      File(images![_currentImageIndex]
                                                          .toString()
                                                          .replaceAll('file://', '')),
                                                      fit: BoxFit.contain,
                                                    ),
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: IconButton(
                                                  icon: const Icon(Icons.close),
                                                  onPressed: () => Navigator.pop(context),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    child: images![_currentImageIndex]
                                            .toString()
                                            .startsWith('http')
                                        ? Image.network(
                                            images![_currentImageIndex].toString(),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Center(
                                                        child: Icon(
                                                            Icons.broken_image,
                                                            size: 80)),
                                          )
                                        : Image.file(
                                            File(images![_currentImageIndex]
                                                .toString()
                                                .replaceAll('file://', '')),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Center(
                                                        child: Icon(
                                                            Icons.broken_image,
                                                            size: 80)),
                                          ),
                                  ),
                                  // Image Gallery Indicator
                                  if (images.length > 1)
                                    Positioned(
                                      bottom: 16,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          images.length,
                                          (index) => Container(
                                            width: 8,
                                            height: 8,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: index == _currentImageIndex
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : const Center(
                                child:
                                    Icon(Icons.image_not_supported, size: 80)),
                      ),
                      // Image Thumbnails
                      if ((images?.length ?? 0) > 1)
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images?.length ?? 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _currentImageIndex = index;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _currentImageIndex == index
                                            ? Colors.orange
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: images![index]
                                              .toString()
                                              .startsWith('http')
                                          ? Image.network(
                                              images![index].toString(),
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(Icons.broken_image,
                                                      size: 40),
                                            )
                                          : Image.file(
                                              File(images![index]
                                                  .toString()
                                                  .replaceAll('file://', '')),
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(Icons.broken_image,
                                                      size: 40),
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Seller Profile Box
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VisitSellerShop(sellerId: sellerId),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundImage: sellerAvatar.isNotEmpty
                                          ? NetworkImage(sellerAvatar)
                                          : null,
                                      backgroundColor: Colors.grey[300],
                                      child: sellerAvatar.isEmpty
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sellerName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '@$sellerUsername',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                            _buildDetailRow('Style', style),
                            const SizedBox(height: 16),
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
                          final productForCart =
                              Map<String, dynamic>.from(widget.product);
                          productForCart['id'] = productForCart['productId'];
                          productForCart['sellerId'] =
                              productForCart['sellerId'] ?? 'unknown';
                          productForCart['sellerName'] = sellerName;
                          productForCart['sellerAvatar'] = sellerAvatar;
                          CartService.addToCart(productForCart);
                          Navigator.pushReplacementNamed(
                            context,
                            '/home',
                            arguments: {'selectedIndex': 3},
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
                                  'images': images ?? [],
                                  'description': description,
                                  'condition': condition,
                                  'sellerName': sellerName,
                                  'sellerUsername': sellerUsername,
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
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
