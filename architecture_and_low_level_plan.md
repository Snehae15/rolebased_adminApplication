# 🏛️ Architecture & Low-Level Plan — Analytics Dashboard Flutter App

---

## Architecture Overview

This app follows **Clean Architecture** with **3 distinct layers**:

```
┌────────────────────────────────────────────────┐
│           PRESENTATION LAYER                   │
│  Pages · Controllers (GetX) · Widgets          │
├────────────────────────────────────────────────┤
│              DOMAIN LAYER                      │
│  Entities · Repository Interfaces              │
├────────────────────────────────────────────────┤
│               DATA LAYER                       │
│  Models · Repository Implementations · Dio     │
└────────────────────────────────────────────────┘
```

**Data flow:**
```
UI (Page)
  → GetX Controller (calls repository)
    → Repository Implementation (calls DioClient)
      → DioClient (HTTP request)
        → API Response
      → Model.fromJson()
    → Returns Entity / throws Failure
  → Controller updates Rx state
→ UI rebuilds via Obx()
```

---

## Layer-by-Layer Breakdown

### 1. Core / Network — `DioClient`

```dart
// lib/core/network/dio_client.dart

class DioClient {
  late final Dio _dio;
  final LocalStorage _storage;

  DioClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          // ngrok requires this header to skip browser warning
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );
    _addInterceptors();
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Token expired → logout
            Get.find<AuthController>().logout();
          }
          return handler.next(e);
        },
      ),
    );

    // Logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) =>
      _dio.get(path, queryParameters: queryParams);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}
```

**Why ngrok header?** The ngrok free tier shows a browser warning page by default. Adding `ngrok-skip-browser-warning: true` bypasses it and returns actual JSON.

---

### 2. Core / Storage — `LocalStorage`

```dart
// lib/core/storage/local_storage.dart

class LocalStorage {
  static const _tokenKey = 'jwt_token';
  static const _roleKey  = 'user_role';

  final GetStorage _box = GetStorage();

  void saveToken(String token) => _box.write(_tokenKey, token);
  String? getToken()           => _box.read<String>(_tokenKey);
  void saveRole(String role)   => _box.write(_roleKey, role);
  String? getRole()            => _box.read<String>(_roleKey);

  void clearAll() {
    _box.remove(_tokenKey);
    _box.remove(_roleKey);
  }
}
```

---

### 3. Data Layer — Models

**UserModel** (`features/auth/data/models/user_model.dart`)
```dart
class UserModel {
  final String id, name, email, role;
  final bool disabled;
  final String createdAt;

  UserModel.fromJson(Map<String, dynamic> j)
      : id        = j['id'],
        name      = j['name'],
        email     = j['email'],
        role      = j['role'],
        disabled  = j['disabled'] ?? false,
        createdAt = j['createdAt'];
}
```

**RevenueModel** (`features/dashboard/data/models/revenue_model.dart`)
```dart
class RevenueModel {
  final String currency, period;
  final double totalRevenue;

  RevenueModel.fromJson(Map<String, dynamic> j)
      : currency     = j['currency'],
        period        = j['period'],
        totalRevenue  = (j['totalRevenue'] as num).toDouble();
}
```

**SalesSummaryModel**
```dart
class SalesSummaryModel {
  final int totalTransactions, successCount, cancelCount;
  final double successAmount, cancelAmount;
  final String period;

  SalesSummaryModel.fromJson(Map<String, dynamic> j)
      : totalTransactions = j['totalTransactions'],
        successCount      = j['successful']['count'],
        successAmount     = (j['successful']['amount'] as num).toDouble(),
        cancelCount       = j['cancelled']['count'],
        cancelAmount      = (j['cancelled']['amount'] as num).toDouble(),
        period            = j['period'];
}
```

**HourlyGrowthModel**
```dart
class HourlyGrowthModel {
  final int hour;
  final String label;
  final double amount, growth;

  HourlyGrowthModel.fromJson(Map<String, dynamic> j)
      : hour   = j['hour'],
        label  = j['label'],
        amount = (j['amount'] as num).toDouble(),
        growth = (j['growth'] as num).toDouble();
}
```

**CountrySalesModel**
```dart
class CountrySalesModel {
  final String country, code;
  final double sales;

  CountrySalesModel.fromJson(Map<String, dynamic> j)
      : country = j['country'],
        code    = j['code'],
        sales   = (j['sales'] as num).toDouble();
}
```

---

### 4. Data Layer — Repositories

**AuthRepository**
```dart
class AuthRepository {
  final DioClient _dio;
  final LocalStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<UserModel> login(String email, String password) async {
    try {
      final res = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final data = res.data['data'];
      _storage.saveToken(data['token']);
      _storage.saveRole(data['role']);
      return UserModel.fromJson(data['user']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
```

