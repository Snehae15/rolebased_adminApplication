import '../repositories/admin_repository.dart';
import '../../../../core/error/app_exception.dart';

class ResetPasswordUseCase {
  final AdminRepository _repository;
  ResetPasswordUseCase(this._repository);

  Future<void> execute({required String id, required String newPassword}) async {
    if (newPassword.length < 6) throw const ValidationException('Password must be at least 6 characters');
    return _repository.resetPassword(id: id, newPassword: newPassword);
  }
}
