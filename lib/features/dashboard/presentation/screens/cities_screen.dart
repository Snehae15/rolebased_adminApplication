import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cities_controller.dart';

class CitiesScreen extends GetView<CitiesController> {
  const CitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cities in ${controller.stateName}')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.cities.isEmpty) {
          return const Center(child: Text('No cities found.'));
        }
        return ListView.separated(
          controller: controller.scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: controller.cities.length + (controller.isLoadingMore.value ? 1 : 0),
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            if (index == controller.cities.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final city = controller.cities[index];
            return ListTile(
              title: Text(city.name),
              trailing: Text('\$${city.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          },
        );
      }),
    );
  }
}
