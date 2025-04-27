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

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Kategori', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ..._categories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(category),
                  activeColor: Colors.grey[700],
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Selesai'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationDialog() {
    final controller = TextEditingController(text: _lokasiController.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Lokasi Toko'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Contoh: Bandung'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _lokasiController.text = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showJamOperasionalDialog() {
    final controller = TextEditingController(text: _jamOperasionalController.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Jam Operasional'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Contoh: Senin-Minggu, 08:00-21:00'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _jamOperasionalController.text = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showKontakDialog() {
    final controller = TextEditingController(text: _kontakController.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kontak (WhatsApp/Telepon)'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'No. WhatsApp/Telepon'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _kontakController.text = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Biodata Toko', style: TextStyle(color: Colors.black)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _deskripsiController,
                            maxLines: 3,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              hintText: 'Deskripsi toko',
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    const SizedBox(height: 32),
                    // ListTile-style for Lokasi
                    ListTile(
                      title: const Text('Lokasi', style: TextStyle(fontSize: 16)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _lokasiController.text.isEmpty ? 'Pilih lokasi' : _lokasiController.text,
                            style: TextStyle(
                              color: _lokasiController.text.isEmpty ? Colors.grey[400] : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      onTap: _showLocationDialog,
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 32),
                    // ListTile-style for Kategori
                    ListTile(
                      title: const Text('Kategori', style: TextStyle(fontSize: 16)),
                      subtitle: _selectedCategories.isEmpty
                          ? Text('Pilih kategori', style: TextStyle(color: Colors.grey[400], fontSize: 15))
                          : Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Wrap(
                                spacing: 4.0,
                                runSpacing: 8.0,
                                children: _selectedCategories.map((category) => Chip(
                                  label: Text(
                                    category,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  backgroundColor: Colors.grey[700],
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                )).toList(),
                              ),
                            ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: _showCategoryBottomSheet,
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 32),
                    // ListTile-style for Jam Operasional
                    ListTile(
                      title: const Text('Jam Operasional', style: TextStyle(fontSize: 16)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _jamOperasionalController.text.isEmpty ? 'Pilih jam' : _jamOperasionalController.text,
                            style: TextStyle(
                              color: _jamOperasionalController.text.isEmpty ? Colors.grey[400] : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      onTap: _showJamOperasionalDialog,
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 32),
                    // ListTile-style for Kontak
                    ListTile(
                      title: const Text('Kontak', style: TextStyle(fontSize: 16)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _kontakController.text.isEmpty ? 'Pilih kontak' : _kontakController.text,
                            style: TextStyle(
                              color: _kontakController.text.isEmpty ? Colors.grey[400] : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      onTap: _showKontakDialog,
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate() &&
                                _selectedCategories.isNotEmpty &&
                                _lokasiController.text.isNotEmpty &&
                                _jamOperasionalController.text.isNotEmpty) {
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
                            } else if (_lokasiController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Lokasi toko harus diisi')),
                              );
                            } else if (_jamOperasionalController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Jam operasional harus diisi')),
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
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
