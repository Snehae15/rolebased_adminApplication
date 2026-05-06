# 🧪 Testing Plan — Analytics Dashboard Flutter App

---

## Testing Strategy

Given the **3-hour time constraint**, testing is prioritized by risk and visibility:

```
Priority 1 (Must) → Auth flow, API connection, role routing
Priority 2 (Should) → Controllers, repository methods
Priority 3 (Nice) → Widget tests, edge cases
```

---

## 1. Unit Tests — Controllers

### `AuthController` Tests

**File:** `test/auth/auth_controller_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([AuthRepository, LocalStorage])
void main() {
  late AuthController controller;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    controller = AuthController(mockRepo);
    Get.testMode = true;
  });

  tearDown(() => Get.reset());

  group('AuthController.login()', () {
    test('sets isLoading true while logging in', () async {
      when(mockRepo.login(any, any)).thenAnswer(
        (_) async => Future.delayed(const Duration(milliseconds: 100),
            () => UserModel(id: '1', name: 'Alice', email: 'alice@test.com',
                            role: 'user', disabled: false, createdAt: '')),
      );

      final future = controller.login('alice@test.com', 'User@123');
      expect(controller.isLoading.value, true);
      await future;
      expect(controller.isLoading.value, false);
    });

    test('sets errorMessage on wrong credentials (401)', () async {
      when(mockRepo.login(any, any))
          .thenThrow(Exception('Invalid email or password'));

      await controller.login('wrong@test.com', 'wrong');

      expect(controller.errorMessage.value, isNotEmpty);
      expect(controller.currentUser.value, isNull);
    });

    test('navigates to admin dashboard when role is admin', () async {
      when(mockRepo.login(any, any)).thenAnswer(
        (_) async => UserModel(id: '1', name: 'Admin', email: 'admin@test.com',
                               role: 'admin', disabled: false, createdAt: ''),
      );

      await controller.login('admin@analytics.com', 'Admin@123');
      // Verify route via Get.currentRoute in test mode
      expect(Get.currentRoute, AppRoutes.adminDashboard);
    });

    test('navigates to user dashboard when role is user', () async {
      when(mockRepo.login(any, any)).thenAnswer(
        (_) async => UserModel(id: '2', name: 'Alice', email: 'alice@test.com',
                               role: 'user', disabled: false, createdAt: ''),
      );

      await controller.login('alice@analytics.com', 'User@123');
      expect(Get.currentRoute, AppRoutes.userDashboard);
    });

    test('handles disabled account (403)', () async {
      when(mockRepo.login(any, any))
          .thenThrow(Exception('Account has been disabled. Contact an administrator.'));

      await controller.login('mark@analytics.com', 'Mark@123');
      expect(controller.errorMessage.value, contains('disabled'));
    });
  });

  group('AuthController.logout()', () {
    test('clears storage and redirects to login', () {
      final mockStorage = MockLocalStorage();
      Get.put<LocalStorage>(mockStorage);
      controller.logout();
      verify(mockStorage.clearAll()).called(1);
      expect(Get.currentRoute, AppRoutes.login);
    });
  });
}
```

---

### `DashboardController` Tests

**File:** `test/dashboard/dashboard_controller_test.dart`

```dart
@GenerateMocks([DashboardRepository])
void main() {
  late DashboardController controller;
  late MockDashboardRepository mockRepo;

  setUp(() {
    mockRepo = MockDashboardRepository();
    controller = DashboardController(mockRepo);
    Get.testMode = true;
  });

  group('DashboardController.loadAll()', () {
    test('loads all dashboard data successfully', () async {
      when(mockRepo.getRevenue()).thenAnswer((_) async =>
          RevenueModel(currency: 'USD', period: 'FY 2024', totalRevenue: 48275930.75));
      when(mockRepo.getSalesSummary()).thenAnswer((_) async =>
          SalesSummaryModel(/* ... */));
      when(mockRepo.getCountries()).thenAnswer((_) async => []);
      when(mockRepo.getHourlyGrowth()).thenAnswer((_) async => []);

      await controller.loadAll();

      expect(controller.revenue.value, isNotNull);
      expect(controller.isLoading.value, false);
    });

    test('sets isLoading false even if one request fails', () async {
      when(mockRepo.getRevenue()).thenThrow(Exception('Network error'));
      when(mockRepo.getSalesSummary()).thenAnswer((_) async => SalesSummaryModel(/* ... */));
      when(mockRepo.getCountries()).thenAnswer((_) async => []);
      when(mockRepo.getHourlyGrowth()).thenAnswer((_) async => []);

      await controller.loadAll();
      expect(controller.isLoading.value, false);
    });
  });
}
```

