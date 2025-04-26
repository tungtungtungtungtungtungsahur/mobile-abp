import 'package:flutter/material.dart';
import 'cart.dart';
import 'cart_service.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
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
                          const Center(
                              child: Icon(Icons.broken_image, size: 80)),
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
                  Text(
                    'Deskripsi',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Kategori: ',
                          style: TextStyle(color: Colors.grey[700])),
                      Text(category),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Kondisi: ',
                          style: TextStyle(color: Colors.grey[700])),
                      Text(condition),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Warna: ',
                          style: TextStyle(color: Colors.grey[700])),
                      Text(color),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Add to cart logic
                  final productForCart = Map<String, dynamic>.from(product);
                  productForCart['id'] = product['productId'];
                  productForCart['sellerId'] = product['sellerId'] ?? 'unknown';
                  CartService.addToCart(productForCart);
                  Navigator.push(
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
                  elevation: 4,
                ),
                child: const Text('Keranjang'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Buy logic
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur beli coming soon!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
                child: const Text('Beli'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
