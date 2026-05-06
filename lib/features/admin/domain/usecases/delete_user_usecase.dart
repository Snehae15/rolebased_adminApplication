import '../repositories/admin_repository.dart';

class DeleteUserUseCase {
  final AdminRepository _repository;
  DeleteUserUseCase(this._repository);

  Future<void> execute(String id) => _repository.deleteUser(id);
}
