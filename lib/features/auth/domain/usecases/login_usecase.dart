import 'package:get/get.dart';
import '../../../../core/error/app_exception.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<String> execute({required String email, required String password}) async {
    if (email.trim().isEmpty) throw const ValidationException('Email is required');
    if (!GetUtils.isEmail(email)) throw const ValidationException('Enter a valid email');
    if (password.isEmpty) throw const ValidationException('Password is required');
    
    return _repository.login(email: email, password: password);
  }
}