---

### `AdminController` Tests

**File:** `test/admin/admin_controller_test.dart`

```dart
group('AdminController', () {
  test('fetchUsers populates userList', () async {
    when(mockRepo.getUsers()).thenAnswer((_) async => [
      UserModel(id: '1', name: 'Alice', email: 'alice@test.com',
                role: 'user', disabled: false, createdAt: ''),
    ]);

    await controller.fetchUsers();
    expect(controller.users.length, 1);
  });

  test('createUser adds to list on success', () async {
    when(mockRepo.createUser(any)).thenAnswer((_) async =>
        UserModel(id: '99', name: 'Bob', email: 'bob@test.com',
                  role: 'user', disabled: false, createdAt: ''));

    await controller.createUser(name: 'Bob', email: 'bob@test.com',
                                 password: 'Pass@123', role: 'user');
    expect(controller.users.any((u) => u.email == 'bob@test.com'), true);
  });

  test('toggleDisable flips disabled status in list', () async {
    controller.users.add(UserModel(id: '1', name: 'Alice', email: 'a@b.com',
                                    role: 'user', disabled: false, createdAt: ''));
    when(mockRepo.toggleDisable('1')).thenAnswer((_) async =>
        UserModel(id: '1', name: 'Alice', email: 'a@b.com',
                  role: 'user', disabled: true, createdAt: ''));

    await controller.toggleDisable('1');
    expect(controller.users.first.disabled, true);
  });

  test('deleteUser removes from list', () async {
    controller.users.add(UserModel(id: '1', name: 'Alice', email: 'a@b.com',
                                    role: 'user', disabled: false, createdAt: ''));
    when(mockRepo.deleteUser('1')).thenAnswer((_) async => {});

    await controller.deleteUser('1');
    expect(controller.users.isEmpty, true);
  });
});
```

---

## 2. Unit Tests — Repositories

**File:** `test/auth/auth_repository_test.dart`

```dart
group('AuthRepository.login()', () {
  test('returns UserModel on 200 success', () async {
    // Mock DioClient.post to return success response
    when(mockDio.post(any, data: anyNamed('data'))).thenAnswer((_) async =>
        Response(
          data: {
            'success': true,
            'data': {
              'token': 'mock_jwt',
              'role': 'user',
              'user': {
                'id': '1', 'name': 'Alice', 'email': 'alice@test.com',
                'role': 'user', 'createdAt': '2024-01-01'
              }
            }
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/auth/login'),
        ));

    final result = await repo.login('alice@test.com', 'User@123');

    expect(result.name, 'Alice');
    verify(mockStorage.saveToken('mock_jwt')).called(1);
    verify(mockStorage.saveRole('user')).called(1);
  });

  test('throws Failure with API message on 401', () async {
    when(mockDio.post(any, data: anyNamed('data'))).thenThrow(
        DioException(
          response: Response(
            data: {'success': false, 'message': 'Invalid email or password'},
            statusCode: 401,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ));

    expect(() => repo.login('x@x.com', 'wrong'),
           throwsA(isA<Exception>()));
  });
});
```

---

## 3. Widget Tests

**File:** `test/widgets/login_page_test.dart`

