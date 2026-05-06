import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../services/token_service.dart';
import '../../app/routes/app_routes.dart';

class AuthInterceptor extends Interceptor {
  final TokenService _tokenService;
  AuthInterceptor(this._tokenService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!options.path.contains('/auth/')) {
      final token = await _tokenService.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final tokenService = TokenService();
      await tokenService.clearAll();
      Get.offAllNamed(AppRoutes.login);
    }
    handler.next(err);
  }
}
