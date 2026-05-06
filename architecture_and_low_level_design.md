# Architecture & Low-Level Design Plan

## Architecture: Clean Architecture (Feature-First)

Clean Architecture separates code into concentric layers with strict dependency rules:
- **Presentation** depends on **Domain**
- **Data** depends on **Domain**
- **Domain** depends on NOTHING (pure Dart)

---

## Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart                        # MaterialApp + GetMaterialApp setup
│   ├── routes/
│   │   ├── app_routes.dart             # Route name constants
│   │   └── app_pages.dart              # GetPage list
│   └── theme/
│       ├── app_theme.dart              # ThemeData
│       ├── app_colors.dart             # Color constants
│       └── app_text_styles.dart        # TextStyle constants
│
├── core/
│   ├── network/
│   │   ├── dio_client.dart             # Dio singleton + interceptors
│   │   ├── auth_interceptor.dart       # Attaches Bearer token
│   │   └── error_interceptor.dart      # Maps DioException → AppException
│   ├── error/
│   │   └── app_exception.dart          # Exception hierarchy
│   ├── models/
│   │   └── api_response.dart           # Generic ApiResponse<T>
│   ├── services/
│   │   └── token_service.dart          # flutter_secure_storage wrapper
│   └── utils/
│       ├── currency_formatter.dart     # e.g. $48,275,930.75
│       └── validators.dart             # Email, password validators
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── auth_remote_datasource.dart
    │   │   ├── models/
    │   │   │   ├── auth_response_model.dart
    │   │   │   └── user_model.dart
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── user_entity.dart
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart   # abstract
    │   │   └── usecases/
    │   │       └── login_usecase.dart
    │   └── presentation/
    │       ├── controllers/
    │       │   └── auth_controller.dart
    │       ├── screens/
    │       │   ├── splash_screen.dart
    │       │   └── login_screen.dart
    │       └── widgets/
    │           └── login_form.dart
    │
    ├── admin/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── admin_remote_datasource.dart
    │   │   ├── models/
    │   │   │   └── admin_user_model.dart
    │   │   └── repositories/
    │   │       └── admin_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── admin_user_entity.dart
    │   │   ├── repositories/
    │   │   │   └── admin_repository.dart  # abstract
    │   │   └── usecases/
    │   │       ├── get_users_usecase.dart
    │   │       ├── create_user_usecase.dart
    │   │       ├── disable_user_usecase.dart
    │   │       ├── delete_user_usecase.dart
    │   │       └── reset_password_usecase.dart
    │   └── presentation/
    │       ├── controllers/
    │       │   └── admin_controller.dart
    │       ├── screens/
    │       │   └── admin_dashboard_screen.dart
    │       └── widgets/
    │           ├── user_list_tile.dart
    │           ├── create_user_dialog.dart
    │           └── reset_password_dialog.dart
    │
    └── dashboard/
        ├── data/
        │   ├── datasources/
        │   │   └── dashboard_remote_datasource.dart
        │   ├── models/
        │   │   ├── revenue_model.dart
        │   │   ├── sales_summary_model.dart
        │   │   ├── country_model.dart
        │   │   ├── state_model.dart
        │   │   ├── city_model.dart
        │   │   └── hourly_growth_model.dart
        │   └── repositories/
        │       └── dashboard_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   ├── revenue_entity.dart
        │   │   ├── sales_summary_entity.dart
        │   │   ├── country_entity.dart
        │   │   ├── state_entity.dart
        │   │   ├── city_entity.dart
        │   │   └── hourly_growth_entity.dart
        │   ├── repositories/
        │   │   └── dashboard_repository.dart  # abstract
        │   └── usecases/
        │       ├── get_revenue_usecase.dart
        │       ├── get_sales_summary_usecase.dart
        │       ├── get_countries_usecase.dart
        │       ├── get_states_usecase.dart
        │       ├── get_cities_usecase.dart
        │       └── get_hourly_growth_usecase.dart
        └── presentation/
            ├── controllers/
            │   ├── dashboard_controller.dart
            │   ├── states_controller.dart
            │   └── cities_controller.dart
            ├── screens/
            │   ├── user_dashboard_screen.dart
            │   ├── states_screen.dart
            │   └── cities_screen.dart
            └── widgets/
                ├── revenue_card.dart
                ├── sales_pie_chart.dart
                ├── country_sales_list.dart
                ├── hourly_line_chart.dart
                └── shimmer_widgets.dart
