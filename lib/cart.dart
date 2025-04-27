import 'package:flutter/material.dart';
import 'cart_service.dart';
import 'chat_detail_page.dart';
import 'dart:io';
import 'cart_done.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Edit/Selesai button at the top right
          Padding(
            padding: const EdgeInsets.only(top: 24, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      isEditing = !isEditing;
                    });
                  },
                  child: Text(
                    isEditing ? 'Selesai' : 'Edit',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          // Cart content
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: CartService.getCartItems(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(child: Text('Keranjang kosong'));
                }

                // Group by sellerUsername
                final Map<String, List<Map<String, dynamic>>> grouped = {};
                for (var item in items) {
                  final sellerUsername = item['sellerUsername'] ?? 'unknown';
                  grouped.putIfAbsent(sellerUsername, () => []).add(item);
                }

                return ListView.separated(
                  itemCount: grouped.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (context, groupIndex) {
                    final sellerUsername = grouped.keys.elementAt(groupIndex);
                    final items = grouped[sellerUsername]!;
                    final seller = items.first['seller'] ?? {};
                    final sellerName = (seller['name'] ?? 'Seller').toString();
                    final sellerAvatar = (seller['avatarUrl'] ?? '').toString();
                    final sellerId = (items.first['sellerId'] ?? '').toString();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Seller Info
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: sellerAvatar.isNotEmpty
                                      ? NetworkImage(sellerAvatar)
                                      : null,
                                  child: sellerAvatar.isEmpty
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text(sellerName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Product(s)
                            ...items
                                .map((item) =>
                                    _buildProductCard(item, isEditing))
                                .toList(),
                            const SizedBox(height: 12),
                            // Chat and Complete buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatDetailPage(
                                          receiverId: sellerId,
                                          name: sellerName,
                                          avatarUrl: sellerAvatar,
                                          productInfo: {
                                            'id': items.first['productId'] ??
                                                items.first['id'],
                                            'name': items.first['name'],
                                            'price': items.first['price'],
                                            'images': items.first['images'],
                                            'description':
                                                items.first['description'] ??
                                                    '',
                                            'condition':
                                                items.first['condition'] ?? '',
                                            'sellerName': sellerName,
                                            'sellerUsername': sellerUsername,
                                            'sellerId': sellerId,
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                    side: const BorderSide(color: Colors.black),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Chat penjual'),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () async {
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      for (var item in items) {
                                        // Remove from cart
                                        await CartService.removeFromCart(
                                            item['id']);
                                        // Add to cart_done
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user.uid)
                                            .collection('cart_done')
                                            .add(item);
                                      }
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CartDonePage()),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Selesai'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item, bool isEditing) {
    final quantity = item['quantity'] ?? 1;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (item['images'] as List<dynamic>?)?.isNotEmpty == true
                ? item['images'][0].toString().startsWith('http')
                    ? Image.network(
                        item['images'][0].toString(),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 60),
                      )
                    : Image.file(
                        File(item['images'][0]
                            .toString()
                            .replaceAll('file://', '')),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 60),
                      )
                : const Icon(Icons.broken_image, size: 60),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Rp ${item['price']}',
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 8),
                  Text('Jumlah: $quantity',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.blue)),
                  if (isEditing)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            CartService.removeFromCart(item['id']);
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            CartService.updateQuantity(
                                item['id'], quantity - 1);
                          },
                        ),
                        Text('$quantity'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            CartService.updateQuantity(
                                item['id'], quantity + 1);
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
