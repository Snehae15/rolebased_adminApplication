import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/auth_response_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;
  AuthRemoteDataSource(this._dioClient);

  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return AuthResponseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
