import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../domain/entities/dashboard_entities.dart';

class SalesPieChart extends StatelessWidget {
  final SalesSummaryEntity summary;
  const SalesPieChart({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCircularChart(
          title: const ChartTitle(text: 'Sales Summary'),
          legend: const Legend(isVisible: true, position: LegendPosition.bottom),
          series: <CircularSeries>[
            PieSeries<SalesSummaryItem, String>(
              dataSource: [
                SalesSummaryItem('Successful', summary.successful.count),
                SalesSummaryItem('Cancelled', summary.cancelled.count),
              ],
              xValueMapper: (item, _) => item.label,
              yValueMapper: (item, _) => item.count,
              pointColorMapper: (item, _) => item.label == 'Successful' ? Colors.green : Colors.red,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            )
          ],
        ),
      ),
    );
  }
}
