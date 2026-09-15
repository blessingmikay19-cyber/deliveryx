import 'package:flutter/foundation.dart';

import '../models/category_model.dart';
import '../models/merchant_model.dart';
import '../models/product_model.dart';
import '../repositories/merchant_repository.dart';
import '../repositories/product_repository.dart';

class CustomerViewModel extends ChangeNotifier {
  final MerchantRepository _merchantRepository = MerchantRepository();

  final ProductRepository _productRepository = ProductRepository();

  List<MerchantModel> _merchants = [];
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];

  MerchantModel? _selectedMerchant;

  bool _isLoadingMerchants = false;
  bool _isLoadingMenu = false;

  String? _errorMessage;

  List<MerchantModel> get merchants => _merchants;

  List<ProductModel> get products => _products;

  List<CategoryModel> get categories => _categories;

  MerchantModel? get selectedMerchant => _selectedMerchant;

  bool get isLoadingMerchants => _isLoadingMerchants;

  bool get isLoadingMenu => _isLoadingMenu;

  String? get errorMessage => _errorMessage;

  Future<void> loadMerchants() async {
    _isLoadingMerchants = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _merchants = await _merchantRepository.getApprovedOpenMerchants();
    } catch (e) {
      _errorMessage = 'Unable to load merchants.';
    } finally {
      _isLoadingMerchants = false;
      notifyListeners();
    }
  }

  Future<void> loadMerchantMenu(MerchantModel merchant) async {
    _isLoadingMenu = true;
    _errorMessage = null;
    _selectedMerchant = merchant;
    _products = [];
    _categories = [];

    notifyListeners();

    try {
      _products = await _productRepository.getAvailableMerchantProducts(
        merchant.id,
      );

      _categories = await _productRepository.getCategories();
    } catch (e) {
      _errorMessage = 'Unable to load merchant menu.';
    } finally {
      _isLoadingMenu = false;
      notifyListeners();
    }
  }

  List<ProductModel> productsForCategory(String? categoryId) {
    if (categoryId == null) {
      return _products.where((product) => product.categoryId == null).toList();
    }

    return _products
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  CategoryModel? getCategory(String? categoryId) {
    if (categoryId == null) {
      return null;
    }

    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
