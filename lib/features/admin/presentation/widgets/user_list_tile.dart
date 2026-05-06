import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../controllers/admin_controller.dart';
import 'reset_password_dialog.dart';

class UserListTile extends GetView<AdminController> {
  final AdminUserEntity user;

  const UserListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text('${user.email} • ${user.role}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(user.disabled ? 'Disabled' : 'Active'),
            backgroundColor: user.disabled ? Colors.red.shade100 : Colors.green.shade100,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset_password') {
                Get.dialog(ResetPasswordDialog(userId: user.id));
              } else if (value == 'toggle_disable') {
                controller.toggleDisableUser(user.id);
              } else if (value == 'delete') {
                Get.defaultDialog(
                  title: 'Delete User',
                  middleText: 'Are you sure you want to delete this user?',
                  textConfirm: 'Delete',
                  textCancel: 'Cancel',
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    controller.deleteUser(user.id);
                    Get.back();
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'reset_password',
                child: Text('Reset Password'),
              ),
              PopupMenuItem<String>(
                value: 'toggle_disable',
                child: Text(user.disabled ? 'Enable User' : 'Disable User'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete User', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
