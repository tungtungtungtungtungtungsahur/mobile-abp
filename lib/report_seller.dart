import 'package:flutter/material.dart';

class ReportSellerSheet extends StatefulWidget {
  final String sellerId;
  final String reason;
  const ReportSellerSheet(
      {Key? key, required this.sellerId, required this.reason})
      : super(key: key);

  @override
  State<ReportSellerSheet> createState() => _ReportSellerSheetState();
}

class _ReportSellerSheetState extends State<ReportSellerSheet> {
  final TextEditingController _detailController = TextEditingController();
  final int _maxLength = 200;

  String? get _description {
    switch (widget.reason) {
      case 'Penipu Phishing':
        return 'Pengguna ini berpura-pura menjadi sebuah organisasi atau individu yang dipercaya, berusaha untuk mendapatkan informasi pribadi anda melalui tautan atau surel.';
      case 'Barang yang saya beli':
        return 'Laporan terkait barang yang Anda beli dari penjual ini.';
      case 'Barang terlarang':
        return 'Penjual ini menawarkan barang yang dilarang oleh hukum atau kebijakan platform.';
      case 'Salah harga':
        return 'Harga produk tidak sesuai atau menyesatkan.';
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mengapa Kamu Melaporkan Akun Ini?',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.reason,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (_description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _description!,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text('Detail',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _detailController,
                      maxLines: 5,
                      maxLength: _maxLength,
                      decoration: const InputDecoration(
                        hintText:
                            'Beri tau kami apa yang terjadi sehingga kami dapat menyelesaikan ini dengan cepat',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                        counterText: '',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '${_detailController.text.length}/$_maxLength',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _detailController.text.trim().isEmpty
                          ? null
                          : () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Terima kasih, laporan Anda telah dikirim.')),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Report'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
