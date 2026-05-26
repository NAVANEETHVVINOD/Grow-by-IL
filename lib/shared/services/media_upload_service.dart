import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/shared/repositories/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;

/// Handles all media uploads to Supabase Storage.
///
/// Convention: files are stored as `{userId}/{filename}` so RLS
/// folder-based ownership works automatically.
class MediaUploadService {
  const MediaUploadService();

  /// Upload an avatar image. Returns the public URL.
  /// Overwrites any existing avatar for this user.
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    String extension = 'jpg',
  }) async {
    final path = '$userId/avatar.$extension';
    await supabase.storage.from('avatars').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );
    return supabase.storage.from('avatars').getPublicUrl(path);
  }

  /// Upload a portfolio project image. Returns the public URL.
  Future<String> uploadPortfolioImage({
    required String userId,
    required String projectId,
    required Uint8List bytes,
    String extension = 'jpg',
  }) async {
    final path = '$userId/$projectId.$extension';
    await supabase.storage.from('portfolio').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );
    return supabase.storage.from('portfolio').getPublicUrl(path);
  }

  /// Upload a project banner. Returns the public URL.
  Future<String> uploadProjectBanner({
    required String userId,
    required String projectId,
    required Uint8List bytes,
    String extension = 'jpg',
  }) async {
    final path = '$userId/$projectId.$extension';
    await supabase.storage.from('project-banners').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );
    return supabase.storage.from('project-banners').getPublicUrl(path);
  }

  /// Delete an avatar.
  Future<void> deleteAvatar(String userId, {String extension = 'jpg'}) async {
    await supabase.storage.from('avatars').remove(['$userId/avatar.$extension']);
  }

  /// Delete a portfolio image.
  Future<void> deletePortfolioImage(String userId, String projectId, {String extension = 'jpg'}) async {
    await supabase.storage.from('portfolio').remove(['$userId/$projectId.$extension']);
  }

  /// Delete a project banner.
  Future<void> deleteProjectBanner(String userId, String projectId, {String extension = 'jpg'}) async {
    await supabase.storage.from('project-banners').remove(['$userId/$projectId.$extension']);
  }
}

final mediaUploadServiceProvider = Provider<MediaUploadService>((ref) {
  return const MediaUploadService();
});
