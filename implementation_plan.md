# 📋 Implementation Plan — Analytics Dashboard Flutter App
> Senior-Level Interview Task | Time Budget: 3 Hours | Stack: Flutter + GetX + Dio + SfCharts

---

## ⏱️ Time Allocation Overview

| Phase | Task | Time |
|-------|------|------|
| 0 | Project Setup & Structure | 15 min |
| 1 | Core Layer (Models, Services, DI) | 30 min |
| 2 | Auth Flow (Splash + Login) | 20 min |
| 3 | Admin Dashboard | 35 min |
| 4 | User Analytics Dashboard | 45 min |
| 5 | Drill-Down Screens (State/City) | 20 min |
| 6 | Polish, Error Handling, Testing | 15 min |
| **Total** | | **~3 hrs** |

---

## Phase 0 — Project Bootstrap (15 min)

### 0.1 Create Flutter Project
```bash
flutter create analytics_dashboard
cd analytics_dashboard
```

### 0.2 Add Dependencies to `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  get: ^4.6.6

  # Networking
  dio: ^5.4.3+1

  # Charts
  syncfusion_flutter_charts: ^25.2.7

  # Storage (token persistence)
  get_storage: ^2.1.1

  # UI extras
  flutter_spinkit: ^5.2.1
  cached_network_image: ^3.3.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.9
```

### 0.3 Run Setup
```bash
flutter pub get
```

---

## Phase 1 — Core Layer (30 min)

### 1.1 Folder Structure (Clean Architecture)
```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_colors.dart
│   ├── errors/
│   │   └── failures.dart
│   ├── network/
│   │   └── dio_client.dart
│   └── storage/
│       └── local_storage.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/user_model.dart
│   │   │   └── repositories/auth_repository.dart
│   │   ├── domain/
│   │   │   └── entities/user_entity.dart
│   │   └── presentation/
│   │       ├── controllers/auth_controller.dart
│   │       ├── pages/splash_page.dart
│   │       └── pages/login_page.dart
│   ├── admin/
│   │   ├── data/
│   │   │   └── repositories/admin_repository.dart
│   │   └── presentation/
│   │       ├── controllers/admin_controller.dart
│   │       ├── pages/admin_dashboard_page.dart
│   │       ├── pages/create_user_page.dart
│   │       └── widgets/user_tile.dart
│   └── dashboard/
│       ├── data/
│       │   ├── models/
│       │   │   ├── revenue_model.dart
│       │   │   ├── sales_summary_model.dart
│       │   │   ├── country_sales_model.dart
│       │   │   └── hourly_growth_model.dart
│       │   └── repositories/dashboard_repository.dart
│       └── presentation/
│           ├── controllers/dashboard_controller.dart
│           ├── pages/
│           │   ├── user_dashboard_page.dart
│           │   ├── state_sales_page.dart
│           │   └── city_sales_page.dart
│           └── widgets/
│               ├── revenue_card.dart
│               ├── sales_pie_chart.dart
│               ├── country_sales_widget.dart
│               └── hourly_growth_chart.dart
├── routes/
│   └── app_routes.dart
├── bindings/
│   ├── auth_binding.dart
│   ├── admin_binding.dart
│   └── dashboard_binding.dart
└── main.dart
```

### 1.2 Key Files to Implement

**`core/constants/api_constants.dart`**
```dart
class ApiConstants {
  static const String baseUrl =
      'https://critter-liver-bodacious.ngrok-free.dev';

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
```

**`core/network/dio_client.dart`** — See Architecture Plan for full implementation.

---

## Phase 2 — Auth Flow (20 min)

### 2.1 Splash Screen
- Logo + "Analytics Dashboard" text
- 2-second delay → check stored token
- Navigate to Login (or Dashboard if token still valid)

### 2.2 Login Screen
- Email + Password fields with validation
- Show/hide password toggle
- Loading state while authenticating
- Role-based redirect:
  - `admin` → `/admin-dashboard`
  - `user`  → `/user-dashboard`
- Error snackbar on failure (wrong credentials, disabled account, etc.)

---

## Phase 3 — Admin Dashboard (35 min)

### Features
| Feature | Implementation |
|---------|---------------|
| List all users | `GetX` list + `ListView.builder` |
| Create user | Bottom sheet / new page with form |
| Disable/Enable toggle | `PUT /disable` with icon button |
| Reset password | Dialog with new password input |
| Delete user | Confirm dialog → `DELETE` |

### UI Notes
- Use `Chip` or colored badge for role (admin/user)
- Red badge for disabled accounts
- Pull-to-refresh support
- Optimistic UI updates via GetX reactive state

---

## Phase 4 — User Analytics Dashboard (45 min)

### Widget Build Order
1. `RevenueCard` — Large prominent number at top
2. `SalesPieChart` — SfCircularChart (Successful vs Cancelled)
3. `CountrySalesWidget` — Horizontal bar list, tappable
4. `HourlyGrowthChart` — SfCartesianChart (Line chart)

### SfCharts Usage

**Pie Chart:**
```dart
SfCircularChart(
  series: <CircularSeries>[
    PieSeries<SaleData, String>(
      dataSource: data,
      xValueMapper: (d, _) => d.label,
      yValueMapper: (d, _) => d.count,
      dataLabelSettings: DataLabelSettings(isVisible: true),
    )
  ],
)
```

**Line Chart:**
```dart
SfCartesianChart(
  primaryXAxis: CategoryAxis(),
  series: <CartesianSeries>[
    LineSeries<HourlyData, String>(
      dataSource: hourlyData,
      xValueMapper: (d, _) => d.label,
      yValueMapper: (d, _) => d.amount,
      markerSettings: MarkerSettings(isVisible: true),
    )
  ],
)
```

---

## Phase 5 — Drill-Down Screens (20 min)

### Flow
```
CountrySalesWidget
    └── tap country → StateSalesPage (GET /states/:country)
            └── tap state  → CitySalesPage (GET /cities/:state?page=&limit=)
```

### City Screen Pagination
- Use `ScrollController` to detect bottom of list
- On scroll-end: fetch next page and append to list
- Show `CircularProgressIndicator` at list bottom while loading

---

## Phase 6 — Polish & Error Handling (15 min)

### Error States
- Network error → retry button
- 401 expired token → auto logout + redirect to login
- 403 wrong role → friendly message
- Empty states with illustrations

### UX Polish
- Shimmer/skeleton loading for all data widgets
- `GetX` Snackbars for all success/error feedback
- Consistent padding (16px horizontal)
- Responsive chart heights

---

## ✅ Definition of Done

- [ ] Splash → Login flow working
- [ ] Admin can list, create, disable, reset, delete users
- [ ] User dashboard loads all 4 data widgets
- [ ] Country → State → City drill-down works
- [ ] City pagination loads more on scroll
- [ ] All API errors handled gracefully
- [ ] Token persisted across app restart
- [ ] No hardcoded strings (use constants)
- [ ] Clean architecture layers respected (data ↔ domain ↔ presentation)
