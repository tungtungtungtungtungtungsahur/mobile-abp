import 'package:flutter/material.dart';

class HapusBarangService {
  // Function to delete product
  static Future<bool> hapusBarang(BuildContext context, Map<String, String> product) async {
    try {
      // TODO: Implement actual API call to delete the product
      // For now, we'll simulate a successful deletion
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk berhasil dihapus'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      return true;
    } catch (e) {
      // Show error message if deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus produk: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      
      return false;
    }
  }
}
