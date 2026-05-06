import '../entities/dashboard_entities.dart';

abstract class DashboardRepository {
  Future<RevenueEntity> getRevenue();
  Future<SalesSummaryEntity> getSalesSummary();
  Future<List<CountryEntity>> getCountries();
  Future<List<StateEntity>> getStates(String country);
  Future<CityPageEntity> getCities({required String state, required int page, required int limit});
  Future<List<HourlyGrowthEntity>> getHourlyGrowth();
}
