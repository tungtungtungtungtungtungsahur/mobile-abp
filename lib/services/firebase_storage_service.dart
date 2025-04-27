import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String?> uploadImage(File imageFile) async {
    try {
      print('Starting image upload...');
      
      // Check if file exists
      if (!await imageFile.exists()) {
        print('Error: File does not exist at path: ${imageFile.path}');
        return null;
      }

      // Generate a unique filename
      String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      print('Generated filename: $fileName');
      
      // Create a reference to the location you want to upload to
      Reference ref = _storage.ref().child('product_images/$fileName');
      print('Created storage reference');
      
      // Upload the file
      print('Starting file upload...');
      UploadTask uploadTask = ref.putFile(imageFile);
      
      // Get the download URL
      print('Waiting for upload to complete...');
      TaskSnapshot taskSnapshot = await uploadTask;
      print('Upload completed, getting download URL...');
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print('Got download URL: $downloadUrl');
      
      return downloadUrl;
    } catch (e, stackTrace) {
      print('Error uploading image: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    print('Starting upload of ${imageFiles.length} images...');
    List<String> imageUrls = [];
    
    for (var imageFile in imageFiles) {
      print('Uploading image: ${imageFile.path}');
      String? imageUrl = await uploadImage(imageFile);
      if (imageUrl != null) {
        print('Successfully uploaded image, URL: $imageUrl');
        imageUrls.add(imageUrl);
      } else {
        print('Failed to upload image: ${imageFile.path}');
      }
    }
    
    print('Completed upload of ${imageUrls.length} images');
    return imageUrls;
  }
} 