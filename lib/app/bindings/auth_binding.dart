import 'package:get/get.dart';
import 'package:rolebased_adminapplication/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:rolebased_adminapplication/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rolebased_adminapplication/features/auth/domain/repositories/auth_repository.dart';
import 'package:rolebased_adminapplication/features/auth/domain/usecases/login_usecase.dart';
import 'package:rolebased_adminapplication/features/auth/presentation/controllers/auth_controller.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/token_service.dart';


class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthRemoteDataSource(Get.find<DioClient>()));
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>(), Get.find<TokenService>()));
    Get.lazyPut(() => LoginUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => AuthController(Get.find<LoginUseCase>()));
  }
}
