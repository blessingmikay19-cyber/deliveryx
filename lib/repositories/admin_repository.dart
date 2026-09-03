import '../models/merchant_model.dart';
import '../services/supabase_service.dart';

class AdminRepository {
  final _client = SupabaseService.client;

  Future<List<MerchantModel>>
      getPendingMerchants() async {
    final response = await _client
        .from('merchants')
        .select()
        .eq('approval_status', 'pending')
        .order('created_at', ascending: true);

    return response
        .map<MerchantModel>(
          (map) => MerchantModel.fromMap(map),
        )
        .toList();
  }

  Future<void> updateMerchantApproval({
    required String merchantId,
    required String status,
  }) async {
    await _client
        .from('merchants')
        .update({
          'approval_status': status,
          'updated_at':
              DateTime.now().toIso8601String(),
        })
        .eq('id', merchantId);
  }
}