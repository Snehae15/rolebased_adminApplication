import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/usecases/login_usecase.dart';

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
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
