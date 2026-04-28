import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';

// 🔥 Import Sistem Tema
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

class GrowthChartScreen extends StatelessWidget {
  final String childId;
  final int age;

  const GrowthChartScreen({
    super.key,
    required this.childId,
    required this.age,
  });

  Map<String, double> getWeightRangeByAge(int age) {
    if (age <= 1) return {'min': 3, 'max': 10};
    if (age <= 2) return {'min': 8, 'max': 14};
    if (age <= 3) return {'min': 10, 'max': 16};
    if (age <= 5) return {'min': 12, 'max': 20};
    return {'min': 15, 'max': 25};
  }

  Map<String, double> getHeightRangeByAge(int age) {
    if (age <= 1) return {'min': 50, 'max': 75};
    if (age <= 2) return {'min': 70, 'max': 90};
    if (age <= 3) return {'min': 80, 'max': 100};
    if (age <= 5) return {'min': 95, 'max': 115};
    return {'min': 110, 'max': 130};
  }

  // =========================
  // 🔥 DETEKSI TREN BERAT (Akurasi Standar Posyandu KMS: N, T, 2T)
  // =========================
  String detectWeightTrend(List<Map<String, dynamic>> growth) {
    if (growth.length < 2) return "Data Awal (Belum Ada Tren)";

    final current = (growth.last['weight'] ?? 0).toDouble();
    final prev = (growth[growth.length - 2]['weight'] ?? 0).toDouble();

    if (current < prev) {
      if (growth.length >= 3) {
        final prev2 = (growth[growth.length - 3]['weight'] ?? 0).toDouble();
        if (prev < prev2) {
          return "Turun Berturut-turut (2T) ⚠️"; // Peringatan Keras Gizi Buruk KMS
        }
      }
      return "Turun Bulan Ini (T) 📉";
    } else if (current == prev) {
      return "Tetap / Tidak Naik (T) ⚠️";
    }

    return "Naik (N) 📈";
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final weightRange = getWeightRangeByAge(age);
    final heightRange = getHeightRangeByAge(age);

    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      appBar: AppBar(
        backgroundColor: AppColor.bgWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Grafik KMS Digital",
          style: TextStyle(
            color: AppColor.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestore.getGrowth(childId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primaryGreen),
            );
          }

          final growth = snapshot.data ?? [];

          if (growth.isEmpty) {
            return _buildEmptyState();
          }

          final last = growth.last;
          final weight = (last['weight'] ?? 0).toDouble();
          final height = (last['height'] ?? 0).toDouble();

          // 🔥 Mengambil Data Imunisasi Terakhir untuk Detail
          String imunisasi = last['imunisasi']?.toString() ?? "-";
          if (imunisasi.isEmpty) imunisasi = "-";

          // STATUS LOGIC
          String weightStatus = weight < weightRange['min']!
              ? "KURANG"
              : weight > weightRange['max']!
              ? "BERLEBIH"
              : "NORMAL";
          Color weightColor = weightStatus == "NORMAL"
              ? AppColor.primaryGreen
              : AppColor.errorRed;

          String heightStatus = height < heightRange['min']!
              ? "STUNTING"
              : height > heightRange['max']!
              ? "TINGGI BERLEBIH"
              : "NORMAL";
          Color heightColor = heightStatus == "NORMAL"
              ? AppColor.primaryGreen
              : Colors.orange;

          final trend = detectWeightTrend(growth);
          Color trendColor = trend.contains("⚠️") || trend.contains("Turun")
              ? AppColor.errorRed
              : AppColor.primaryGreen;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ringkasan Pemeriksaan Terakhir",
                  style: AppTextStyle.heading1,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDiagnosisCard(
                        "Berat Terakhir",
                        "$weight kg",
                        weightStatus,
                        weightColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDiagnosisCard(
                        "Tinggi Terakhir",
                        "$height cm",
                        heightStatus,
                        heightColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 🔥 KARTU BARU: INFORMASI IMUNISASI
                _buildImmunizationCard(imunisasi),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: trendColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.analytics_outlined, color: trendColor),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tren Pertumbuhan (Standar KMS)",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColor.textGrey,
                            ),
                          ),
                          Text(
                            trend,
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
                ),

                const SizedBox(height: 40),

                // 🔥 GRAFIK BERAT BADAN
                const Text(
                  "Grafik Berat Badan (kg)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textBlack,
                  ),
                ),
                const SizedBox(height: 16),
                _buildChartBox(growth, 'weight', AppColor.primaryGreen),

                const SizedBox(height: 40),

                // 🔥 GRAFIK TINGGI BADAN
                const Text(
                  "Grafik Tinggi Badan (cm)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textBlack,
                  ),
                ),
                const SizedBox(height: 16),
                _buildChartBox(growth, 'height', Colors.blue),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================
  // 🎨 WIDGET KARTU DIAGNOSIS
  // =========================
  Widget _buildDiagnosisCard(
    String title,
    String value,
    String status,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColor.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColor.textBlack,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 WIDGET BARU: KARTU IMUNISASI
  Widget _buildImmunizationCard(String imunisasi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.vaccines, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Imunisasi Diterima",
                  style: TextStyle(color: AppColor.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  imunisasi,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // 🎨 WIDGET GRAFIK FL_CHART
  // =========================
  Widget _buildChartBox(
    List<Map<String, dynamic>> growth,
    String key,
    Color lineColor,
  ) {
    double maxY = 0;
    for (var data in growth) {
      double val = (data[key] ?? 0).toDouble();
      if (val > maxY) maxY = val;
    }
    maxY = maxY + (key == 'weight' ? 5 : 20);

    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 24, right: 24, left: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: growth.length > 1 ? (growth.length - 1).toDouble() : 1,
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: key == 'weight' ? 5 : 20,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColor.borderGrey,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= growth.length) {
                    return const SizedBox.shrink();
                  }

                  final date = (growth[index]['date'] as Timestamp).toDate();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('d MMM').format(date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColor.textGrey,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: key == 'weight' ? 5 : 20,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColor.textGrey,
                  ),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: false,
              color: lineColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withOpacity(0.1),
              ),
              spots: List.generate(growth.length, (index) {
                return FlSpot(
                  index.toDouble(),
                  (growth[index][key] ?? 0).toDouble(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Icon(Icons.show_chart_rounded, size: 64, color: AppColor.borderGrey),
          const SizedBox(height: 16),
          const Text(
            "Belum ada data pertumbuhan.\nKader akan mengisi data ini saat posyandu.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColor.textGrey),
          ),
        ],
      ),
    );
  }
}
