import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/child_model.dart';

class ChartScreen extends StatelessWidget {
  final ChildModel child;

  const ChartScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(child.name)),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: LineChart(
          LineChartData(
            borderData: FlBorderData(show: true),
            titlesData: FlTitlesData(show: true),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                spots: List.generate(
                  child.growth.length,
                  (i) => FlSpot(i.toDouble(), child.growth[i].weight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
