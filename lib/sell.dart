import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_barang.dart'; // Make sure this import is correct
import 'services/firebase_storage_service.dart';
import 'ktp.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  bool _isLoading = true;
  bool _isKtpVerified = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  String? _selectedCategory;
  String? _selectedCondition;
  String? _selectedStyle;
  int _wordCount = 0;
  final int _maxWords = 500;

  bool _isUploading = false;

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
    'Kacamata',
    'Buku',
    'Lainnya',
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
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _checkKtpVerification();
  }

  Future<void> _checkKtpVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (mounted) {
        setState(() {
          _isKtpVerified = userDoc.data()?['ktpVerified'] ?? false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Maksimal upload 4 foto')));
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
      ).showSnackBar(const SnackBar(content: Text('Gagal memilih gambar')));
    }
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Kategori'),
          content: SizedBox(
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
          title: const Text('Pilih Kondisi'),
          content: SizedBox(
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
          title: const Text('Pilih Style'),
          content: SizedBox(
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
          title: const Text('Masukkan Harga'),
          content: TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: 'Rp ',
              hintText: 'Masukkan harga',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_priceController.text.isNotEmpty &&
                    int.parse(_priceController.text) > 0) {
                  setState(() {});
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Harga harus lebih dari 0')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Produk berhasil ditambahkan ke katalog'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushReplacementNamed(context, '/profile_barang');
              },
            ),
          ],
        );
      },
    );
  }

  bool _validateInputs() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
          const SnackBar(content: Text('Nama produk tidak boleh kosong')));
      return false;
    }
    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga produk tidak boleh kosong')),
      );
      return false;
    }
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi produk tidak boleh kosong')),
      );
      return false;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
          const SnackBar(content: Text('Kategori produk harus dipilih')));
      return false;
    }
    if (_selectedCondition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
          const SnackBar(content: Text('Kondisi produk harus dipilih')));
      return false;
    }
    if (_selectedStyle == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
          const SnackBar(content: Text('Style produk harus dipilih')));
      return false;
    }
    return true;
  }

  void _handleUpload() async {
    if (_validateInputs()) {
      setState(() { _isUploading = true; });
      _showLoadingDialog();
      // Get current user
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
        setState(() { _isUploading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus login terlebih dahulu')),
        );
        return;
      }

      // Upload images to Firebase Storage
      List<String> imageUrls = await FirebaseStorageService.uploadMultipleImages(_selectedImages);

      if (imageUrls.isEmpty) {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
        setState(() { _isUploading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengupload gambar')),
        );
        return;
      }

      final productData = {
        'name': _nameController.text,
        'price': int.tryParse(_priceController.text) ?? 0,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'condition': _selectedCondition,
        'style': _selectedStyle,
        'images': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'sellerId': user.uid,
        'sellerEmail': user.email,
      };

      try {
        await FirebaseFirestore.instance
            .collection('products')
            .add(productData);
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
        setState(() { _isUploading = false; });
        _showSuccessDialog(context);
      } catch (e) {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
        setState(() { _isUploading = false; });
        print('Error saving product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan produk: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isKtpVerified) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.badge,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Verifikasi KTP Diperlukan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Untuk dapat menjual produk, Anda perlu memverifikasi KTP terlebih dahulu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KtpPage(
                          userId: FirebaseAuth.instance.currentUser!.uid,
                          onVerificationComplete: () {
                            Navigator.pop(context);
                            _checkKtpVerification();
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Verifikasi KTP'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: const Text('Jual produk', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Grid
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length + 1,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
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
                  } else {
                    return Stack(
                      children: [
                        Container(
                          width: 120,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index - 1]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _selectedImages.removeAt(index - 1);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih hingga 4 foto',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

            // Product Name
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nama Produk',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama produk',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Deskripsi
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
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
                        _wordCount = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
                        if (_wordCount > _maxWords) {
                          final words = text.trim().split(RegExp(r'\s+'));
                          _descriptionController.text = words.take(_maxWords).join(' ');
                          _descriptionController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _descriptionController.text.length),
                          );
                          _wordCount = _maxWords;
                        }
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_wordCount/$_maxWords kata',
                        style: TextStyle(
                          color: _wordCount > _maxWords ? Colors.red : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (_wordCount > _maxWords)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Kata yang dimasukkan sudah lebih dari 500',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),

            // List Items
            GestureDetector(
              onTap: _showCategoryDialog,
              child: _buildListItem(
                'Category',
                _selectedCategory ?? 'Pilih kategori',
              ),
            ),
            GestureDetector(
              onTap: _showStyleDialog,
              child: _buildListItem('Styles', _selectedStyle ?? 'Pilih style'),
            ),
            GestureDetector(
              onTap: _showConditionDialog,
              child: _buildListItem(
                'Condition',
                _selectedCondition ?? 'Pilih kondisi',
              ),
            ),
            GestureDetector(
              onTap: _showPriceDialog,
              child: _buildListItem(
                'Price',
                _priceController.text.isEmpty
                    ? 'Masukkan harga'
                    : 'Rp ${_priceController.text}',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _handleUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Submit'),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: TextStyle(color: Colors.grey[600])),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          visualDensity: VisualDensity.compact,
        ),
        const Divider(height: 1),
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
