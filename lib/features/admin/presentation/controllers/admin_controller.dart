import 'package:get/get.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/services/token_service.dart';
import '../../../../app/routes/app_routes.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../../domain/usecases/disable_user_usecase.dart';
import '../../domain/usecases/delete_user_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';

class AdminController extends GetxController {
  final GetUsersUseCase _getUsersUseCase;
  final CreateUserUseCase _createUserUseCase;
  final DisableUserUseCase _disableUserUseCase;
  final DeleteUserUseCase _deleteUserUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  AdminController(
    this._getUsersUseCase,
    this._createUserUseCase,
    this._disableUserUseCase,
    this._deleteUserUseCase,
    this._resetPasswordUseCase,
  );

  final users = <AdminUserEntity>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    try {
      final fetchedUsers = await _getUsersUseCase.execute();
      users.assignAll(fetchedUsers);
    } on AppException catch (e) {
      Get.snackbar('Error', e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUser(String name, String email, String password, String role) async {
    try {
      final newUser = await _createUserUseCase.execute(name: name, email: email, password: password, role: role);
      users.add(newUser);
      Get.back(); // close dialog
      Get.snackbar('Success', 'User created successfully');
    } on AppException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }

  Future<void> toggleDisableUser(String id) async {
    try {
      await _disableUserUseCase.execute(id);
      fetchUsers(); // Refresh the list
    } on AppException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _deleteUserUseCase.execute(id);
      users.removeWhere((user) => user.id == id);
      Get.snackbar('Success', 'User deleted successfully');
    } on AppException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }

  Future<void> resetPassword(String id, String newPassword) async {
    try {
      await _resetPasswordUseCase.execute(id: id, newPassword: newPassword);
      Get.back(); // close dialog
      Get.snackbar('Success', 'Password reset successfully');
    } on AppException catch (e) {
      Get.snackbar('Error', e.message);
    }
  }

  Future<void> logout() async {
    await TokenService().clearAll();
    Get.offAllNamed(AppRoutes.login);
  }
}