```

---

## Low-Level Design

### 1. DioClient

```dart
class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  late final Dio dio;

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://critter-liver-bodacious.ngrok-free.dev',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',  // Required for ngrok
      },
    ));
    dio.interceptors.addAll([
      AuthInterceptor(TokenService()),
      LogInterceptor(responseBody: true),
      ErrorInterceptor(),
    ]);
  }
}
```

### 2. AuthInterceptor

```dart
class AuthInterceptor extends Interceptor {
  final TokenService _tokenService;
  AuthInterceptor(this._tokenService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth header for login endpoint
    if (!options.path.contains('/auth/login')) {
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
      await _tokenService.clearAll();
      Get.offAllNamed(AppRoutes.login);
    }
    handler.next(err);
  }
}
```

### 3. AppException Hierarchy

```dart
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class NetworkException extends AppException {
  const NetworkException() : super('No internet connection');
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

class ValidationException extends AppException {
  const ValidationException(String msg) : super(msg);
}
```

### 4. ApiResponse Model

```dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : null,
    );
  }
}
```

### 5. AuthController (GetX)

```dart
class AuthController extends GetxController {
  final LoginUseCase _loginUseCase;
  AuthController(this._loginUseCase);

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;

  Future<void> login() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final role = await _loginUseCase.execute(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (role == 'admin') {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else {
        Get.offAllNamed(AppRoutes.userDashboard);
      }
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }
}
```

### 6. DashboardController (GetX)

```dart
class DashboardController extends GetxController {
  // Use Cases injected
  final revenue = Rxn<RevenueEntity>();
  final salesSummary = Rxn<SalesSummaryEntity>();
  final countries = <CountryEntity>[].obs;
  final hourlyGrowth = <HourlyGrowthEntity>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _getRevenueUseCase.execute(),
        _getSalesSummaryUseCase.execute(),
        _getCountriesUseCase.execute(),
        _getHourlyGrowthUseCase.execute(),
      ]);
      revenue.value = results[0] as RevenueEntity;
      salesSummary.value = results[1] as SalesSummaryEntity;
      countries.value = results[2] as List<CountryEntity>;
      hourlyGrowth.value = results[3] as List<HourlyGrowthEntity>;
    } on AppException catch (e) {
      error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }
}
```

### 7. CitiesController — Infinite Pagination

```dart
class CitiesController extends GetxController {
  final GetCitiesUseCase _getCitiesUseCase;
  CitiesController(this._getCitiesUseCase);

