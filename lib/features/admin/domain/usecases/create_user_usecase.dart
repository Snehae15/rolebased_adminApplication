import '../repositories/admin_repository.dart';
import '../entities/admin_user_entity.dart';
import 'package:get/get.dart';
import '../../../../core/error/app_exception.dart';

class CreateUserUseCase {
  final AdminRepository _repository;
  CreateUserUseCase(this._repository);

  Future<AdminUserEntity> execute({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    if (name.trim().isEmpty) throw const ValidationException('Name is required');
    if (email.trim().isEmpty) throw const ValidationException('Email is required');
    if (!GetUtils.isEmail(email)) throw const ValidationException('Enter a valid email');
    if (password.length < 6) throw const ValidationException('Password must be at least 6 characters');
    if (!['admin', 'user'].contains(role)) throw const ValidationException('Role must be admin or user');

    return _repository.createUser(name: name, email: email, password: password, role: role);
  }
}
