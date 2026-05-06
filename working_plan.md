# ⚙️ Working Plan — 3-Hour Execution Guide
> This is your real-time battle plan. Work top-to-bottom. Don't skip steps.

---

## ⏰ Clock-Based Execution

| Clock Time | Task | Checkpoint |
|------------|------|-----------|
| 0:00 – 0:15 | Project setup + pubspec + folders | App runs on emulator |
| 0:15 – 0:30 | DioClient + LocalStorage + constants | No errors in core/ |
| 0:30 – 0:50 | Models + Repositories (Auth + Dashboard) | Compilation clean |
| 0:50 – 1:10 | Splash + Login screen + AuthController | Login works end-to-end |
| 1:10 – 1:45 | Admin Dashboard (list + actions) | All admin API calls work |
| 1:45 – 2:30 | User Dashboard (4 widgets + charts) | Dashboard renders |
| 2:30 – 2:50 | State → City drill-down + pagination | Drill-down flow works |
| 2:50 – 3:00 | Polish: errors, loading states, UX | App feels production-ready |

---

## ✅ Step-by-Step Execution Checklist

### BLOCK 1 — Setup (0:00 – 0:30)

- [ ] `flutter create analytics_dashboard && cd analytics_dashboard`
- [ ] Paste all dependencies into `pubspec.yaml`
- [ ] Run `flutter pub get` — confirm no errors
- [ ] Create folder structure from Architecture Plan
- [ ] Create `api_constants.dart` with base URL and all endpoints
- [ ] Create `app_colors.dart` with theme colors
- [ ] Implement `LocalStorage` with GetStorage
- [ ] Implement `DioClient` with:
  - [ ] `ngrok-skip-browser-warning: true` header ← **CRITICAL**
  - [ ] Token injection interceptor
  - [ ] 401 auto-logout interceptor
  - [ ] Timeout configuration (15s)
  - [ ] LogInterceptor in debug mode
- [ ] Register `LocalStorage` and `DioClient` in `main.dart`

---

### BLOCK 2 — Auth Layer (0:30 – 1:10)

**Models**
- [ ] `UserModel.fromJson()`
- [ ] Verify all fields parse correctly

**Repository**
- [ ] `AuthRepository.login()` — POST, save token + role
- [ ] Error propagation: use `data['message']` from API response

**Controller**
- [ ] `AuthController.login()` — async, updates Rx state
- [ ] Role-based navigation (admin → `/admin-dashboard`, user → `/user-dashboard`)
- [ ] `AuthController.logout()` — clear storage, go to login

**Screens**

*Splash Page (`SplashPage`):*
- [ ] Show logo + app name
- [ ] 2-second delay
- [ ] If token exists → navigate by stored role
- [ ] If no token → navigate to login

*Login Page (`LoginPage`):*
- [ ] Email + password text fields
- [ ] Password visibility toggle
- [ ] Obx loading button (spinner while `isLoading`)
- [ ] Error message display below button
- [ ] Form validation (non-empty, email format)

**Test Checkpoint:**
- [ ] Login with `alice@analytics.com / User@123` → User Dashboard route
- [ ] Login with `admin@analytics.com / Admin@123` → Admin Dashboard route
- [ ] Login with `mark@analytics.com / Mark@123` → Disabled error shown
- [ ] Wrong credentials → Error message shown

---

### BLOCK 3 — Admin Dashboard (1:10 – 1:45)

**Models**
- [ ] Reuse `UserModel` for admin user list

**Repository (`AdminRepository`)**
- [ ] `getUsers()` — GET `/api/admin/users`
- [ ] `createUser({name, email, password, role})` — POST
- [ ] `resetPassword(id, newPassword)` — PUT
- [ ] `toggleDisable(id)` — PUT
- [ ] `deleteUser(id)` — DELETE

**Controller (`AdminController`)**
- [ ] `users = <UserModel>[].obs`
- [ ] `fetchUsers()` on `onInit()`
- [ ] `createUser()` — append to list on success
- [ ] `toggleDisable(id)` — update item in list
- [ ] `resetPassword(id)` — show snackbar
- [ ] `deleteUser(id)` — remove from list

**Screen (`AdminDashboardPage`)**
- [ ] AppBar with "Admin Dashboard" + logout button
- [ ] FAB → Create User page/dialog
- [ ] `ListView.builder` of `UserTile` widgets
- [ ] Pull-to-refresh (`RefreshIndicator`)

**UserTile Widget**
- [ ] Show: name, email, role chip, disabled badge
- [ ] Action menu or buttons: Disable/Enable, Reset Password, Delete
- [ ] Confirm dialog before delete

**CreateUserPage / Dialog**
- [ ] Fields: Name, Email, Password, Role (dropdown: admin/user)
- [ ] Validation before calling API
- [ ] Close and refresh on success

**Test Checkpoint:**
- [ ] All 5 users visible in list
- [ ] Create a new user → appears in list
- [ ] Disable a user → badge changes
- [ ] Delete a user → removed from list
- [ ] Reset password → success snackbar

---

### BLOCK 4 — User Dashboard (1:45 – 2:30)

**Models**
- [ ] `RevenueModel.fromJson()`
- [ ] `SalesSummaryModel.fromJson()` — note nested `successful` / `cancelled`
- [ ] `CountrySalesModel.fromJson()`
- [ ] `HourlyGrowthModel.fromJson()`

**Repository (`DashboardRepository`)**
- [ ] `getRevenue()`
- [ ] `getSalesSummary()`
- [ ] `getCountries()`
- [ ] `getHourlyGrowth()`

