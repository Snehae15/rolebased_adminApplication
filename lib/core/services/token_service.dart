import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';
  static const _storage = FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveRole(String role) =>
      _storage.write(key: _roleKey, value: role);

  Future<String?> getRole() => _storage.read(key: _roleKey);

  Future<void> clearAll() => _storage.deleteAll();
}
