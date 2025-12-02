import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  User? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  AuthProvider(this._authService) {
    loadAuthStatus();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> loadAuthStatus() async {
    _setLoading(true);
    try {
      _isLoggedIn = await _authService.isLoggedIn();
      if (_isLoggedIn) {
        _user = await _authService.getCurrentUser();
      }
    } catch (_) {
      _isLoggedIn = false;
      _user = null;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final authResponse = await _authService.login(email, password);
      _user = authResponse.user;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoggedIn = false;
      _user = null;
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String fullName,
    UserType userType = UserType.customer,
  }) async {
    _setLoading(true);
    try {
      final authResponse = await _authService.register(
        email: email,
        password: password,
        name: name,
        fullName: fullName,
        userType: userType,
      );
      _user = authResponse.user;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoggedIn = false;
      _user = null;
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      _isLoggedIn = false;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
