import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_entities.dart';
import 'package:intl/intl.dart';

class RevenueCard extends StatelessWidget {
  final RevenueEntity revenue;
  const RevenueCard({super.key, required this.revenue});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Total Revenue', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              format.format(revenue.totalRevenue),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }
}
