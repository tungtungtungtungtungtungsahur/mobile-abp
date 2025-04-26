import 'package:flutter/material.dart';

class EditDetailBarangToko extends StatefulWidget {
  final Map<String, String> product;

  const EditDetailBarangToko({Key? key, required this.product}) : super(key: key);

  @override
  State<EditDetailBarangToko> createState() => _EditDetailBarangTokoState();
}

class _EditDetailBarangTokoState extends State<EditDetailBarangToko> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  int _charCount = 26;
  final int _maxChars = 500;
  int _hashtagCount = 6;
  
  String _selectedCategory = 'Chelsea boots';
  String _selectedStyle = 'Casual';
  String _selectedCondition = 'Baru dengan tag';
  String _selectedPrice = 'Rp 80.000';

  final List<String> _categories = [
    'Fashion',
    'Furniture',
    'Elektronik',
    'Aksesoris',
    'Sepatu',
    'Tas',
    'Kosmetik',
    'Perlengkapan Rumah',
  ];

  final List<String> _conditions = [
    'Baru',
    'Bekas',
    'Baru dengan tag',
    'Bekas seperti baru',
  ];

  final List<String> _styles = [
    'Batik',
    'Casual',
    'Formal',
    'Sporty',
    'Vintage',
    'Modern',
    'Minimalis',
    'Other',
  ];

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
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_categories[index]),
                  onTap: () {
                    setState(() {
                      _selectedCategory = _categories[index];
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
              itemCount: _conditions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_conditions[index]),
                  onTap: () {
                    setState(() {
                      _selectedCondition = _conditions[index];
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
              itemCount: _styles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_styles[index]),
                  onTap: () {
                    setState(() {
                      _selectedStyle = _styles[index];
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
    _priceController.text = _selectedPrice.replaceAll('Rp ', '');
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
                  setState(() {
                    _selectedPrice = 'Rp ${_priceController.text}';
                  });
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

  @override
  void initState() {
    super.initState();
    _descriptionController.text = 'ajakajjskskensebdbsbsnsnsj';
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
        title: Text('Edit produk', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
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
                    child: index == 0
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.black54),
                              SizedBox(height: 4),
                              Text('Tambah foto',
                                  style: TextStyle(color: Colors.black54, fontSize: 12)),
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
                  Text('Klik dan tarik untuk ngubah posisi',
                      style: TextStyle(color: Colors.black54, fontSize: 12)),
                  TextButton(
                    onPressed: () {},
                    child: Text('Baca tips foto',
                        style: TextStyle(color: Colors.blue[700], fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 24),

            // Description
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    decoration: InputDecoration(
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
              child: _buildListItem('Category', _selectedCategory),
            ),
            GestureDetector(
              onTap: _showStyleDialog,
              child: _buildListItem('Styles', _selectedStyle),
            ),
            GestureDetector(
              onTap: _showConditionDialog,
              child: _buildListItem('Condition', _selectedCondition),
            ),
            GestureDetector(
              onTap: _showPriceDialog,
              child: _buildListItem('Price', _selectedPrice),
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
                onPressed: () {},
                child: Text('Move to drafts', 
                  style: TextStyle(color: Colors.black)
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Perubahan berhasil disimpan'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
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
          title: Text(title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  style: TextStyle(color: Colors.grey[600])),
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
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
