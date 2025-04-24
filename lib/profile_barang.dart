import 'package:flutter/material.dart';

class ProfileBarang extends StatefulWidget {
  const ProfileBarang({super.key});

  @override
  State<ProfileBarang> createState() => _ProfileBarangState();
}

class _ProfileBarangState extends State<ProfileBarang>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/80',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sultan Mahesa',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                '@sultanma',
                                style: TextStyle(color: Colors.grey),
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
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      'Terverifikasi',
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
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Bandung',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
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
                    const Spacer(),
                    Text(
                      'Tergabung 1 tahun',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
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
              Tab(text: 'Ulasan'),
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
                // Ulasan Tab
                const Center(child: Text('Ulasan Content')),
                // Tentang Tab
                const Center(child: Text('Tentang Content')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarangTab() {
    final List<Map<String, String>> products = [
      {
        'name': 'Navy blue vest',
        'price': 'Rp 50.000',
        'image': 'https://via.placeholder.com/150',
      },
      {
        'name': 'Kemeja kotak-kotak',
        'price': 'Rp 50.000',
        'image': 'https://via.placeholder.com/150',
      },
      {
        'name': 'Hair tonic',
        'price': 'Rp 50.000',
        'image': 'https://via.placeholder.com/150',
      },
      {
        'name': 'Sepatu Sneakers',
        'price': 'Rp 50.000',
        'image': 'https://via.placeholder.com/150',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '10 Barang',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Image.network(
                          products[index]['image']!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            products[index]['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            products[index]['price']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
