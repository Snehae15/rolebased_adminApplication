import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;
  DashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<RevenueEntity> getRevenue() => _remoteDataSource.getRevenue();

  @override
  Future<SalesSummaryEntity> getSalesSummary() => _remoteDataSource.getSalesSummary();

  @override
  Future<List<CountryEntity>> getCountries() => _remoteDataSource.getCountries();

  @override
  Future<List<StateEntity>> getStates(String country) => _remoteDataSource.getStates(country);

  @override
  Future<CityPageEntity> getCities({required String state, required int page, required int limit}) => _remoteDataSource.getCities(state: state, page: page, limit: limit);

  @override
  Future<List<HourlyGrowthEntity>> getHourlyGrowth() => _remoteDataSource.getHourlyGrowth();
}
