import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../../../app/routes/app_routes.dart';

class CountrySalesList extends StatelessWidget {
  final List<CountryEntity> countries;
  const CountrySalesList({super.key, required this.countries});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: countries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final country = countries[index];
          return ListTile(
            title: Text(country.name),
            trailing: Text('\$${country.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Get.toNamed(AppRoutes.states, arguments: country.name);
            },
          );
        },
      ),
    );
  }
}
