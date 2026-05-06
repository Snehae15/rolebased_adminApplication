import '../entities/admin_user_entity.dart';

abstract class AdminRepository {
  Future<List<AdminUserEntity>> getUsers();
  Future<AdminUserEntity> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  });
  Future<void> disableUser(String id);
  Future<void> deleteUser(String id);
  Future<void> resetPassword({required String id, required String newPassword});
}
