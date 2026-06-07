import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/session_service.dart';

class AuthRepository {
  AuthRepository(this._api, this._session);

  final ApiClient _api;
  final SessionService _session;

  Future<UserModel?> currentUser() {
    return _session.getUser();
  }

  Future<UserModel> login(String email, String password) async {
    final response = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });
    return _save(response);
  }

  Future<UserModel> register(
    String nombre,
    String email,
    String password,
  ) async {
    final response = await _api.post('/auth/register', {
      'nombre': nombre,
      'email': email,
      'password': password,
    });
    return _save(response);
  }

  Future<void> logout() {
    return _session.clear();
  }

  Future<UserModel> _save(Map<String, dynamic> response) async {
    final data = response['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _session.saveSession(token: '${data['token']}', user: user);
    return user;
  }
}
