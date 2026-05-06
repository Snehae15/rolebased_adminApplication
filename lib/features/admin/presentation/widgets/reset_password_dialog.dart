import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class ResetPasswordDialog extends GetView<AdminController> {
  final String userId;

  const ResetPasswordDialog({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final passwordController = TextEditingController();

    return AlertDialog(
      title: const Text('Reset Password'),
      content: TextField(
        controller: passwordController,
        decoration: const InputDecoration(labelText: 'New Password'),
        obscureText: true,
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => controller.resetPassword(userId, passwordController.text),
          child: const Text('Reset'),
        ),
      ],
    );
  }
}
