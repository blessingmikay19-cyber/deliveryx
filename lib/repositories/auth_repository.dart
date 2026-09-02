import '../models/profile_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) {
    return AuthService.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return AuthService.signIn(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return AuthService.signOut();
  }

  Future<ProfileModel?> getProfile(String userId) async {
    final response = await SupabaseService.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return ProfileModel.fromMap(response);
  }
}