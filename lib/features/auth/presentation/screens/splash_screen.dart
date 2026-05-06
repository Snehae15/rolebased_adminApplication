import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/services/token_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 2500), () async {
      final token = await TokenService().getToken();
      final role = await TokenService().getRole();
      if (!mounted) return;
      if (token != null && token.isNotEmpty) {
        Get.offAllNamed(role == 'admin' ? AppRoutes.adminDashboard : AppRoutes.userDashboard);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text('Analytics Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
