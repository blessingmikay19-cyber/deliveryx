import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';
import '../models/merchant_model.dart';
import '../models/product_model.dart';

class CartViewModel extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  MerchantModel? _merchant;

  List<CartItemModel> get items =>
      List.unmodifiable(_items);

  MerchantModel? get merchant => _merchant;

  bool get isEmpty => _items.isEmpty;

  int get itemCount {
    return _items.fold(
      0,
      (total, item) => total + item.quantity,
    );
  }

  double get subtotal {
    return _items.fold(
      0,
      (total, item) => total + item.total,
    );
  }

  bool canAddFromMerchant(
    MerchantModel merchant,
  ) {
    if (_merchant == null) {
      return true;
    }

    return _merchant!.id == merchant.id;
  }

  bool addItem({
    required ProductModel product,
    required MerchantModel merchant,
  }) {
    // First item establishes the merchant. && _items.isEmpty added to ensure that the merchant is only set when the cart is empty, preventing issues when adding items from different merchants.
    _merchant ??= merchant;

    // Prevent products from different merchants
    // from being added to the same cart.
    if (_merchant!.id != merchant.id) {
      return false;
    }

    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(
        CartItemModel(
          product: product,
          quantity: 1,
        ),
      );
    }

    notifyListeners();
    return true;
  }

  void increaseQuantity(String productId) {
    final index = _items.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index == -1) {
      return;
    }

    _items[index].quantity++;

    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    final index = _items.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index == -1) {
      return;
    }

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    _clearMerchantIfEmpty();

    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere(
      (item) => item.product.id == productId,
    );

    _clearMerchantIfEmpty();

    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _merchant = null;

    notifyListeners();
  }

  void _clearMerchantIfEmpty() {
    if (_items.isEmpty) {
      _merchant = null;
    }
  }
}