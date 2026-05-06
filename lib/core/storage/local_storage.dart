import 'package:get_storage/get_storage.dart';
 
class LocalStorage {
  static const _tokenKey = 'jwt_token';
  static const _roleKey = 'user_role';
  static const _nameKey = 'user_name';
 
  final _box = GetStorage();
 
  void saveToken(String token) => _box.write(_tokenKey, token);
  String? getToken() => _box.read<String>(_tokenKey);
 
  void saveRole(String role) => _box.write(_roleKey, role);
  String? getRole() => _box.read<String>(_roleKey);
 
  void saveName(String name) => _box.write(_nameKey, name);
  String? getName() => _box.read<String>(_nameKey);
 
  bool get hasToken => getToken() != null;
 
  void clearAll() {
    _box.remove(_tokenKey);
    _box.remove(_roleKey);
    _box.remove(_nameKey);
  }
}