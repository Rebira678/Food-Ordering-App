import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class ImageService {
  static final _picker = ImagePicker();
  static final _supabase = Supabase.instance.client;

  /// Pick an image from gallery
  static Future<File?> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  /// Upload payment screenshot to Supabase Storage
  static Future<String?> uploadPaymentScreenshot(File file) async {
    try {
      final fileName = 'payment_${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
      final path = 'payments/$fileName';
      
      await _supabase.storage.from('orders').upload(path, file);
      
      final String publicUrl = _supabase.storage.from('orders').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('❌ UPLOAD ERROR: $e');
      return null;
    }
  }

  /// Upload profile avatar
  static Future<String?> uploadAvatar(File file, String userId) async {
    try {
      final fileName = 'avatar_$userId${p.extension(file.path)}';
      final path = 'avatars/$fileName';
      
      await _supabase.storage.from('profiles').upload(
        path, 
        file,
        fileOptions: const FileOptions(upsert: true),
      );
      
      final String publicUrl = _supabase.storage.from('profiles').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('❌ AVATAR UPLOAD ERROR: $e');
      return null;
    }
  }
}
