import 'package:flutter/material.dart';

class PesananSelesai extends StatefulWidget {
  const PesananSelesai({Key? key}) : super(key: key);

  @override
  State<PesananSelesai> createState() => _PesananSelesaiState();
}

class _PesananSelesaiState extends State<PesananSelesai> {
  // Dummy order data
  final List<Map<String, dynamic>> _orders = [
    {
      'store': 'Mall ORI Watsons Indonesia Official',
      'product': 'Something Nobles Eyeshadow Palette Vol 1',
      'originalPrice': 'Rp131.000',
      'discountedPrice': 'Rp96.600',
      'totalPrice': 'Rp83.312',
      'imagePath': 'assets/eyeshadow.jpg',
      'sellerRating': null,
      'productRating': null,
    },
    {
      'store': 'Serbaaa serbuuu',
      'product': 'kalkulator DX-837B ATK-14/ Calculator 12 D...',
      'originalPrice': '',
      'discountedPrice': 'Rp21.460',
      'totalPrice': 'Rp23.460',
      'imagePath': 'assets/calculator.jpg',
      'sellerRating': null,
      'productRating': null,
    },
    {
      'store': 'Awicom Label',
      'product': '10x20 POLYMAILER Plastik Packing ukuran 1...',
      'originalPrice': 'Rp10.000',
      'discountedPrice': 'Rp6.160',
      'totalPrice': 'Rp6.820',
      'imagePath': 'assets/polymailer.jpg',
      'sellerRating': null,
      'productRating': null,
    },
    {
      'store': 'Targetolshop',
      'product': '1 pack isi 5 roll plastik sampah roll jumbo kant...',
      'originalPrice': '',
      'discountedPrice': '',
      'totalPrice': '',
      'imagePath': 'assets/trash_bag.jpg',
      'sellerRating': null,
      'productRating': null,
    },
  ];

  void _showRatingDialog(BuildContext context, int index) {
    int sellerRating = 0;
    int productRating = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Beri Nilai'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Penilaian untuk Toko: ${_orders[index]['store']}'),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(
                          i < sellerRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () {
                          setStateDialog(() {
                            sellerRating = i + 1;
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 16),
                  Text('Penilaian untuk Produk: ${_orders[index]['product']}'),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(
                          i < productRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () {
                          setStateDialog(() {
                            productRating = i + 1;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (sellerRating > 0 && productRating > 0) {
                      setState(() {
                        _orders[index]['sellerRating'] = sellerRating;
                        _orders[index]['productRating'] = productRating;
                        // Move rated order to the end
                        final ratedOrder = _orders.removeAt(index);
                        _orders.add(ratedOrder);
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Terima kasih atas penilaian Anda!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Text('Kirim'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
          'Selesai',
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
            child: ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return _buildOrderItem(context, order, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Map<String, dynamic> order, int index) {
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
                  order['store'],
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
                  child: Image.asset(order['imagePath'], fit: BoxFit.cover),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order['product']),
                      if (order['originalPrice'].isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          order['originalPrice'],
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      if (order['discountedPrice'].isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          order['discountedPrice'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                      if (order['totalPrice'].isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text('Total 1 produk: ${order['totalPrice']}'),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: order['sellerRating'] == null || order['productRating'] == null
                  ? OutlinedButton(
                      onPressed: () => _showRatingDialog(context, index),
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
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: List.generate(5, (i) => Icon(
                                i < order['productRating']
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 22,
                              )),
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
