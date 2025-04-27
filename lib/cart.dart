import 'package:flutter/material.dart';
import 'cart_service.dart';
import 'chat_detail_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isEditing = false;
  Set<String> selectedProductIds = {}; // Track selected products

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
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
              final sellerName = seller['name'] ?? 'Seller';
              final sellerAvatar = seller['avatarUrl'] ?? '';
              final totalPrice = items.fold<int>(0, (sum, item) {
                final price = int.tryParse(item['price'].toString()) ?? 0;
                final quantity = item['quantity'] ?? 1;
                return sum + (price * quantity).toInt();
              });

              final selectedTotalPrice = items.where((item) => selectedProductIds.contains(item['id']?.toString() ?? ''))
                  .fold<int>(0, (sum, item) {
                final price = int.tryParse(item['price'].toString()) ?? 0;
                final quantity = item['quantity'] ?? 1;
                return sum + (price * quantity).toInt();
              });

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 4),
                        const Spacer(),
                        Text(
                            'Rp ${selectedTotalPrice.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Product(s)
                    ...items
                        .map((item) => _buildProductCard(item, isEditing))
                        .toList(),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: selectedProductIds.isNotEmpty
                  ? () {
                      // TODO: Replace with your buy/checkout logic
                      print('Buying products: ${selectedProductIds.toList()}');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Beli'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item, bool isEditing) {
    final quantity = item['quantity'] ?? 1;
    final productId = item['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: selectedProductIds.contains(productId),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  selectedProductIds.add(productId);
                } else {
                  selectedProductIds.remove(productId);
                }
              });
            },
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item['imageUrl'] ?? '',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 60),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
