import 'package:get/get.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/services/token_service.dart';
import '../../../../app/routes/app_routes.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/usecases/dashboard_usecases.dart';

class DashboardController extends GetxController {
  final DashboardUseCases _useCases;
  DashboardController(this._useCases);

  final revenue = Rxn<RevenueEntity>();
  final salesSummary = Rxn<SalesSummaryEntity>();
  final countries = <CountryEntity>[].obs;
  final hourlyGrowth = <HourlyGrowthEntity>[].obs;
  
  final isLoading = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    error.value = '';
    try {
      final results = await Future.wait([
        _useCases.getRevenue(),
        _useCases.getSalesSummary(),
        _useCases.getCountries(),
        _useCases.getHourlyGrowth(),
      ]);
      revenue.value = results[0] as RevenueEntity;
      salesSummary.value = results[1] as SalesSummaryEntity;
      countries.value = results[2] as List<CountryEntity>;
      hourlyGrowth.value = results[3] as List<HourlyGrowthEntity>;
    } on AppException catch (e) {
      error.value = e.message;
      Get.snackbar('Error', e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await TokenService().clearAll();
    Get.offAllNamed(AppRoutes.login);
  }
}
