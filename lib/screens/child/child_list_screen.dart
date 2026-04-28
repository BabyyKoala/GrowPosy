import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 Import Service & Models
import '../../models/child_model.dart';
import '../../services/firestore_service.dart';

// 🔥 Import Screens
import '../child/add_child_screen.dart';
import '../growth/growth_chart_screen.dart';
import '../growth/add_growth_screen.dart';

// 🔥 Import Tema
import '../../theme/app_color.dart';

class ChildListScreen extends StatelessWidget {
  const ChildListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    // Mendapatkan userId ibu yang sedang login
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      appBar: AppBar(title: const Text("Data Buah Hati")),

      // 🔥 TOMBOL TAMBAH ANAK (FLOATING)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColor.primaryGreen,
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddChildScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Tambah",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<List<ChildModel>>(
        // 🔥 Asumsi: firestore.getChildren() hanya mengambil data anak milik Ibu ini saja
        // Jika belum, pastikan query Anda: collection('children').where('userId', isEqualTo: currentUserId)
        stream: firestore.getChildren(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final children = snapshot.data!;

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: 100,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              final isBoy = child.gender == 'L';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColor.borderGrey),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.textBlack.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 INFO ANAK UTAMA
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: isBoy
                              ? Colors.blue[50]
                              : Colors.pink[50],
                          child: Icon(
                            isBoy ? Icons.face : Icons.face_3,
                            color: isBoy ? Colors.blue : Colors.pink,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                child.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColor.textBlack,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                // 🔥 PENGGUNAAN FITUR BARU: calculatedAgeInMonths (Usia real-time)
                                "Usia: ${child.calculatedAgeInMonths} Bulan",
                                style: const TextStyle(
                                  color: AppColor.textGrey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: AppColor.borderGrey, height: 1),
                    ),

                    // 🔥 BERAT TERAKHIR & TOMBOL AKSI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Stream untuk mengambil berat terakhir
                        StreamBuilder<double?>(
                          stream: firestore.getLastWeight(child.id),
                          builder: (context, weightSnapshot) {
                            if (weightSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text(
                                "Memuat data...",
                                style: TextStyle(
                                  color: AppColor.textLightGrey,
                                  fontSize: 12,
                                ),
                              );
                            }

                            final weight = weightSnapshot.data;
                            if (weight == null) {
                              return const Text(
                                "Belum ada data KMS",
                                style: TextStyle(
                                  color: AppColor.textGrey,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Berat Terakhir",
                                  style: TextStyle(
                                    color: AppColor.textGrey,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  "$weight kg",
                                  style: const TextStyle(
                                    color: AppColor.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // Tombol Aksi
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddGrowthScreen(
                                      childId: child.id,
                                      userId: currentUserId,
                                      childName: child.name,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.add_chart_rounded,
                                color: Colors.blue,
                              ),
                              tooltip: "Input Pertumbuhan",
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColor.primaryGreen.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => GrowthChartScreen(
                                        childId: child.id,
                                        age: child
                                            .calculatedAgeInMonths, // Gunakan usia dinamis
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.auto_graph_rounded,
                                  color: AppColor.primaryGreen,
                                ),
                                tooltip: "Lihat Grafik KMS",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColor.borderGrey.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.child_care_rounded,
              size: 64,
              color: AppColor.textLightGrey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Belum ada data anak.\nSilakan ketuk tombol Tambah di bawah.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColor.textGrey, height: 1.5),
          ),
        ],
      ),
    );
  }
}
