import 'package:get/get.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/usecases/dashboard_usecases.dart';

class StatesController extends GetxController {
  final DashboardUseCases _useCases;
  StatesController(this._useCases);

  final states = <StateEntity>[].obs;
  final isLoading = false.obs;
  late String countryName;

  @override
  void onInit() {
    super.onInit();
    countryName = Get.arguments as String;
    fetchStates();
  }

  Future<void> fetchStates() async {
    isLoading.value = true;
    try {
      final fetchedStates = await _useCases.getStates(countryName);
      states.assignAll(fetchedStates);
    } on AppException catch (e) {
      Get.snackbar('Error', e.message);
    } finally {
      isLoading.value = false;
    }
  }
}
