import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/admin_user_model.dart';

class AdminRemoteDataSource {
  final DioClient _dioClient;
  AdminRemoteDataSource(this._dioClient);

  Future<List<AdminUserModel>> getUsers() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.users);
      final List data = response.data['data'];
      return data.map((json) => AdminUserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AdminUserModel> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.users,
        data: {'name': name, 'email': email, 'password': password, 'role': role},
      );
      return AdminUserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> disableUser(String id) async {
    try {
      await _dioClient.dio.put(ApiConstants.disableUser(id));
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _dioClient.dio.delete(ApiConstants.deleteUser(id));
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> resetPassword({required String id, required String newPassword}) async {
    try {
      await _dioClient.dio.post(
        ApiConstants.resetPassword(id),
        data: {'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
