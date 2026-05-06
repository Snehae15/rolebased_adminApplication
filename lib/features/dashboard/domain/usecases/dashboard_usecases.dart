import '../repositories/dashboard_repository.dart';
import '../entities/dashboard_entities.dart';

class DashboardUseCases {
  final DashboardRepository _repository;
  DashboardUseCases(this._repository);

  Future<RevenueEntity> getRevenue() => _repository.getRevenue();
  Future<SalesSummaryEntity> getSalesSummary() => _repository.getSalesSummary();
  Future<List<CountryEntity>> getCountries() => _repository.getCountries();
  Future<List<StateEntity>> getStates(String country) => _repository.getStates(country);
  Future<CityPageEntity> getCities({required String state, required int page, required int limit}) => _repository.getCities(state: state, page: page, limit: limit);
  Future<List<HourlyGrowthEntity>> getHourlyGrowth() => _repository.getHourlyGrowth();
}
