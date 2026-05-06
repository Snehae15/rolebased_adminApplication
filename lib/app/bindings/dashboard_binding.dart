import 'package:get/get.dart';
import 'package:rolebased_adminapplication/features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../core/network/dio_client.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/dashboard_usecases.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardRemoteDataSource(Get.find<DioClient>()));
    Get.lazyPut<DashboardRepository>(() => DashboardRepositoryImpl(Get.find<DashboardRemoteDataSource>()));
    Get.lazyPut(() => DashboardUseCases(Get.find<DashboardRepository>()));
    Get.lazyPut(() => DashboardController(Get.find<DashboardUseCases>()));
  }
}
