import 'package:flutter/material.dart';

class BantuanPage extends StatelessWidget {
  const BantuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Bantuan',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFaqItem(
            question: 'Bagaimana cara menjual barang saya?',
            answer:
                'Di halaman beranda, lalu klik menu jual untuk menambahkan barang yang ingin dijual.',
          ),
          _buildFaqItem(
            question: 'Bagaimana cara membeli barang?',
            answer:
                'Cari barang melalui halaman Beranda atau kategori, klik barang yang diinginkan, lalu klik "chat penjual" dan diarahkan ke halaman chat',
          ),
          _buildFaqItem(
            question: 'Bagaimana cara menghubungi penjual?',
            answer:
                'Gunakan fitur Chat di halaman produk untuk bertanya langsung kepada penjual mengenai kondisi barang yang dijual.',
          ),
          _buildFaqItem(
            question: 'Bagaimana cara menghapus barang dari katalog saya?',
            answer:
                'Masuk ke menu "Katalog Saya", klik ikon "tempat sampah" diatas.',
          ),
          _buildFaqItem(
            question: 'Apakah saya bisa mengedit barang yang sudah diunggah?',
            answer:
                'Tentu. Masuk ke menu "Katalog Saya", klik ikon edit diatas, lalu ubah informasi barang sesuai kebutuhan Anda.',
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: const Color(0xFF11212D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ExpansionTile(
        collapsedIconColor: Colors.white,
        iconColor: Colors.white,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
