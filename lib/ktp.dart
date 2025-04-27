import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'services/auth_service.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class KtpPage extends StatefulWidget {
  final String userId;
  final VoidCallback onVerificationComplete;
  
  const KtpPage({
    super.key,
    required this.userId,
    required this.onVerificationComplete,
  });

  @override
  _KtpPageState createState() => _KtpPageState();
}

class _KtpPageState extends State<KtpPage> {
  File? _ktpImage;
  bool _isLoading = false;
  bool _isSubmitted = false;
  final _authService = AuthService();
  final _textRecognizer = TextRecognizer();

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<bool> _isValidKtp(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Convert text to lowercase for case-insensitive matching
      final text = recognizedText.text.toLowerCase();
      
      // Check for common KTP text patterns
      final ktpKeywords = [
        'nik',
        'nama',
        'tempat/tgl lahir',
        'jenis kelamin',
        'alamat',
        'rt/rw',
        'kel/desa',
        'kecamatan',
        'agama',
        'status perkawinan',
        'pekerjaan',
        'kewarganegaraan',
        'berlaku hingga'
      ];

      // Count how many KTP keywords are found
      int matches = 0;
      for (final keyword in ktpKeywords) {
        if (text.contains(keyword.toLowerCase())) {
          matches++;
        }
      }

      // Consider it a valid KTP if at least 5 keywords are found
      return matches >= 5;
    } catch (e) {
      print('Error in KTP validation: $e');
      return false;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _ktpImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_ktpImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih gambar KTP terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate if the image is actually a KTP
      final isValid = await _isValidKtp(_ktpImage!);
      
      if (!isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gambar yang diunggah bukan KTP yang valid'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // Update KTP verification status in Firestore
      await _authService.updateKtpVerification(widget.userId, true);

      if (mounted) {
        setState(() {
          _isSubmitted = true;
        });
        widget.onVerificationComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Upload KTP Anda',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Preview Image
              Container(
                width: screenWidth,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _ktpImage == null
                    ? const Center(
                        child: Text(
                          'Belum ada gambar',
                          style: TextStyle(color: Colors.black45),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          _ktpImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Button Pilih Gambar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: _pickImage,
                  child: const Text(
                    'Pilih Gambar',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Pesan Berhasil
              if (_isSubmitted) ...[
                const Text(
                  'KTP berhasil dimasukkan',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Button Kirim
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Kirim',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
