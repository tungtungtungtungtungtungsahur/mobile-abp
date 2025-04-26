import 'package:flutter/material.dart';

class SellPage extends StatefulWidget {
  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedCategory;
  String? _selectedCondition;
  String? _selectedStyle;
  int _charCount = 0;
  final int _maxChars = 500;
  int _hashtagCount = 6;

  // Dummy data untuk dropdown
  final List<String> categories = [
    'Fashion',
    'Furniture',
    'Elektronik',
    'Aksesoris',
    'Sepatu',
    'Tas',
    'Kosmetik',
    'Perlengkapan Rumah',
  ];

  final List<String> conditions = ['Baru', 'Bekas', 'Baru dengan tag', 'Bekas seperti baru'];
  final List<String> styles = ['Batik', 'Casual', 'Formal', 'Sporty', 'Vintage', 'Modern', 'Minimalis', 'Other'];

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Kategori'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(categories[index]),
                  onTap: () {
                    setState(() {
                      _selectedCategory = categories[index];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showConditionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Kondisi'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: conditions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(conditions[index]),
                  onTap: () {
                    setState(() {
                      _selectedCondition = conditions[index];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showStyleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Style'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: styles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(styles[index]),
                  onTap: () {
                    setState(() {
                      _selectedStyle = styles[index];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showPriceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Masukkan Harga'),
          content: TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: 'Rp ',
              hintText: 'Masukkan harga',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_priceController.text.isNotEmpty && 
                    int.parse(_priceController.text) > 0) {
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Harga harus lebih dari 0')),
                  );
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sukses'),
          content: Text('Produk berhasil ditambahkan ke katalog'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.pushReplacementNamed(
                  context,
                  '/katalog',
                ); // Navigasi ke katalog
              },
            ),
          ],
        );
      },
    );
  }

  bool _validateInputs() {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedCondition == null ||
        _selectedStyle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon lengkapi semua data produk')),
      );
      return false;
    }
    return true;
  }

  void _handleUpload() {
    if (_validateInputs()) {
      final productData = {
        'name': _nameController.text,
        'price': _priceController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'style': _selectedStyle,
      };

      // Use productData here
      print('Uploading product: $productData');
      _showSuccessDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Jual produk', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.copy_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.folder_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Grid
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 8,
                padding: EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        index == 0
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: Colors.black54),
                                SizedBox(height: 4),
                                Text(
                                  'Tambah foto',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                            : Container(),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih hingga 8 foto',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Baca tips foto',
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 24),

            // Deskripsi
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText:
                          'Deskripsi barangmu.\n\nMulai dengan judul, lalu tambahin detail termasuk bahan, kondisi, ukuran, dan gaya.',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (text) {
                      setState(() {
                        _charCount = text.length;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hashtags: $_hashtagCount',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        '$_charCount/$_maxChars',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1),

            // List Items
            GestureDetector(
              onTap: _showCategoryDialog,
              child: _buildListItem('Category', _selectedCategory ?? 'Pilih kategori'),
            ),
            GestureDetector(
              onTap: _showStyleDialog,
              child: _buildListItem('Styles', _selectedStyle ?? 'Pilih style'),
            ),
            GestureDetector(
              onTap: _showConditionDialog,
              child: _buildListItem('Condition', _selectedCondition ?? 'Pilih kondisi'),
            ),
            GestureDetector(
              onTap: _showPriceDialog,
              child: _buildListItem('Price', _priceController.text.isEmpty ? 'Masukkan harga' : 'Rp ${_priceController.text}'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Disimpan sebagai draft')),
                  );
                },
                child: Text(
                  'Save as draft',
                  style: TextStyle(color: Colors.black),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _handleUpload,
                child: Text('Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String title, String value) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(color: Colors.grey[600]),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          visualDensity: VisualDensity.compact,
        ),
        Divider(height: 1),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
