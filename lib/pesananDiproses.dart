import 'package:flutter/material.dart';
import 'pesananSelesai.dart';

class PesananDiproses extends StatelessWidget {
  const PesananDiproses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Diproses',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.chat_bubble_outline, color: Colors.black),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '34',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PesananDiproses(),
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildOrderItem(
                  'Mall ORI Watsons Indonesia Official',
                  'Something Nobles Eyeshadow Palette Vol 1',
                  'Rp131.000',
                  'Rp96.600',
                  'Rp83.312',
                  'assets/eyeshadow.jpg',
                ),
                _buildOrderItem(
                  'Serbaaa serbuuu',
                  'kalkulator DX-837B ATK-14/ Calculator 12 D...',
                  '',
                  'Rp21.460',
                  'Rp23.460',
                  'assets/calculator.jpg',
                ),
                _buildOrderItem(
                  'Awicom Label',
                  '10x20 POLYMAILER Plastik Packing ukuran 1...',
                  'Rp10.000',
                  'Rp6.160',
                  'Rp6.820',
                  'assets/polymailer.jpg',
                ),
                _buildOrderItem(
                  'Targetolshop',
                  '1 pack isi 5 roll plastik sampah roll jumbo kant...',
                  '',
                  '',
                  '',
                  'assets/trash_bag.jpg',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String store, String product, String originalPrice, 
      String discountedPrice, String totalPrice, String imagePath) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  store,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Diproses',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product),
                      if (originalPrice.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          originalPrice,
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      if (discountedPrice.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          discountedPrice,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                      if (totalPrice.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Total 1 produk: $totalPrice'),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {},
                child: Text(
                  'Chat Penjual',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
