// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'components/bottom_navigation_bar.dart';
import 'profile.dart';
import 'sell.dart';

// Placeholder data - replace with your actual data models and fetching logic
final List<Map<String, dynamic>> recommendedProducts = [
  {
    'image':
        'https://images.stockx.com/360/Air-Jordan-4-Retro-SB-Navy/Images/Air-Jordan-4-Retro-SB-Navy/Lv2/img01.jpg?w=576&q=57&dpr=2&updated_at=1740417865&h=384',
    'name': 'Nike Air VaporMax Evo',
    'price': 'Rp. 120.000',
    'condition': 'New',
  },
  {
    'image':
        'https://images.stockx.com/images/Supreme-MLB-Teams-Box-Logo-New-Era-Red.jpg?fit=fill&bg=FFFFFF&w=78&h=56&q=57&dpr=2&trim=color&updated_at=1744142786',
    'name': 'Supreme MLB Cap',
    'price': 'Rp. 200.000',
    'condition': 'New',
  },
  {
    'image':
        'https://id-live-01.slatic.net/p/ec4945dedfeac49e4f83ae12dabc0e44.jpg',
    'name': 'Lightstick NCT',
    'price': 'Rp. 300.000',
    'condition': 'Second',
  },
  {
    'image':
        'https://www.elektronikmurah.biz/cdn/shop/products/MCM-606-A-1x1.jpg?v=1569564711',
    'name': 'Rice cooker miyako',
    'price': 'Rp. 90.000',
    'condition': 'Second',
  },
  // Add more products...
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // For BottomNavigationBar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) { // Index 2 is for Sell tab
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
    return SingleChildScrollView(
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
            _buildRecommendationsGrid(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Inbox tab content
  Widget _buildInboxContent() {
    return const Center(child: Text('Inbox Content'));
  }

  // Sell tab content
  Widget _buildSellContent() {
    return SellPage();
  }

  // Cart tab content
  Widget _buildCartContent() {
    return const Center(child: Text('Cart Content'));
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
        color: Colors.grey[200], // Light grey background
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Pencarian',
          hintStyle: TextStyle(color: Colors.grey),
          icon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none, // Remove the default underline
          contentPadding: EdgeInsets.symmetric(vertical: 14.0),
        ),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryItem(Icons.shopping_bag_outlined, 'Shirt'),
          const SizedBox(width: 12),
          _buildCategoryItem(
            Icons.accessibility_new,
            'Pants',
          ), // Find better icon
          const SizedBox(width: 12),
          _buildCategoryItem(Icons.directions_run, 'Shoes'), // Find better icon
          const SizedBox(width: 12),
          _buildCategoryItem(Icons.watch_outlined, 'Watch'),
          // Add more categories...
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return InkWell(
      onTap: () {
        // Handle category tap
        print('Tapped category: $label');
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: 80, // Adjust width as needed
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: Colors.black54),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --- Recommendations Grid ---
  Widget _buildRecommendationsGrid() {
    return GridView.builder(
      // Important: Prevent GridView from scrolling independently inside SingleChildScrollView
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        crossAxisSpacing: 12.0, // Horizontal space between items
        mainAxisSpacing: 12.0, // Vertical space between items
        childAspectRatio: 0.7, // Adjust aspect ratio (width / height)
      ),
      itemCount: recommendedProducts.length,
      itemBuilder: (context, index) {
        final product = recommendedProducts[index];
        return _buildProductCard(
          imageUrl: product['image'],
          name: product['name'],
          price: product['price'],
          condition: product['condition'],
        );
      },
    );
  }

  Widget _buildProductCard({
    required String imageUrl,
    required String name,
    required String price,
    required String condition,
  }) {
    bool isNew = condition.toLowerCase() == 'new';
    return InkWell(
      onTap: () {
        // Handle product tap
        print('Tapped product: $name');
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
              offset: const Offset(0, 1), // changes position of shadow
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
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover, // Adjust fit as needed
                  width: double.infinity,
                  // Add error and loading builders for better UX
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
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
                      color: Colors.orange, // Or your price color
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
