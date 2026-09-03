import 'package:flutter/foundation.dart';

import '../models/merchant_model.dart';
import '../repositories/admin_repository.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminRepository _repository =
      AdminRepository();

  List<MerchantModel> _pendingMerchants = [];

  bool _isLoading = false;

  String? _errorMessage;

  List<MerchantModel> get pendingMerchants =>
      _pendingMerchants;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> loadPendingMerchants() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _pendingMerchants =
          await _repository.getPendingMerchants();
    } catch (e) {
      _errorMessage =
          'Unable to load merchant applications.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveMerchant(
    String merchantId,
  ) async {
    return _updateMerchantStatus(
      merchantId,
      'approved',
    );
  }

  Future<bool> rejectMerchant(
    String merchantId,
  ) async {
    return _updateMerchantStatus(
      merchantId,
      'rejected',
    );
  }

  Future<bool> _updateMerchantStatus(
    String merchantId,
    String status,
  ) async {
    try {
      await _repository.updateMerchantApproval(
        merchantId: merchantId,
        status: status,
      );

      _pendingMerchants.removeWhere(
        (merchant) => merchant.id == merchantId,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage =
          'Unable to update merchant application.';
      notifyListeners();

      return false;
    }
  }
}