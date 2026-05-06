import '../../domain/repositories/admin_repository.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;
  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AdminUserEntity>> getUsers() => _remoteDataSource.getUsers();

  @override
  Future<AdminUserEntity> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) => _remoteDataSource.createUser(name: name, email: email, password: password, role: role);

  @override
  Future<void> disableUser(String id) => _remoteDataSource.disableUser(id);

  @override
  Future<void> deleteUser(String id) => _remoteDataSource.deleteUser(id);

  @override
  Future<void> resetPassword({required String id, required String newPassword}) =>
      _remoteDataSource.resetPassword(id: id, newPassword: newPassword);
}
