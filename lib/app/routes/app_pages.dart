import 'package:get/get.dart';
import 'app_routes.dart';

// Screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/user_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/states_screen.dart';
import '../../features/dashboard/presentation/screens/cities_screen.dart';

// Bindings
import '../bindings/auth_binding.dart';
import '../bindings/admin_binding.dart';
import '../bindings/dashboard_binding.dart';
import '../bindings/states_binding.dart';
import '../bindings/cities_binding.dart';

class AppPages {
  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.adminDashboard, page: () => const AdminDashboardScreen(), binding: AdminBinding()),
    GetPage(name: AppRoutes.userDashboard, page: () => const UserDashboardScreen(), binding: DashboardBinding()),
    GetPage(name: AppRoutes.states, page: () => const StatesScreen(), binding: StatesBinding()),
    GetPage(name: AppRoutes.cities, page: () => const CitiesScreen(), binding: CitiesBinding()),
  ];
}
