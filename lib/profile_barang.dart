import 'package:flutter/material.dart';
import 'detail_barang_saya.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editDetailbarangtoko.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'report_seller.dart';

class ProfileBarang extends StatefulWidget {
  final String sellerId;
  const ProfileBarang({super.key, required this.sellerId});

  @override
  State<ProfileBarang> createState() => _ProfileBarangState();
}

class _ProfileBarangState extends State<ProfileBarang>
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
        title: const Text('Akun Saya'),
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
                    child: Text('Error: \\${snapshot.error}'),
                  );
                }
                final data = snapshot.data;
                if (data == null) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('User data not found.'),
                  );
                }
                return Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: data['profileImageUrl'] != null
                              ? NetworkImage(data['profileImageUrl'])
                              : const NetworkImage(
                                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=800&auto=format&fit=crop&q=60',
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '@${data['username'] ?? '-'}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: data['ktpVerified'] == true ? Colors.blue : Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.verified,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          data['ktpVerified'] == true ? 'Terverifikasi' : 'Belum Terverifikasi',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('toko')
                                        .doc(widget.sellerId)
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        );
                                      }
                                      final tokoData = snapshot.data?.data() as Map<String, dynamic>?;
                                      return Text(
                                        tokoData?['lokasi'] ?? '-',
                                        style: TextStyle(color: Colors.grey[600]),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Report button
                        if (FirebaseAuth.instance.currentUser?.uid !=
                            widget.sellerId)
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
                return Text('Error: \\${snapshot.error}');
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
                return Center(child: Text('Error: \\${snapshot.error}'));
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
                      final productDoc = snapshot.data?.docs[index];
                      if (productDoc != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailBarangSaya(
                              productId: productDoc.id,
                              product:
                                  productDoc.data() as Map<String, dynamic>,
                            ),
                          ),
                        );
                      }
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: (product['images'] as List<dynamic>?)
                                          ?.isNotEmpty ==
                                      true
                                  ? Image.network(
                                      (product['images'] as List<dynamic>)[0],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.error),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Icon(Icons.image_not_supported),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed:
                                          null, // Disable edit for other sellers
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
          return Center(child: Text('Error: \\${snapshot.error}'));
        }
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        if (data == null || (data['deskripsi'] ?? '').toString().isEmpty) {
          return const Center(
              child: Text('Tidak ada deskripsi terkait toko ini'));
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              if ((data['deskripsi'] ?? '').toString().isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Deskripsi'),
                  subtitle: Text(data['deskripsi'] ?? ''),
                ),
              if ((data['lokasi'] ?? '').toString().isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Lokasi'),
                  subtitle: Text(data['lokasi'] ?? ''),
                ),
              if ((data['kategori'] as List<dynamic>? ?? []).isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Kategori'),
                  subtitle:
                      Text((data['kategori'] as List<dynamic>).join(', ')),
                ),
              if ((data['kontak'] ?? '').toString().isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Kontak'),
                  subtitle: Text(data['kontak'] ?? ''),
                ),
              if ((data['jamOperasional'] ?? '').toString().isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Jam Operasional'),
                  subtitle: Text(data['jamOperasional'] ?? ''),
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
          decoration: BoxDecoration(
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
