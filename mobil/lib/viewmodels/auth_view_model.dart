import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository);

  final AuthRepository _repository;

  UserModel? user;
  bool loading = true;
  String? error;

  bool get isLoggedIn => user != null;

  Future<void> init() async {
    loading = true;
    notifyListeners();
    user = await _repository.currentUser();
    loading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    return _run(() => _repository.login(email.trim(), password));
  }

  Future<bool> register(String nombre, String email, String password) async {
    return _run(
      () => _repository.register(nombre.trim(), email.trim(), password),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    user = null;
    notifyListeners();
  }

  Future<bool> _run(Future<UserModel> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      user = await action();
      loading = false;
      notifyListeners();
      return true;
    } catch (err) {
      error = '$err';
      loading = false;
      notifyListeners();
      return false;
    }
  }
}
