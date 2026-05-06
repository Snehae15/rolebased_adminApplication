import 'package:get/get.dart';
import 'package:rolebased_adminapplication/features/admin/domain/usecases/create_user_usecase.dart';
import 'package:rolebased_adminapplication/features/admin/domain/usecases/delete_user_usecase.dart';
import 'package:rolebased_adminapplication/features/admin/domain/usecases/disable_user_usecase.dart';
import 'package:rolebased_adminapplication/features/admin/domain/usecases/reset_password_usecase.dart';
import 'package:rolebased_adminapplication/features/admin/presentation/controllers/admin_controller.dart';
import '../../core/network/dio_client.dart';
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/get_users_usecase.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminRemoteDataSource(Get.find<DioClient>()));
    Get.lazyPut<AdminRepository>(() => AdminRepositoryImpl(Get.find<AdminRemoteDataSource>()));
    Get.lazyPut(() => GetUsersUseCase(Get.find<AdminRepository>()));
    Get.lazyPut(() => CreateUserUseCase(Get.find<AdminRepository>()));
    Get.lazyPut(() => DisableUserUseCase(Get.find<AdminRepository>()));
    Get.lazyPut(() => DeleteUserUseCase(Get.find<AdminRepository>()));
    Get.lazyPut(() => ResetPasswordUseCase(Get.find<AdminRepository>()));
    Get.lazyPut(() => AdminController(
      Get.find<GetUsersUseCase>(),
      Get.find<CreateUserUseCase>(),
      Get.find<DisableUserUseCase>(),
      Get.find<DeleteUserUseCase>(),
      Get.find<ResetPasswordUseCase>(),
    ));
  }
}
