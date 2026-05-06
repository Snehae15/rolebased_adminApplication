import 'package:dio/dio.dart';

abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection. Please check your network.']);
}
class ValidationException extends AppException {
  const ValidationException(String msg) : super(msg);
}
class UnauthorizedException extends AppException {
  const UnauthorizedException(String msg) : super(msg);
}
class ForbiddenException extends AppException {
  const ForbiddenException(String msg) : super(msg);
}
class NotFoundException extends AppException {
  const NotFoundException(String msg) : super(msg);
}
class ConflictException extends AppException {
  const ConflictException(String msg) : super(msg);
}
class ServerException extends AppException {
  const ServerException(String msg) : super(msg);
}

// Helper to map DioException to AppException
AppException mapDioException(DioException e) {
  final message = e.response?.data?['message'] as String? ?? 'Something went wrong';
  if (e.response == null &&
      e.requestOptions.uri.host.contains('ngrok-free')) {
    return const NetworkException(
      'Ngrok blocked this browser request. Add ngrok-skip-browser-warning to the backend CORS allowedHeaders, then send that header from Flutter.',
    );
  }
  return switch (e.response?.statusCode) {
    400 => ValidationException(message),
    401 => UnauthorizedException(message),
    403 => ForbiddenException(message),
    404 => NotFoundException(message),
    409 => ConflictException(message),
    500 => ServerException(message),
    null => const NetworkException(),
    _ => ServerException(message),
  };
}
