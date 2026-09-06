import 'dart:typed_data';

import '../services/storage_service.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/supabase_service.dart';

class ProductRepository {
  final _client = SupabaseService.client;

  // =========================
  // CATEGORIES
  // =========================

  Future<List<CategoryModel>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('name');

    return response
        .map<CategoryModel>(
          (map) => CategoryModel.fromMap(map),
        )
        .toList();
  }

  // =========================
  // MERCHANT PRODUCTS
  // =========================

  Future<List<ProductModel>> getMerchantProducts(
    String merchantId,
  ) async {
    final response = await _client
        .from('merchant_products')
        .select()
        .eq('merchant_id', merchantId)
        .order('created_at', ascending: false);

    return response
        .map<ProductModel>(
          (map) => ProductModel.fromMap(map),
        )
        .toList();
  }

  Future<ProductModel> createProduct({
    required String merchantId,
    String? categoryId,
    required String name,
    String? description,
    required double price,
    String? imageUrl,
  }) async {
    final response = await _client
        .from('merchant_products')
        .insert({
          'merchant_id': merchantId,
          'category_id': categoryId,
          'name': name,
          'description': description,
          'price': price,
          'image_url': imageUrl,
        })
        .select()
        .single();

    return ProductModel.fromMap(response);
  }

  Future<ProductModel> updateProduct({
    required String productId,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (categoryId != null) {
      updates['category_id'] = categoryId;
    }

    if (name != null) {
      updates['name'] = name;
    }

    if (description != null) {
      updates['description'] = description;
    }

    if (price != null) {
      updates['price'] = price;
    }

    if (imageUrl != null) {
      updates['image_url'] = imageUrl;
    }

    if (isAvailable != null) {
      updates['is_available'] = isAvailable;
    }

    final response = await _client
        .from('merchant_products')
        .update(updates)
        .eq('id', productId)
        .select()
        .single();

    return ProductModel.fromMap(response);
  }

  Future<void> deleteProduct(String productId) async {
    await _client
        .from('merchant_products')
        .delete()
        .eq('id', productId);
  }

  Future<String> uploadProductImage({
  required String userId,
  required String fileName,
  required Uint8List fileBytes,
}) async {
  return await StorageService.uploadProductImage(
    userId: userId,
    fileName: fileName,
    fileBytes: fileBytes,
  );
}
}