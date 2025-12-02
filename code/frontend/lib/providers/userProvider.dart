import 'package:bem_na_hora_flutter/services/api_service.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;
  final AuthService _authService;

  User? _user;
  bool _isLoading = false;
  String? _error;

  UserProvider(this._userService, this._authService);

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  // Login
  Future<void> login(String email, String senha) async {
    _setLoading(true);
    _setError(null);
    try {
      final authResponse = await _userService.login(email, senha);
      _user = authResponse.user;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Registrar
  Future<void> register(User user) async {
    _setLoading(true);
    _setError(null);
    try {
      final newUser = await _userService.register(user);
      _user = newUser;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Buscar usuário atual
  Future<void> loadCurrentUser() async {
    _setLoading(true);
    try {
      final storedUser = await _authService.getCurrentUser();
      _user = storedUser;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar usuário
  Future<void> updateUser(User user) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _userService.updateUser(user);
      _user = updated;
      await loadAllUsers(reset: true);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteUser(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      await _userService.deleteUser(id);
      if (_user != null && _user!.id == id) {
        _user = null;
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    await _userService.logout();
    _user = null;
    notifyListeners();
  }

  List<User> _users = [];
  List<User> get users => _users;

  Future<void> loadAllUsers({bool reset = false}) async {
    _setLoading(true);
    try {
      final response = await _userService.getAllUsers();
      if (reset) {
        _users = response;
      } else {
        _users.addAll(response);
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<User> getUserById(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = await _userService.getUserById(id);
      return user;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
