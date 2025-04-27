import 'package:flutter/material.dart';
import 'detail_barang_shop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'report_seller.dart';

class VisitSellerShop extends StatefulWidget {
  final String sellerId;
  const VisitSellerShop({super.key, required this.sellerId});

  @override
  State<VisitSellerShop> createState() => _VisitSellerShopState();
}

class _VisitSellerShopState extends State<VisitSellerShop>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _userDataFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.sellerId)
        .get();
    return doc.data();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Profile Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _userDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final data = snapshot.data;
                if (data == null) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('Data toko tidak ditemukan.'),
                  );
                }
                return Column(
                  children: [
                    // Profile Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: data['avatarUrl'] != null
                              ? NetworkImage(data['avatarUrl'])
                              : null,
                          child: data['avatarUrl'] == null
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'] ?? 'Toko',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${data['username'] ?? 'unknown'}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    data['location'] ?? 'Indonesia',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Report button
                        IconButton(
                          icon: const Icon(Icons.warning_amber_rounded,
                              color: Colors.black, size: 32),
                          tooltip: 'Laporkan Penjual',
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                return _buildReportSheet(context);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Rating
                    Row(
                      children: [
                        const Text(
                          '5.0 ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (index) => const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        const Text(
                          ' (100)',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: const [
              Tab(text: 'Barang'),
              Tab(text: 'Tentang'),
            ],
          ),
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Barang Tab
                _buildBarangTab(),
                // Tentang Tab
                _buildTentangTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarangTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('sellerId', isEqualTo: widget.sellerId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final products = snapshot.data?.docs ?? [];
              return Text(
                '${products.length} Barang',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('sellerId', isEqualTo: widget.sellerId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final products = snapshot.data?.docs ?? [];
              if (products.isEmpty) {
                return const Center(
                  child: Text('Belum ada barang yang dijual'),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product =
                      products[index].data() as Map<String, dynamic>;
                  final images = product['images'] as List<dynamic>?;
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailBarangShop(
                            product: {
                              ...product,
                              'productId': products[index].id,
                            },
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
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
                                top: Radius.circular(8),
                              ),
                              child: images?.isNotEmpty == true
                                  ? Image.network(
                                      images![0].toString(),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${product['price'] ?? 0}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  Widget _buildTentangTab() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('toko')
          .doc(widget.sellerId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        if (data == null || (data['deskripsi'] ?? '').toString().isEmpty) {
          return const Center(
              child: Text('Tidak ada deskripsi terkait toko ini'));
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tentang Toko',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data['deskripsi'] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportSheet(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.6,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Mengapa Kamu Melaporkan Akun Ini?',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const Divider(height: 1, thickness: 1),
              _buildReportReason(context, 'Penipu Phishing'),
              _buildReportReason(context, 'Barang yang saya beli'),
              _buildReportReason(context, 'Barang terlarang'),
              _buildReportReason(context, 'Salah harga'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportReason(BuildContext context, String reason) {
    return ListTile(
      title: Text(reason),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ReportSellerSheet(
            sellerId: widget.sellerId,
            reason: reason,
          ),
        );
      },
    );
  }
}
