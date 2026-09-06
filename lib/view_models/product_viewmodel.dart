
import 'package:flutter/foundation.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Unable to load categories.';
      notifyListeners();
    }
  }

  Future<void> loadMerchantProducts(String merchantId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.getMerchantProducts(merchantId);
    } catch (e) {
      _errorMessage = 'Unable to load products.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct({
    required String merchantId,
    String? categoryId,
    required String name,
    String? description,
    required double price,
    String? imageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final product = await _repository.createProduct(
        merchantId: merchantId,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
      );

      _products.insert(0, product);

      return true;
    } catch (e) {
      _errorMessage = 'Unable to create product.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct({
    required String productId,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProduct = await _repository.updateProduct(
        productId: productId,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
      );

      final index = _products.indexWhere((product) => product.id == productId);

      if (index != -1) {
        _products[index] = updatedProduct;
      }

      return true;
    } catch (e) {
      _errorMessage = 'Unable to update product.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteProduct(productId);

      _products.removeWhere((product) => product.id == productId);

      return true;
    } catch (e) {
      _errorMessage = 'Unable to delete product.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadProductImage({
    required String userId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _repository.uploadProductImage(
        userId: userId,
        fileName: fileName,
        fileBytes: fileBytes,
      );
    } catch (e) {
      _errorMessage = 'Unable to upload product image.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
