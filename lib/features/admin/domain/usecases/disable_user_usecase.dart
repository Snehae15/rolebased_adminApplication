import '../repositories/admin_repository.dart';

class DisableUserUseCase {
  final AdminRepository _repository;
  DisableUserUseCase(this._repository);

  Future<void> execute(String id) => _repository.disableUser(id);
}
