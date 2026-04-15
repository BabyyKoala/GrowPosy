import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class GrowthChartScreen extends StatelessWidget {
  final String childId;
  final int age;

  const GrowthChartScreen({
    super.key,
    required this.childId,
    required this.age,
  });

  // =========================
  // 🔥 RANGE BERAT
  // =========================
  Map<String, double> getWeightRangeByAge(int age) {
    if (age <= 1) return {'min': 3, 'max': 10};
    if (age <= 2) return {'min': 8, 'max': 14};
    if (age <= 3) return {'min': 10, 'max': 16};
    if (age <= 5) return {'min': 12, 'max': 20};
    return {'min': 15, 'max': 25};
  }

  // =========================
  // 🔥 RANGE TINGGI
  // =========================
  Map<String, double> getHeightRangeByAge(int age) {
    if (age <= 1) return {'min': 50, 'max': 75};
    if (age <= 2) return {'min': 70, 'max': 90};
    if (age <= 3) return {'min': 80, 'max': 100};
    if (age <= 5) return {'min': 95, 'max': 115};
    return {'min': 110, 'max': 130};
  }

  // =========================
  // 🔥 CONVERT TIME
  // =========================
  double toDays(Timestamp timestamp) {
    return timestamp.toDate().millisecondsSinceEpoch / 100000000;
  }

  // =========================
  // 🔥 DETEKSI TREN BERAT
  // =========================
  String detectWeightTrend(List<Map<String, dynamic>> growth) {
    if (growth.length < 3) return "DATA KURANG";

    int declineCount = 0;

    for (int i = 1; i < growth.length; i++) {
      final prev = (growth[i - 1]['weight'] ?? 0).toDouble();
      final current = (growth[i]['weight'] ?? 0).toDouble();

      // 🔥 filter noise kecil
      if (current < prev - 0.2) {
        declineCount++;
      }
    }

    if (declineCount >= 2) {
      return "TREN MENURUN ⚠️";
    } else if (declineCount == 1) {
      return "SEDIKIT TURUN";
    } else {
      return "STABIL / NAIK";
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    final weightRange = getWeightRangeByAge(age);
    final heightRange = getHeightRangeByAge(age);

    return Scaffold(
      appBar: AppBar(title: const Text("Grafik Pertumbuhan")),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestore.getGrowth(childId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final growth = snapshot.data!;

          if (growth.isEmpty) {
            return const Center(child: Text("Belum ada data"));
          }

          final last = growth.last;

          final weight = (last['weight'] ?? 0).toDouble();
          final height = (last['height'] ?? 0).toDouble();

          // =========================
          // 🔥 STATUS BERAT
          // =========================
          String weightStatus;
          if (weight < weightRange['min']!) {
            weightStatus = "KURANG";
          } else if (weight > weightRange['max']!) {
            weightStatus = "BERLEBIH";
          } else {
            weightStatus = "NORMAL";
          }

          // =========================
          // 🔥 STATUS TINGGI
          // =========================
          String heightStatus;
          Color heightColor;

          if (height < heightRange['min']!) {
            heightStatus = "STUNTING";
            heightColor = Colors.orange;
          } else if (height > heightRange['max']!) {
            heightStatus = "TINGGI BERLEBIH";
            heightColor = Colors.blue;
          } else {
            heightStatus = "NORMAL";
            heightColor = Colors.green;
          }

          // =========================
          // 🔥 DETEKSI TREN
          // =========================
          final trend = detectWeightTrend(growth);

          Color trendColor;
          if (trend.contains("MENURUN")) {
            trendColor = Colors.red;
          } else if (trend.contains("SEDIKIT")) {
            trendColor = Colors.orange;
          } else {
            trendColor = Colors.green;
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // =========================
                // 🔥 GRAFIK
                // =========================
                Expanded(
                  child: LineChart(
                    LineChartData(
                      borderData: FlBorderData(show: true),

                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final date = DateTime.fromMillisecondsSinceEpoch(
                                (value * 100000000).toInt(),
                              );

                              return Text(
                                "${date.day}/${date.month}",
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),

                      lineBarsData: [
                        // 🔥 BERAT
                        LineChartBarData(
                          isCurved: true,
                          spots: growth.map((e) {
                            final t = e['date'] as Timestamp;
                            return FlSpot(
                              toDays(t),
                              (e['weight'] ?? 0).toDouble(),
                            );
                          }).toList(),
                        ),

                        // 🔥 TINGGI
                        LineChartBarData(
                          isCurved: true,
                          spots: growth.map((e) {
                            final t = e['date'] as Timestamp;
                            return FlSpot(
                              toDays(t),
                              (e['height'] ?? 0).toDouble(),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =========================
                // 🔥 STATUS + TREND
                // =========================
                Column(
                  children: [
                    Text(
                      "Status Berat: $weightStatus",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Status Tinggi: $heightStatus",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: heightColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🔥 TREND
                    Text(
                      "Tren Berat: $trend",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
