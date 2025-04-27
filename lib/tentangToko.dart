import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TentangToko extends StatefulWidget {
  const TentangToko({Key? key}) : super(key: key);

  @override
  _TentangTokoState createState() => _TentangTokoState();
}

class _TentangTokoState extends State<TentangToko> {
  final _formKey = GlobalKey<FormState>();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _kontakController = TextEditingController();
  final _jamOperasionalController = TextEditingController();
  
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
  
  final List<String> _selectedCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('toko').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _deskripsiController.text = data['deskripsi'] ?? '';
      _lokasiController.text = data['lokasi'] ?? '';
      _kontakController.text = data['kontak'] ?? '';
      _jamOperasionalController.text = data['jamOperasional'] ?? '';
      final List<dynamic>? kategori = data['kategori'] as List<dynamic>?;
      if (kategori != null) {
        _selectedCategories.clear();
        _selectedCategories.addAll(kategori.map((e) => e.toString()));
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<String?> _getUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.data()?['username'] as String?;
  }

  Future<void> _saveData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final username = await _getUsername();
    if (username == null) return;
    await FirebaseFirestore.instance.collection('toko').doc(user.uid).set({
      'deskripsi': _deskripsiController.text.trim(),
      'lokasi': _lokasiController.text.trim(),
      'kontak': _kontakController.text.trim(),
      'jamOperasional': _jamOperasionalController.text.trim(),
      'kategori': _selectedCategories,
      'username': username,
      'uid': user.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _kontakController.dispose();
    _jamOperasionalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Toko'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _deskripsiController,
                                maxLines: 3,
                                style: const TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  labelText: 'Deskripsi Toko',
                                  labelStyle: const TextStyle(color: Colors.black54),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.description, color: Colors.black54),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Deskripsi toko harus diisi';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _lokasiController,
                                style: const TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  labelText: 'Lokasi Toko',
                                  labelStyle: const TextStyle(color: Colors.black54),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.location_on, color: Colors.black54),
                                  hintText: 'Contoh: Bandung',
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lokasi toko harus diisi';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Kategori',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: _categories.map((category) {
                                  final isSelected = _selectedCategories.contains(category);
                                  return FilterChip(
                                    label: Text(
                                      category,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    selected: isSelected,
                                    onSelected: (bool selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedCategories.add(category);
                                        } else {
                                          _selectedCategories.remove(category);
                                        }
                                      });
                                    },
                                    backgroundColor: Colors.grey[200],
                                    selectedColor: Colors.grey[800],
                                    checkmarkColor: Colors.white,
                                    showCheckmark: true,
                                  );
                                }).toList(),
                              ),
                              if (_selectedCategories.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Pilih minimal satu kategori',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _kontakController,
                                style: const TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  labelText: 'Kontak (WhatsApp/Telepon)',
                                  labelStyle: const TextStyle(color: Colors.black54),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.phone, color: Colors.black54),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Kontak harus diisi';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _jamOperasionalController,
                                style: const TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  labelText: 'Jam Operasional',
                                  labelStyle: const TextStyle(color: Colors.black54),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.access_time, color: Colors.black54),
                                  hintText: 'Contoh: Senin-Minggu, 08:00-21:00',
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Jam operasional harus diisi';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate() && _selectedCategories.isNotEmpty) {
                              await _saveData();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Data toko berhasil disimpan')),
                                );
                                Navigator.pop(context);
                              }
                            } else if (_selectedCategories.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pilih minimal satu kategori')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.black,
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
