import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../domain/entities/dashboard_entities.dart';

class HourlyLineChart extends StatelessWidget {
  final List<HourlyGrowthEntity> hourlyData;
  const HourlyLineChart({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCartesianChart(
          title: const ChartTitle(text: 'Hourly Growth'),
          primaryXAxis: const CategoryAxis(title: AxisTitle(text: 'Hour')),
          primaryYAxis: const NumericAxis(title: AxisTitle(text: 'Purchase Amount')),
          series: <CartesianSeries>[
            LineSeries<HourlyGrowthEntity, String>(
              dataSource: hourlyData,
              xValueMapper: (item, _) => item.label,
              yValueMapper: (item, _) => item.amount,
              markerSettings: const MarkerSettings(isVisible: true),
              color: Colors.blueAccent,
            )
          ],
        ),
      ),
    );
  }
}
