import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../widgets/user_list_tile.dart';
import '../widgets/create_user_dialog.dart';

class AdminDashboardScreen extends GetView<AdminController> {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.users.isEmpty) {
          return const Center(child: Text('No users found.'));
        }
        return ListView.builder(
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final user = controller.users[index];
            return UserListTile(user: user);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.dialog(const CreateUserDialog());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