  final cities = <CityEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  int _page = 1;
  static const int _limit = 20;
  late String stateName;

  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    stateName = Get.arguments as String;
    fetchCities();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && hasMore.value) fetchMore();
    }
  }

  Future<void> fetchCities() async {
    isLoading.value = true;
    try {
      final result = await _getCitiesUseCase.execute(
          state: stateName, page: 1, limit: _limit);
      cities.value = result.data;
      hasMore.value = result.page < result.totalPages;
      _page = 2;
    } on AppException catch (e) {
      Get.snackbar('Error', e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMore() async {
    isLoadingMore.value = true;
    try {
      final result = await _getCitiesUseCase.execute(
          state: stateName, page: _page, limit: _limit);
      cities.addAll(result.data);
      hasMore.value = result.page < result.totalPages;
      _page++;
    } on AppException catch (e) {
      Get.snackbar('Error', e.message);
    } finally {
      isLoadingMore.value = false;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
```

### 8. SfCircularChart — Sales Pie Chart

```dart
SfCircularChart(
  legend: Legend(isVisible: true, position: LegendPosition.bottom),
  series: <CircularSeries>[
    PieSeries<SalesSummaryItem, String>(
      dataSource: [
        SalesSummaryItem('Successful', summary.successful.count, Colors.green),
        SalesSummaryItem('Cancelled', summary.cancelled.count, Colors.red),
      ],
      xValueMapper: (item, _) => item.label,
      yValueMapper: (item, _) => item.count,
      pointColorMapper: (item, _) => item.color,
      dataLabelSettings: const DataLabelSettings(isVisible: true),
    )
  ],
)
```

### 9. SfCartesianChart — Hourly Line Chart

```dart
SfCartesianChart(
  primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Hour')),
  primaryYAxis: NumericAxis(title: AxisTitle(text: 'Purchase Amount')),
  series: <CartesianSeries>[
    LineSeries<HourlyGrowthEntity, String>(
      dataSource: hourlyData,
      xValueMapper: (item, _) => item.label,
      yValueMapper: (item, _) => item.amount,
      markerSettings: const MarkerSettings(isVisible: true),
    )
  ],
)
```

### 10. Dependency Injection via GetX Bindings

```dart
// auth_binding.dart
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DioClient());
    Get.lazyPut(() => TokenService());
    Get.lazyPut(() => AuthRemoteDataSourceImpl(Get.find()));
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(Get.find()));
    Get.lazyPut(() => LoginUseCase(Get.find()));
    Get.lazyPut(() => AuthController(Get.find()));
  }
}

// admin_binding.dart
class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminRemoteDataSourceImpl(Get.find()));
    Get.lazyPut<AdminRepository>(() => AdminRepositoryImpl(Get.find()));
    Get.lazyPut(() => GetUsersUseCase(Get.find()));
    Get.lazyPut(() => CreateUserUseCase(Get.find()));
    Get.lazyPut(() => DisableUserUseCase(Get.find()));
    Get.lazyPut(() => DeleteUserUseCase(Get.find()));
    Get.lazyPut(() => ResetPasswordUseCase(Get.find()));
    Get.lazyPut(() => AdminController(
      Get.find(), Get.find(), Get.find(), Get.find(), Get.find()
    ));
  }
}
```

---

## Data Flow Diagram

```
UI (Screen)
    │ triggers action
    ▼
Controller (GetX)
    │ calls
    ▼
UseCase (Domain)
    │ calls
    ▼
Repository (abstract interface, Domain)
    │ implemented by
    ▼
RepositoryImpl (Data)
    │ calls
    ▼
RemoteDataSource (Data)
    │ uses
    ▼
DioClient → API Server
```

---

## Navigation Flow

```
Splash Screen (2.5s delay)
        │
        ▼
    Login Screen
    ┌───┴───┐
    │       │
 Admin    User
    │       │
    ▼       ▼
Admin     User Dashboard
Dashboard      ├── Country List
  ├── User       │       ▼
  List         States Screen
  ├── Create        │
  User             ▼
  ├── Reset    Cities Screen
  Password   (Paginated)
  ├── Toggle
  Disable
  └── Delete
```

---

## Key Design Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| State management | GetX | Lightweight, reactive, built-in DI + routing |
| HTTP client | Dio | Interceptors, timeout config, better error handling than http |
| Secure storage | flutter_secure_storage | JWT must not be stored in SharedPreferences |
| Charts | SyncFusion | Requirement; supports both circular and cartesian charts |
| Pagination strategy | Cursor-based via page+limit params | API supports it; infinite scroll UX |
| Parallel loading | Future.wait | Dashboard loads all 4 widgets simultaneously, faster UX |
| Error propagation | Exception hierarchy | Typed errors allow precise UI handling |