```dart
testWidgets('Login button is disabled when fields are empty', (tester) async {
  await tester.pumpWidget(GetMaterialApp(home: LoginPage()));

  final loginButton = find.text('Login');
  // Verify no API call triggered with empty fields
  await tester.tap(loginButton);
  await tester.pump();
  verify(mockAuthController.login(any, any)).called(0);
});

testWidgets('Shows error snackbar on login failure', (tester) async {
  // Setup controller with error
  controller.errorMessage.value = 'Invalid email or password';
  await tester.pumpWidget(GetMaterialApp(home: LoginPage()));
  await tester.pump();
  expect(find.text('Invalid email or password'), findsOneWidget);
});

testWidgets('Password field toggles visibility', (tester) async {
  await tester.pumpWidget(GetMaterialApp(home: LoginPage()));
  final toggleIcon = find.byIcon(Icons.visibility_off);
  await tester.tap(toggleIcon);
  await tester.pump();
  expect(find.byIcon(Icons.visibility), findsOneWidget);
});
```

---

## 4. Integration / Smoke Tests

### Manual Smoke Test Checklist

Run against live API (`https://critter-liver-bodacious.ngrok-free.dev`):

#### Auth
- [ ] Login with `alice@analytics.com / User@123` → goes to User Dashboard
- [ ] Login with `admin@analytics.com / Admin@123` → goes to Admin Dashboard
- [ ] Login with `mark@analytics.com / Mark@123` → shows "Account has been disabled" error
- [ ] Login with wrong password → shows "Invalid email or password" error
- [ ] Login with empty fields → validation error, no API call

#### Admin Dashboard
- [ ] Lists all users with name, email, role, disabled status
- [ ] Create new user with valid data → appears in list
- [ ] Create user with duplicate email → shows 409 error
- [ ] Disable active user → badge changes to disabled
- [ ] Re-enable disabled user → badge changes back
- [ ] Reset password → success snackbar
- [ ] Delete user → removed from list
- [ ] Attempt to disable own account → shows self-disable error

#### User Dashboard
- [ ] Revenue card shows `$48,275,930.75`
- [ ] Pie chart shows Successful vs Cancelled slices
- [ ] Country list shows 10 countries
- [ ] Tap "India" → shows 6 states
- [ ] Tap "Tamil Nadu" → shows city list with pagination
- [ ] Scroll to bottom of city list → loads next page
- [ ] Line chart shows 24-hour growth data

#### Error Handling
- [ ] Kill server → shows retry button
- [ ] Wait for token to expire → auto-logout to login screen
- [ ] Navigate to admin route as user role → blocked

---

## 5. Model Parsing Tests

```dart
group('SalesSummaryModel.fromJson()', () {
  test('parses nested successful/cancelled objects correctly', () {
    final json = {
      'period': 'FY 2024',
      'totalTransactions': 312450,
      'successful': {'count': 274820, 'amount': 44182340.50},
      'cancelled': {'count': 37630, 'amount': 4093590.25},
      'lastUpdated': '2026-04-29T01:35:00.000Z',
    };

    final model = SalesSummaryModel.fromJson(json);

    expect(model.successCount, 274820);
    expect(model.successAmount, 44182340.50);
    expect(model.cancelCount, 37630);
  });
});

group('HourlyGrowthModel.fromJson()', () {
  test('handles negative growth values', () {
    final model = HourlyGrowthModel.fromJson({
      'hour': 1, 'label': '01:00', 'amount': 1800, 'growth': -43.7
    });
    expect(model.growth, -43.7);
  });
});
```

---

## 6. Run Tests

```bash
# Generate mocks
flutter pub run build_runner build --delete-conflicting-outputs

# Run all tests
flutter test

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Run specific file
flutter test test/auth/auth_controller_test.dart
```

---

## ⏱️ Testing Time Budget (within 3 hrs)

| Test Type | Time |
|-----------|------|
| Manual smoke tests (live API) | 8 min |
| Auth controller unit tests | 5 min (write while implementing) |
| Model parsing tests | 3 min |
| Widget smoke (emulator) | 4 min |
| **Total** | **~20 min** |

> Focus time on **manual smoke tests against real API** — they catch the most bugs in an interview setting.
