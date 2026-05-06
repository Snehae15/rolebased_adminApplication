import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/services/token_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenService _tokenService;

  AuthRepositoryImpl(this._remoteDataSource, this._tokenService);

  @override
  Future<String> login({required String email, required String password}) async {
    final response = await _remoteDataSource.login(email, password);
    await _tokenService.saveToken(response.token);
    await _tokenService.saveRole(response.role);
    return response.role;
  }
}
