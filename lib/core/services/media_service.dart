import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';
import '../../shared/repositories/supabase_client.dart';

class MediaService {
  Future<String?> uploadAvatar(String userId, XFile imageFile) async {
    try {
      AppLogger.action(LogCategory.system, 'AVATAR_UPLOAD_START', {
        'userId': userId,
        'originalSize': await imageFile.length(),
      });

      final compressed = await _compress(imageFile, quality: 75, maxDim: 400);
      final path = '$userId/avatar.jpg';

      await supabase.storage
          .from('profiles')
          .uploadBinary(
            path,
            compressed,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // profiles bucket is used for user avatars
      final signedUrl = await supabase.storage
          .from('profiles')
          .createSignedUrl(path, 31536000);

      AppLogger.info(
        LogCategory.system,
        'AVATAR_UPLOAD_SUCCESS | compressed=${compressed.length}b',
      );
      return signedUrl;
    } catch (e, st) {
      AppLogger.error(
        LogCategory.system,
        'AVATAR_UPLOAD_FAILED',
        error: e,
        stack: st,
      );
      return null;
    }
  }

  Future<String?> uploadProjectImage(String projectId, XFile imageFile) async {
    try {
      AppLogger.action(LogCategory.system, 'PROJECT_IMAGE_UPLOAD_START');
      final compressed = await _compress(imageFile, quality: 70, maxDim: 1080);
      final path = '$projectId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage
          .from('projects')
          .uploadBinary(
            path,
            compressed,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      final url = supabase.storage.from('projects').getPublicUrl(path);
      AppLogger.info(LogCategory.system, 'PROJECT_IMAGE_SUCCESS');
      return url;
    } catch (e, st) {
      AppLogger.error(
        LogCategory.system,
        'PROJECT_IMAGE_FAILED',
        error: e,
        stack: st,
      );
      return null;
    }
  }

  Future<Uint8List> _compress(
    XFile file, {
    required int quality,
    required int maxDim,
  }) async {
    final bytes = await file.readAsBytes();
    final result = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: maxDim,
      minHeight: maxDim,
      quality: quality,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
    AppLogger.info(
      LogCategory.system,
      'COMPRESS_DONE | ${bytes.length}b → ${result.length}b '
      '(${(100 - (result.length / bytes.length * 100)).toStringAsFixed(0)}% saved)',
    );
    return result;
  }
}
