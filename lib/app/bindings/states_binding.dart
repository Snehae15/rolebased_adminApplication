import 'package:get/get.dart';
import '../../features/dashboard/domain/usecases/dashboard_usecases.dart';
import '../../features/dashboard/presentation/controllers/states_controller.dart';

class StatesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StatesController(Get.find<DashboardUseCases>()));
  }
}
