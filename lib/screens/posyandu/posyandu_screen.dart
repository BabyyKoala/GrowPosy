import 'package:flutter/material.dart';

// 🔥 Import Tema Global
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

class PosyanduScreen extends StatelessWidget {
  const PosyanduScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 Data Dummy Lokasi Posyandu
    final List<Map<String, String>> posyanduList = [
      {
        'nama': 'Posyandu Mawar',
        'alamat': 'Jl. Melati No. 12, Desa Sukamaju',
        'jarak': '0.5 km',
        'status': 'Buka Besok',
      },
      {
        'nama': 'Posyandu Melati',
        'alamat': 'Jl. Anggrek No. 45, Desa Sukamaju',
        'jarak': '1.2 km',
        'status': 'Tutup',
      },
      {
        'nama': 'Posyandu Kenanga',
        'alamat': 'Jl. Dahlia No. 03, Desa Mekar',
        'jarak': '2.8 km',
        'status': 'Tutup',
      },
    ];

    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      // SafeArea agar tidak tertabrak notch HP
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: Text("Lokasi Posyandu", style: AppTextStyle.heading1),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Temukan pusat layanan kesehatan balita terdekat dari lokasi Anda.",
                style: AppTextStyle.bodyText,
              ),
            ),
            const SizedBox(height: 20),

            // LIST POSYANDU
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 120,
                ), // Padding bawah untuk Floating Navbar
                itemCount: posyanduList.length,
                itemBuilder: (context, index) {
                  final posyandu = posyanduList[index];
                  final isBuka = posyandu['status'] == 'Buka Besok';

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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ICON LOKASI
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColor.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppColor.primaryGreen,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // INFO POSYANDU
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                posyandu['nama']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColor.textBlack,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                posyandu['alamat']!,
                                style: const TextStyle(
                                  color: AppColor.textGrey,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isBuka
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      posyandu['status']!,
                                      style: TextStyle(
                                        color: isBuka
                                            ? Colors.orange
                                            : AppColor.textGrey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    posyandu['jarak']!,
                                    style: const TextStyle(
                                      color: AppColor.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
