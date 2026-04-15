import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/child_model.dart';
import '../growth/add_growth_screen.dart';
import '../growth/growth_chart_screen.dart';

// ==========================
// 🔥 DETEKSI TREN BERAT
// ==========================
String detectWeightTrend(List<Map<String, dynamic>> growth) {
  if (growth.length < 3) return "AMAN";

  int declineCount = 0;

  for (int i = 1; i < growth.length; i++) {
    final prev = (growth[i - 1]['weight'] as num?)?.toDouble() ?? 0;
    final current = (growth[i]['weight'] as num?)?.toDouble() ?? 0;

    if (current < prev - 0.2) {
      declineCount++;
    }
  }

  return declineCount >= 2 ? "TREN MENURUN" : "AMAN";
}

class HomeIbuScreen extends StatelessWidget {
  const HomeIbuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text("Data Anak"), centerTitle: true),

      // ==========================
      // 🔥 LIST DATA ANAK
      // ==========================
      body: StreamBuilder<List<ChildModel>>(
        stream: firestore.getChildren(),
        builder: (context, snapshot) {
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // error
          if (snapshot.hasError) {
            return const Center(child: Text("Terjadi kesalahan"));
          }

          final children = snapshot.data ?? [];

          // kosong
          if (children.isEmpty) {
            return const Center(child: Text("Belum ada data anak"));
          }

          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];

              // proteksi ID kosong
              if (child.id.isEmpty) {
                return const SizedBox();
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==========================
                      // 🔥 HEADER
                      // ==========================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            child.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // 🔥 BUTTON INPUT GROWTH
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddGrowthScreen(childId: child.id),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      Text(
                        "Umur: ${child.age} tahun",
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 10),

                      // ==========================
                      // 🔥 DATA GROWTH
                      // ==========================
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: firestore.getGrowth(child.id),
                        builder: (context, snapshotGrowth) {
                          if (snapshotGrowth.connectionState ==
                              ConnectionState.waiting) {
                            return const Text("Loading...");
                          }

                          if (!snapshotGrowth.hasData ||
                              snapshotGrowth.data!.isEmpty) {
                            return const Text("Belum ada data pertumbuhan");
                          }

                          final growth = snapshotGrowth.data!;

                          final lastWeight =
                              (growth.last['weight'] as num?)?.toDouble() ?? 0;

                          final lastHeight =
                              (growth.last['height'] as num?)?.toDouble() ?? 0;

                          final trend = detectWeightTrend(growth);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Berat: $lastWeight kg"),
                              Text("Tinggi: $lastHeight cm"),

                              const SizedBox(height: 6),

                              // ==========================
                              // 🔥 ALERT
                              // ==========================
                              if (trend == "TREN MENURUN")
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withAlpha(30),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    "⚠️ Berat anak cenderung menurun",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withAlpha(30),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    "Status: Aman",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // ==========================
                      // 🔥 BUTTON GRAFIK
                      // ==========================
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GrowthChartScreen(
                                  childId: child.id,
                                  age: child.age,
                                ),
                              ),
                            );
                          },
                          child: const Text("Lihat Grafik"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // ==========================
      // 🔥 TAMBAH ANAK
      // ==========================
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.pushNamed(context, '/add_child');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
