import 'package:flutter/material.dart';
import 'pesananSelesai.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  //cart items dummy data
  final List<Map<String, dynamic>> cartItems = const [
    {
      'name': 'Nike Air Max Plus 3 Men\'s',
      'price': 80000,
      'image': 'images/barbek.png',
    },
    {
      'name': 'Adidas Yung White',
      'price': 160000,
      'image': 'images/barbek.png',
    },
  ];

  Set<int> selectedItems = {};
  //total price
  int get total {
    return selectedItems.fold(0, (sum, index) => sum + (cartItems[index]['price'] as num).toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //button for cart status process and done
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Diproses page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartStatusPage(status: 'Diproses'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text("Diproses"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Selesai page (putri's task, will remove later)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PesananSelesai(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text("Selesai"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                var item = cartItems[index];
                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedItems.contains(index)) {
                              selectedItems.remove(index);
                            } else {
                              selectedItems.add(index);
                            }
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedItems.contains(index) ? Colors.black : Colors.grey,
                              width: 2,
                            ),
                            color: selectedItems.contains(index) ? Colors.black : Colors.transparent,
                          ),
                          child: selectedItems.contains(index)
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.network(item['image']),
                    ],
                  ),
                  title: Text(item['name']),
                  subtitle: const Text("Fashion"),
                  trailing: Text("Rp. ${item['price'].toString()}"),
                  onTap: () {
                    setState(() {
                      if (selectedItems.contains(index)) {
                        selectedItems.remove(index);
                      } else {
                        selectedItems.add(index);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${selectedItems.length} barang'),
                    Text('Rp. $total'),
                  ],
                ),
                //button for beli (can press if there is selected item)
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: selectedItems.isEmpty ? null : () {},
                    child: const Text('Beli'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//cart status page (will move to another page -make new file later)
class CartStatusPage extends StatelessWidget {
  final String status;

  const CartStatusPage({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang - $status'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Text('Halaman $status'),
      ),
    );
  }
}
