class CloudinaryConfig {
  static const String cloudName = 'djumqzh0w';
  static const String uploadPreset = 'mobile-abp'; // Replace with your upload preset name
  
  static String getUploadUrl() {
    return 'https://api.cloudinary.com/v1_1/$cloudName/upload';
  }
} 