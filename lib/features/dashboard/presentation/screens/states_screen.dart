import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/states_controller.dart';
import '../../../../app/routes/app_routes.dart';

class StatesScreen extends GetView<StatesController> {
  const StatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('States in ${controller.countryName}')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.states.isEmpty) {
          return const Center(child: Text('No states found.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.states.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final state = controller.states[index];
            return ListTile(
              title: Text(state.name),
              trailing: Text('\$${state.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Get.toNamed(AppRoutes.cities, arguments: state.name);
              },
            );
          },
        );
      }),
    );
  }
}
