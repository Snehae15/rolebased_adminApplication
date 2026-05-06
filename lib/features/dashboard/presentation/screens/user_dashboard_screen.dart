import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/revenue_card.dart';
import '../widgets/sales_pie_chart.dart';
import '../widgets/country_sales_list.dart';
import '../widgets/hourly_line_chart.dart';
import 'package:shimmer/shimmer.dart';

class UserDashboardScreen extends GetView<DashboardController> {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: controller.loadAll),
          IconButton(icon: const Icon(Icons.logout), onPressed: controller.logout),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.revenue.value == null) {
          return _buildShimmer();
        }
        if (controller.error.isNotEmpty && controller.revenue.value == null) {
          return Center(child: Text(controller.error.value));
        }
        return RefreshIndicator(
          onRefresh: controller.loadAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (controller.revenue.value != null) RevenueCard(revenue: controller.revenue.value!),
                const SizedBox(height: 16),
                if (controller.salesSummary.value != null) SalesPieChart(summary: controller.salesSummary.value!),
                const SizedBox(height: 16),
                const Text('Country Sales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (controller.countries.isNotEmpty) CountrySalesList(countries: controller.countries),
                const SizedBox(height: 16),
                if (controller.hourlyGrowth.isNotEmpty) HourlyLineChart(hourlyData: controller.hourlyGrowth),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 150,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
