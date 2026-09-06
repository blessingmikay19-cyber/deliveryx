import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class StorageService {
  static SupabaseClient get _client =>
      SupabaseService.client;

  static const String productImagesBucket =
      'product-images';

  static Future<String> uploadProductImage({
    required String userId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final filePath =
        '$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await _client.storage
        .from(productImagesBucket)
        .uploadBinary(
          filePath,
          fileBytes,
          fileOptions: const FileOptions(
            upsert: false,
          ),
        );

    return _client.storage
        .from(productImagesBucket)
        .getPublicUrl(filePath);
  }

  static Future<void> deleteProductImage(
    String imageUrl,
  ) async {
    final uri = Uri.tryParse(imageUrl);

    if (uri == null) {
      return;
    }

    final pathSegments = uri.pathSegments;

    final bucketIndex =
        pathSegments.indexOf(productImagesBucket);

    if (bucketIndex == -1 ||
        bucketIndex + 1 >= pathSegments.length) {
      return;
    }

    final filePath = pathSegments
        .sublist(bucketIndex + 1)
        .join('/');

    await _client.storage
        .from(productImagesBucket)
        .remove([filePath]);
  }
}