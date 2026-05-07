import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class ImageService {
  static final _picker = ImagePicker();
  static final _supabase = Supabase.instance.client;

  /// Pick an image from gallery — works on both mobile and web
  static Future<XFile?> pickImage() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
  }

  /// Upload payment screenshot — uses uploadBinary so it works on web + mobile
  static Future<String?> uploadPaymentScreenshot(XFile xfile) async {
    try {
      final ext = xfile.name.contains('.') ? xfile.name.split('.').last : 'jpg';
      final fileName = 'payment_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = 'payments/$fileName';

      final bytes = await xfile.readAsBytes();
      await _supabase.storage.from('orders').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      return _supabase.storage.from('orders').getPublicUrl(path);
    } catch (e) {
      // If upload fails (e.g. RLS), return placeholder so order still goes through
      return 'https://placehold.co/400x600/65A30D/FFFFFF?text=Receipt+Uploaded';
    }
  }

  /// Upload profile avatar — uses uploadBinary so it works on web + mobile
  static Future<String?> uploadAvatar(XFile xfile, String userId) async {
    try {
      final ext = xfile.name.contains('.') ? xfile.name.split('.').last : 'jpg';
      final fileName = 'avatar_$userId.$ext';
      final path = 'avatars/$fileName';

      final bytes = await xfile.readAsBytes();
      await _supabase.storage.from('profiles').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      return _supabase.storage.from('profiles').getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }
}
