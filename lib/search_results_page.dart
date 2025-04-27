import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'components/bottom_navigation_bar.dart';
import 'services/search_service.dart';
import 'detail_barang_shop.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  int _selectedIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Hasil Pencarian: "${widget.query}"'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada produk'));
          }

          // Filter products based on search query
          final filteredDocs = SearchService.filterProducts(
            snapshot.data!.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>(),
            widget.query,
          );

          if (filteredDocs.isEmpty) {
            return const Center(
              child: Text('Tidak ada hasil pencarian'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
            ),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final product = doc.data();
              final images = product['images'] as List<dynamic>?;
              final imageUrl = images?.isNotEmpty == true ? images![0].toString() : '';
              final name = product['name']?.toString() ?? 'No Name';
              final price = product['price']?.toString() ?? '0';
              final condition = product['condition']?.toString() ?? 'Unknown';
              final sellerId = product['sellerId']?.toString() ?? '';

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(sellerId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return _buildProductCard(
                      imageUrl: imageUrl,
                      name: name,
                      price: 'Rp. $price',
                      condition: condition,
                      productId: doc.id,
                      sellerUsername: 'Loading...',
                      category: product['category']?.toString() ?? '-',
                      style: product['style']?.toString() ?? '-',
                      description: product['description']?.toString() ?? '-',
                      color: product['color']?.toString() ?? '-',
                      sellerId: sellerId,
                    );
                  }

                  final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                  final username = userData?['username']?.toString() ?? 'Unknown User';

                  return _buildProductCard(
                    imageUrl: imageUrl,
                    name: name,
                    price: 'Rp. $price',
                    condition: condition,
                    productId: doc.id,
                    sellerUsername: username,
                    category: product['category']?.toString() ?? '-',
                    style: product['style']?.toString() ?? '-',
                    description: product['description']?.toString() ?? '-',
                    color: product['color']?.toString() ?? '-',
                    sellerId: sellerId,
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildProductCard({
    required String imageUrl,
    required String name,
    required String price,
    required String condition,
    required String productId,
    required String sellerUsername,
    required String category,
    required String style,
    required String description,
    required String color,
    required String sellerId,
  }) {
    bool isNew = condition.toLowerCase() == 'new';
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailBarangShop(
              product: {
                'images': [imageUrl],
                'name': name,
                'price': price.replaceAll('Rp. ', ''),
                'condition': condition,
                'productId': productId,
                'sellerUsername': sellerUsername,
                'category': category,
                'style': style,
                'description': description,
                'color': color,
                'sellerId': sellerId,
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8.0),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: isNew ? Colors.amber : Colors.grey,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        condition,
                        style: TextStyle(
                          fontSize: 12,
                          color: isNew ? Colors.green : Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '@$sellerUsername',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 