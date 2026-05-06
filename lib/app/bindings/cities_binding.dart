import 'package:get/get.dart';
import '../../features/dashboard/domain/usecases/dashboard_usecases.dart';
import '../../features/dashboard/presentation/controllers/cities_controller.dart';

class CitiesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CitiesController(Get.find<DashboardUseCases>()));
  }
}