**Controller (`DashboardController`)**
- [ ] `loadAll()` with `Future.wait([...])` — parallel requests
- [ ] Rx variables for each data type
- [ ] Error handling per request (don't crash all on one failure)

**Widgets**

*RevenueCard:*
- [ ] Large formatted number: `$48,275,930.75`
- [ ] Period label: "FY 2024"
- [ ] Prominent card at top of dashboard

*SalesPieChart (SfCircularChart):*
- [ ] Two segments: Successful (green) / Cancelled (red)
- [ ] Data labels showing count or percentage
- [ ] Legend below chart

*CountrySalesWidget:*
- [ ] `ListView` or scrollable row of country cards
- [ ] Each card: flag emoji / country name, sales amount
- [ ] Tap → navigate to `StateSalesPage` passing country name

*HourlyGrowthChart (SfCartesianChart):*
- [ ] Line series over 24 hours
- [ ] X-axis: hour labels ("00:00" – "23:00")
- [ ] Y-axis: purchase amount
- [ ] Marker on each data point
- [ ] Tooltip on hover/tap showing amount

**Screen (`UserDashboardPage`)**
- [ ] `SingleChildScrollView` wrapping all widgets
- [ ] Loading shimmer / spinner while `isLoading`
- [ ] AppBar with logout button

**Test Checkpoint:**
- [ ] Revenue card shows correct amount
- [ ] Pie chart renders with two slices
- [ ] Country list shows 10 countries
- [ ] Line chart shows 24 data points

---

### BLOCK 5 — Drill-Down + Pagination (2:30 – 2:50)

**`StateSalesPage`**
- [ ] Receives `country` via `Get.arguments`
- [ ] Calls `DashboardRepository.getStates(country)` on init
- [ ] `ListView` of state → sales rows
- [ ] Tap → navigate to `CitySalesPage` with state name

**`CitySalesPage`**
- [ ] Receives `state` via `Get.arguments`
- [ ] Initial load: page 1, limit 20
- [ ] `ScrollController` attached to `ListView`
- [ ] On scroll to 90% of max extent → fetch next page
- [ ] Append new cities to list
- [ ] Show `CircularProgressIndicator` at list bottom when loading
- [ ] Stop fetching when `page >= totalPages`

**Controller for City Page:**
```dart
final cities = <CityModel>[].obs;
int _page = 1;
final bool _hasMore = true;
final isLoadingMore = false.obs;

Future<void> loadMore(String state) async {
  if (!_hasMore || isLoadingMore.value) return;
  isLoadingMore.value = true;
  final result = await _repo.getCities(state, page: _page, limit: 20);
  cities.addAll(result['data'].map(...));
  _hasMore = _page < result['totalPages'];
  _page++;
  isLoadingMore.value = false;
}
```

**Test Checkpoint:**
- [ ] Tap India → see 6 states
- [ ] Tap Tamil Nadu → see paginated city list
- [ ] Scroll to bottom → loads more cities
- [ ] All 1200+ cities accessible via pagination

---

### BLOCK 6 — Polish (2:50 – 3:00)

**Priority order (do what time allows):**

1. [ ] Empty state widgets (no data illustration + message)
2. [ ] Network error state with Retry button
3. [ ] Consistent `AppTheme` applied across all screens
4. [ ] Snackbar style consistency (success = green, error = red)
5. [ ] Loading skeletons for user list (shimmer effect)
6. [ ] Ensure admin cannot access user dashboard routes and vice versa
7. [ ] Test on both iOS and Android emulator

---

## 🚨 Common Pitfalls — Fix Before Submitting

| Pitfall | Fix |
|---------|-----|
| ngrok returns HTML instead of JSON | Add `ngrok-skip-browser-warning: true` to all requests |
| Token not sent on requests | Confirm interceptor runs before every request |
| Admin token used on dashboard routes | Dashboard repo uses same `DioClient` — token is the admin token, **API blocks admins from `/dashboard/*`**. Admins must use user credentials to see dashboard, or you show a "no access" screen |
| City pagination fires on every scroll event | Gate with `isLoadingMore.value` check |
| Charts crash with empty data | Add null/empty guards before rendering SfCharts |
| GetX controller not found | Ensure binding is set on `GetPage` |
| Dio throws untyped exception | Always catch `DioException` specifically before `catch (e)` |
| `num` cast fails on int values | Always cast as `(j['amount'] as num).toDouble()` |

---

## 🔑 API Quick Reference (for interview speed)

```
BASE: https://critter-liver-bodacious.ngrok-free.dev

AUTH
POST /api/auth/login                          { email, password }

ADMIN (Bearer admin_token)
GET  /api/admin/users
POST /api/admin/users                         { name, email, password, role }
PUT  /api/admin/users/:id/reset-password      { newPassword }
PUT  /api/admin/users/:id/disable
DEL  /api/admin/users/:id

DASHBOARD (Bearer user_token)
GET /api/dashboard/revenue
GET /api/dashboard/sales-summary
GET /api/dashboard/countries
GET /api/dashboard/states/:country
GET /api/dashboard/cities/:state?page=1&limit=20
GET /api/dashboard/hourly-growth

TEST CREDENTIALS
admin@analytics.com / Admin@123   → role: admin
alice@analytics.com / User@123    → role: user
mark@analytics.com  / Mark@123   → disabled account
```

---

## 📦 Final Submission Checklist

- [ ] App builds with `flutter run` — zero compile errors
- [ ] All 6 API categories tested manually
- [ ] Correct role-based routing verified
- [ ] Charts render without crashes
- [ ] Pagination works on city screen
- [ ] No hardcoded tokens or secrets in code
- [ ] Error states handled (no white screens)
- [ ] README or brief comment at top of `main.dart` explaining architecture choice
