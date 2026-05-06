import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller.emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            Obx(() => TextField(
              controller: controller.passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(controller.obscurePassword.value ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => controller.obscurePassword.toggle(),
                ),
              ),
              obscureText: controller.obscurePassword.value,
            )),
            const SizedBox(height: 24),
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: controller.login,
                    child: const Text('Login'),
                  )),
          ],
        ),
      ),
    );
  }
}
