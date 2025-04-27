// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'components/bottom_navigation_bar.dart';
import 'profile.dart';
import 'sell.dart';
import 'chat_list_page.dart';
import 'cart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detail_barang_shop.dart';
import 'services/search_service.dart';
import 'search_results_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // For BottomNavigationBar
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedCategory; // Add this for category filtering
  String _searchQuery = ''; // Add this for search filtering

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        // Index 2 is for Sell tab
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SellPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // --- Body ---
  Widget _buildBody() {
    // Return different content based on selected index
    switch (_selectedIndex) {
      case 0: // Home tab
        return _buildHomeContent();
      case 1: // Inbox tab
        return _buildInboxContent();
      case 2: // Sell tab
        return _buildSellContent();
      case 3: // Cart tab
        return _buildCartContent();
      case 4: // Profile tab
        return _buildProfileContent();
      default:
        return _buildHomeContent();
    }
  }

  // Home tab content
  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildSectionTitle('Kategori'),
              const SizedBox(height: 12),
              _buildCategories(),
              const SizedBox(height: 24),
              _buildSectionTitle('Rekomendasi Untuk anda'),
              const SizedBox(height: 12),
              _buildProductsStream(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Inbox tab content
  Widget _buildInboxContent() {
    return const ChatListPage();
  }

  // Sell tab content
  Widget _buildSellContent() {
    return SellPage();
  }

  // Cart tab content
  Widget _buildCartContent() {
    return const CartPage();
  }

  // Profile tab content
  Widget _buildProfileContent() {
    return const ProfilePage();
  }

  // --- Search Bar ---
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Pencarian',
          hintStyle: TextStyle(color: Colors.grey),
          icon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.0),
        ),
        onSubmitted: (query) {
          if (query.trim().isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchResultsPage(query: query),
              ),
            );
          }
        },
      ),
    );
  }

  // --- Section Title Helper ---
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  // --- Categories ---
  Widget _buildCategories() {
    // Use SingleChildScrollView for horizontal scrolling
    final categories = [
      {'icon': Icons.checkroom, 'label': 'Fashion'},
      {'icon': Icons.chair, 'label': 'Furniture'},
      {'icon': Icons.electrical_services, 'label': 'Elektronik'},
      {'icon': Icons.watch, 'label': 'Aksesoris'},
      {'icon': Icons.directions_run, 'label': 'Sepatu'},
      {'icon': Icons.shopping_bag, 'label': 'Tas'},
      {'icon': Icons.brush, 'label': 'Kosmetik'},
      {'icon': Icons.home, 'label': 'Perabotan'},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryItem(Icons.apps, 'Semua'),
          const SizedBox(width: 12),
          ...categories
              .map((cat) => Row(children: [
                    _buildCategoryItem(
                        cat['icon'] as IconData, cat['label'] as String),
                    const SizedBox(width: 12),
                  ]))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    final isSelected = _selectedCategory == label ||
        (_selectedCategory == null && label == 'Semua');
    return InkWell(
      onTap: () {
        setState(() {
          if (label == 'Semua') {
            _selectedCategory = null;
          } else {
            _selectedCategory = label;
          }
        });
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: 80, // Adjust width as needed
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border:
              Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
          color: isSelected ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: Colors.black54),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --- StreamBuilder for products ---
  Widget _buildProductsStream() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return const Center(
        child: Text('Silakan login untuk melihat produk'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('produk tidak ditemukan'),
          );
        }

        // First filter out current user's products
        var docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          return data != null && data['sellerId'] != currentUserId;
        }).toList();

        // Then filter by category if selected
        if (_selectedCategory != null && _selectedCategory != 'Semua') {
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data != null && data['category'] == _selectedCategory;
          }).toList();
        }

        if (docs.isEmpty) {
          return const Center(
            child: Text('produk tidak ditemukan'),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 0.7,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            if (index >= docs.length) {
              return const SizedBox.shrink();
            }

            final doc = docs[index];
            if (!doc.exists) {
              return const SizedBox.shrink();
            }

            final product = doc.data() as Map<String, dynamic>?;
            if (product == null) {
              return const SizedBox.shrink();
            }

            // Safe access to product fields with null checks
            final images = product['images'] as List<dynamic>?;
            final imageUrl =
                images?.isNotEmpty == true ? images![0].toString() : '';
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

                final userData =
                    userSnapshot.data?.data() as Map<String, dynamic>?;
                final username =
                    userData?['username']?.toString() ?? 'Unknown User';

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
        // Navigate to detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailBarangShop(
              product: {
                'images': [
                  imageUrl
                ], // Pass as array to match Cloudinary format
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
            // Image
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
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                      )
                    : const Center(
                        child:
                            Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
              ),
            ),
            // Details
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
                  // Display seller username
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
