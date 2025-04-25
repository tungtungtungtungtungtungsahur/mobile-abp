import 'package:flutter/material.dart';

class PesananSelesai extends StatelessWidget {
  const PesananSelesai({Key? key}) : super(key: key);

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
          'Pesanan Saya',
          style: TextStyle(color: Colors.black),
        ),
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
          // Order list
          Expanded(
            child: ListView(
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

  Widget _buildTab(String text, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected ? Colors.red : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.red : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildOrderItem(String store, String product, String originalPrice, 
      String discountedPrice, String totalPrice, String imagePath) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  store,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Selesai',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
            SizedBox(height: 12),
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
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product),
                      if (originalPrice.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          originalPrice,
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      if (discountedPrice.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          discountedPrice,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                      if (totalPrice.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text('Total 1 produk: $totalPrice'),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {},
                child: Text(
                  'Beri Nilai',
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