**DashboardRepository**
```dart
class DashboardRepository {
  final DioClient _dio;
  DashboardRepository(this._dio);

  Future<RevenueModel> getRevenue() async {
    final res = await _dio.get(ApiConstants.revenue);
    return RevenueModel.fromJson(res.data['data']);
  }

  Future<SalesSummaryModel> getSalesSummary() async {
    final res = await _dio.get(ApiConstants.salesSummary);
    return SalesSummaryModel.fromJson(res.data['data']);
  }

  Future<List<CountrySalesModel>> getCountries() async {
    final res = await _dio.get(ApiConstants.countries);
    return (res.data['data'] as List)
        .map((e) => CountrySalesModel.fromJson(e))
        .toList();
  }

  Future<List<CountrySalesModel>> getStates(String country) async {
    final res = await _dio.get(ApiConstants.states(country));
    return (res.data['data'] as List)
        .map((e) => CountrySalesModel.fromJson(e))
        .toList();
  }

  Future<Map<String, dynamic>> getCities(String state,
      {int page = 1, int limit = 20}) async {
    final res = await _dio.get(ApiConstants.cities(state, page: page, limit: limit));
    return res.data['data'];
  }

  Future<List<HourlyGrowthModel>> getHourlyGrowth() async {
    final res = await _dio.get(ApiConstants.hourlyGrowth);
    return (res.data['data'] as List)
        .map((e) => HourlyGrowthModel.fromJson(e))
        .toList();
  }
}
```

---

### 5. Presentation Layer — GetX Controllers

**AuthController**
```dart
class AuthController extends GetxController {
  final AuthRepository _repo;
  AuthController(this._repo);

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  Rx<UserModel?> currentUser = Rx(null);

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _repo.login(email, password);
      currentUser.value = user;
      user.role == 'admin'
          ? Get.offAllNamed(AppRoutes.adminDashboard)
          : Get.offAllNamed(AppRoutes.userDashboard);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    Get.find<LocalStorage>().clearAll();
    Get.offAllNamed(AppRoutes.login);
  }
}
```

**DashboardController**
```dart
class DashboardController extends GetxController {
  final DashboardRepository _repo;
  DashboardController(this._repo);

  final revenue      = Rx<RevenueModel?>(null);
  final salesSummary = Rx<SalesSummaryModel?>(null);
  final countries    = <CountrySalesModel>[].obs;
  final hourlyData   = <HourlyGrowthModel>[].obs;
  final isLoading    = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([
      _loadRevenue(),
      _loadSalesSummary(),
      _loadCountries(),
      _loadHourlyGrowth(),
    ]);
    isLoading.value = false;
  }

  Future<void> _loadRevenue() async {
    revenue.value = await _repo.getRevenue();
  }
  // ... similar for others
}
```

---

### 6. Routing — `AppRoutes`

```dart
// lib/routes/app_routes.dart

class AppRoutes {
  static const splash          = '/';
  static const login           = '/login';
  static const adminDashboard  = '/admin-dashboard';
  static const userDashboard   = '/user-dashboard';
  static const stateSales      = '/state-sales';
  static const citySales       = '/city-sales';

  static final pages = [
    GetPage(name: splash,         page: () => SplashPage(),         binding: AuthBinding()),
    GetPage(name: login,          page: () => LoginPage(),           binding: AuthBinding()),
    GetPage(name: adminDashboard, page: () => AdminDashboardPage(),  binding: AdminBinding()),
    GetPage(name: userDashboard,  page: () => UserDashboardPage(),   binding: DashboardBinding()),
    GetPage(name: stateSales,     page: () => StateSalesPage()),
    GetPage(name: citySales,      page: () => CitySalesPage()),
  ];
}
```

---

### 7. Dependency Injection — Bindings

```dart
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DioClient(Get.find()));
    Get.lazyPut(() => DashboardRepository(Get.find()));
    Get.lazyPut(() => DashboardController(Get.find()));
  }
}
```

---

### 8. main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Register shared deps
  Get.put(LocalStorage());
  Get.put(DioClient(Get.find<LocalStorage>()));

  runApp(
    GetMaterialApp(
      title: 'Analytics Dashboard',
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
      defaultTransition: Transition.fadeIn,
    ),
  );
}
```

---

## RBAC Matrix (Enforced by API + Frontend)

| Screen | Required Role | Guard |
|--------|--------------|-------|
| Splash | None | — |
| Login | None | — |
| Admin Dashboard | admin | Token role check on startup |
| User Dashboard | user | Token role check on startup |
| State/City Screens | user | Inherited from Dashboard |

> The API enforces RBAC server-side. Frontend role check is UX-only; never trust client alone.

---

## Error Handling Strategy

```dart
// lib/core/errors/failures.dart

class Failure {
  final String message;
  final int? statusCode;
  Failure(this.message, {this.statusCode});
}

String _handleDioError(DioException e) {
  final data = e.response?.data;
  if (data != null && data['message'] != null) {
    return data['message'];  // Use API's message directly
  }
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      return 'Connection timed out. Check your network.';
    case DioExceptionType.receiveTimeout:
      return 'Server is not responding.';
    default:
      return 'Something went wrong. Please try again.';
  }
}
```
