import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 Import Service & Models
import '../../models/child_model.dart';
import '../../services/firestore_service.dart';

// 🔥 Import Screens
import '../child/add_child_screen.dart';
import '../growth/growth_chart_screen.dart';
import '../growth/add_growth_screen.dart'; // Menggunakan screen input yang sudah tervalidasi

// 🔥 Import Tema
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

class ChildListScreen extends StatelessWidget {
  const ChildListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    // Mendapatkan userId ibu yang sedang login
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      appBar: AppBar(
        backgroundColor: AppColor.bgWhite,
        elevation: 0,
        title: const Text(
          "Data Buah Hati",
          style: TextStyle(
            color: AppColor.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // 🔥 TOMBOL TAMBAH ANAK (FLOATING)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColor.primaryGreen,
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
        stream: firestore.getChildren(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColor.primaryGreen),
            );
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
                      color: Colors.black.withOpacity(0.03),
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
                                "Umur: ${child.age} Bulan",
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
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColor.borderGrey),
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
                                  color: AppColor.textGrey,
                                  fontSize: 12,
                                ),
                              );
                            }

                            final weight = weightSnapshot.data;
                            if (weight == null) {
                              return const Text(
                                "Belum ada data berat",
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
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // Tombol Aksi
                        Row(
                          children: [
                            // Tombol Input Mandiri (Jika Ibu ingin input sendiri)
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddGrowthScreen(
                                      childId: child.id,
                                      userId: currentUserId, // Mengirim ID Ibu
                                      childName:
                                          child.name, // Mengirim Nama Anak
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.add_chart_rounded,
                                color: Colors.blue,
                              ),
                              tooltip: "Input Pertumbuhan Mandiri",
                            ),

                            // Tombol Lihat Grafik KMS
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
                                        age: child.age,
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
              color: AppColor.borderGrey.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.child_care_rounded,
              size: 64,
              color: AppColor.textGrey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Belum ada data anak.\nSilakan tekan tombol tambah di bawah.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColor.textGrey, height: 1.5),
          ),
        ],
      ),
    );
  }
}
