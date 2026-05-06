import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/dashboard_models.dart';

class DashboardRemoteDataSource {
  final DioClient _dioClient;
  DashboardRemoteDataSource(this._dioClient);

  Future<RevenueModel> getRevenue() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.revenue);
      return RevenueModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<SalesSummaryModel> getSalesSummary() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.salesSummary);
      return SalesSummaryModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<CountryModel>> getCountries() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.countries);
      return (response.data['data'] as List).map((e) => CountryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<StateModel>> getStates(String country) async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.states(country));
      return (response.data['data'] as List).map((e) => StateModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<CityPageModel> getCities({required String state, required int page, required int limit}) async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.cities(state, page: page, limit: limit));
      return CityPageModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<HourlyGrowthModel>> getHourlyGrowth() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.hourlyGrowth);
      return (response.data['data'] as List).map((e) => HourlyGrowthModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
