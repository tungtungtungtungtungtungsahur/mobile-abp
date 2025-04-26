import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditDetailBarangToko extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> product;

  const EditDetailBarangToko({
    Key? key,
    required this.productId,
    required this.product,
  }) : super(key: key);

  @override
  State<EditDetailBarangToko> createState() => _EditDetailBarangTokoState();
}

class _EditDetailBarangTokoState extends State<EditDetailBarangToko> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  String? _selectedCategory;
  String? _selectedCondition;
  String? _selectedStyle;

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

  final List<String> conditions = [
    'Baru',
    'Bekas',
    'Baru dengan tag',
    'Bekas seperti baru',
  ];
  final List<String> styles = [
    'Batik',
    'Casual',
    'Formal',
    'Sporty',
    'Vintage',
    'Modern',
    'Minimalis',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing product data
    _nameController.text = widget.product['name'] ?? '';
    _priceController.text = (widget.product['price'] ?? 0).toString();
    _descriptionController.text = widget.product['description'] ?? '';
    _selectedCategory = widget.product['category'];
    _selectedCondition = widget.product['condition'];
    _selectedStyle = widget.product['style'];
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Maksimal upload 4 foto')));
      return;
    }
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar')));
    }
  }

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

  Future<void> _updateProduct() async {
    if (_validateInputs()) {
      try {
        final productData = {
          'name': _nameController.text,
          'price': int.tryParse(_priceController.text) ?? 0,
          'description': _descriptionController.text,
          'category': _selectedCategory,
          'condition': _selectedCondition,
          'style': _selectedStyle,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update(productData);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Produk berhasil diperbarui')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memperbarui produk: $e')));
      }
    }
  }

  bool _validateInputs() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Nama produk tidak boleh kosong')));
      return false;
    }
    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harga produk tidak boleh kosong')),
      );
      return false;
    }
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deskripsi produk tidak boleh kosong')),
      );
      return false;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kategori produk harus dipilih')));
      return false;
    }
    if (_selectedCondition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kondisi produk harus dipilih')));
      return false;
    }
    if (_selectedStyle == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Style produk harus dipilih')));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Produk'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _updateProduct),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Grid
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        margin: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
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
                        ),
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
            SizedBox(height: 16),
            // Product Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Price
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            // Category
            ListTile(
              title: Text('Kategori'),
              subtitle: Text(_selectedCategory ?? 'Pilih kategori'),
              trailing: Icon(Icons.arrow_drop_down),
              onTap: _showCategoryDialog,
            ),
            Divider(),
            // Condition
            ListTile(
              title: Text('Kondisi'),
              subtitle: Text(_selectedCondition ?? 'Pilih kondisi'),
              trailing: Icon(Icons.arrow_drop_down),
              onTap: _showConditionDialog,
            ),
            Divider(),
            // Style
            ListTile(
              title: Text('Style'),
              subtitle: Text(_selectedStyle ?? 'Pilih style'),
              trailing: Icon(Icons.arrow_drop_down),
              onTap: _showStyleDialog,
            ),
          ],
        ),
      ),
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
