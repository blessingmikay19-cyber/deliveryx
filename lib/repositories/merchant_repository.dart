import '../models/merchant_model.dart';
import '../services/supabase_service.dart';

class MerchantRepository {
  final _client = SupabaseService.client;

  Future<MerchantModel?> getMerchantByProfileId(
    String profileId,
  ) async {
    final response = await _client
        .from('merchants')
        .select()
        .eq('profile_id', profileId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return MerchantModel.fromMap(response);
  }

  Future<MerchantModel> createMerchant({
    required String profileId,
    required String businessName,
    String? businessDescription,
    String? phone,
    String? address,
  }) async {
    final response = await _client
        .from('merchants')
        .insert({
          'profile_id': profileId,
          'business_name': businessName,
          'business_description': businessDescription,
          'phone': phone,
          'address': address,
        })
        .select()
        .single();

    return MerchantModel.fromMap(response);
  }

  Future<MerchantModel> updateMerchant({
    required String merchantId,
    String? businessName,
    String? businessDescription,
    String? phone,
    String? address,
    bool? isOpen,
    int? preparationTimeMinutes,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (businessName != null) {
      updates['business_name'] = businessName;
    }

    if (businessDescription != null) {
      updates['business_description'] =
          businessDescription;
    }

    if (phone != null) {
      updates['phone'] = phone;
    }

    if (address != null) {
      updates['address'] = address;
    }

    if (isOpen != null) {
      updates['is_open'] = isOpen;
    }

    if (preparationTimeMinutes != null) {
      updates['preparation_time_minutes'] =
          preparationTimeMinutes;
    }

    final response = await _client
        .from('merchants')
        .update(updates)
        .eq('id', merchantId)
        .select()
        .single();

    return MerchantModel.fromMap(response);
  }
}