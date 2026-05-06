import '../repositories/admin_repository.dart';
import '../entities/admin_user_entity.dart';

class GetUsersUseCase {
  final AdminRepository _repository;
  GetUsersUseCase(this._repository);

  Future<List<AdminUserEntity>> execute() => _repository.getUsers();
}
