import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
import '../services/token_service.dart';
import '../constants/api_constants.dart';

class DioClient {
  static DioClient? _instance;
  late final Dio dio;

  DioClient._() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    final tokenService = TokenService();
    dio.interceptors.addAll([
      AuthInterceptor(tokenService),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    ]);
  }

  factory DioClient() => _instance ??= DioClient._();
}
