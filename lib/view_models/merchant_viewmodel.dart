import 'package:flutter/foundation.dart';

import '../models/merchant_model.dart';
import '../repositories/merchant_repository.dart';

class MerchantViewModel extends ChangeNotifier {
  final MerchantRepository _repository =
      MerchantRepository();

  MerchantModel? _merchant;

  bool _isLoading = false;

  String? _errorMessage;

  MerchantModel? get merchant => _merchant;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isApproved =>
      _merchant?.approvalStatus == 'approved';

  Future<void> loadMerchant(String profileId) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _merchant =
          await _repository.getMerchantByProfileId(
        profileId,
      );
    } catch (e) {
      _errorMessage =
          'Unable to load merchant information.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMerchant({
    required String profileId,
    required String businessName,
    String? businessDescription,
    String? phone,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _merchant = await _repository.createMerchant(
        profileId: profileId,
        businessName: businessName,
        businessDescription: businessDescription,
        phone: phone,
        address: address,
      );

      return true;
    } catch (e) {
      _errorMessage =
          'Unable to create merchant profile.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMerchant({
    String? businessName,
    String? businessDescription,
    String? phone,
    String? address,
    bool? isOpen,
    int? preparationTimeMinutes,
  }) async {
    if (_merchant == null) {
      _errorMessage = 'Merchant profile not found.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _merchant = await _repository.updateMerchant(
        merchantId: _merchant!.id,
        businessName: businessName,
        businessDescription: businessDescription,
        phone: phone,
        address: address,
        isOpen: isOpen,
        preparationTimeMinutes:
            preparationTimeMinutes,
      );

      return true;
    } catch (e) {
      _errorMessage =
          'Unable to update merchant profile.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}