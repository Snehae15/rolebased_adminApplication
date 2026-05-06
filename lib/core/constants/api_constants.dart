import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  static String get baseUrl => _configuredBaseUrl.isNotEmpty
      ? _configuredBaseUrl
      : kIsWeb
          ? 'http://127.0.0.1:8787'
          : 'https://critter-liver-bodacious.ngrok-free.dev';

  // Auth
  static const String login = '/api/auth/login';

  // Admin
  static const String users = '/api/admin/users';
  static String resetPassword(String id) => '/api/admin/users/$id/reset-password';
  static String disableUser(String id)   => '/api/admin/users/$id/disable';
  static String deleteUser(String id)    => '/api/admin/users/$id';

  // Dashboard
  static const String revenue      = '/api/dashboard/revenue';
  static const String salesSummary = '/api/dashboard/sales-summary';
  static const String countries    = '/api/dashboard/countries';
  static String states(String country) => '/api/dashboard/states/$country';
  static String cities(String state, {int page = 1, int limit = 20}) =>
      '/api/dashboard/cities/$state?page=$page&limit=$limit';
  static const String hourlyGrowth = '/api/dashboard/hourly-growth';
}
