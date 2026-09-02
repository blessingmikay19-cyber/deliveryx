import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';
import '../models/profile_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  ProfileModel? _profile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProfileModel? get profile => _profile;

  bool get isLoggedIn => _profile != null;

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      if (response.user == null) {
        _errorMessage = 'Registration failed.';
        return false;
      }

      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _repository.signIn(
        email: email,
        password: password,
      );

      if (response.user == null) {
        _errorMessage = 'Login failed.';
        return false;
      }

      await loadProfile(response.user!.id);

      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProfile(String userId) async {
    try {
      _profile = await _repository.getProfile(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Unable to load your profile.';
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.signOut();

    _profile = null;
    _errorMessage = null;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}