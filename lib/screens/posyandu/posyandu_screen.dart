import 'package:flutter/material.dart';

// 🔥 Import Tema Global
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

class PosyanduScreen extends StatefulWidget {
  const PosyanduScreen({super.key});

  @override
  State<PosyanduScreen> createState() => _PosyanduScreenState();
}

class _PosyanduScreenState extends State<PosyanduScreen> {
  String searchQuery = '';

  // 🔥 Data Lokasi Posyandu (Nantinya bisa ditarik dari Firestore)
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
    {
      'nama': 'Posyandu Cempaka',
      'alamat': 'Jl. Flamboyan No. 10, Desa Mekar',
      'jarak': '3.1 km',
      'status': 'Buka Besok',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 🔥 Logika Filter Pencarian
    final filteredList = posyanduList.where((posyandu) {
      return posyandu['nama']!.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          posyandu['alamat']!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Lokasi Posyandu", style: AppTextStyle.heading1),
                  const SizedBox(height: 8),
                  const Text(
                    "Temukan pusat layanan kesehatan balita terdekat dari lokasi Anda.",
                    style: AppTextStyle.bodyText,
                  ),
                  const SizedBox(height: 20),

                  // 🔥 SEARCH BAR
                  TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      hintText: "Cari Posyandu atau Desa...",
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColor.textGrey,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // LIST POSYANDU
            Expanded(
              child: filteredList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 10,
                        bottom: 120,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final posyandu = filteredList[index];
                        final isBuka = posyandu['status'] == 'Buka Besok';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColor.borderGrey),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => _showLocationDetail(posyandu),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ICON LOKASI
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColor.primaryGreen
                                            .withOpacity(0.1),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                posyandu['nama']!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: AppColor.textBlack,
                                                ),
                                              ),
                                              Text(
                                                posyandu['jarak']!,
                                                style: const TextStyle(
                                                  color: AppColor.primaryGreen,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
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

                                          // STATUS & ACTION
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: isBuka
                                                      ? Colors.orange
                                                            .withOpacity(0.1)
                                                      : Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
                                              const Text(
                                                "Lihat Rute →",
                                                style: TextStyle(
                                                  color: AppColor.primaryGreen,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

  // 🔥 Dialog Detail Lokasi
  void _showLocationDetail(Map<String, String> posyandu) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(posyandu['nama']!, style: AppTextStyle.heading1),
            const SizedBox(height: 8),
            Text(posyandu['alamat']!, style: AppTextStyle.bodyText),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Membuka Google Maps...")),
                  );
                },
                icon: const Icon(Icons.directions, color: Colors.white),
                label: const Text(
                  "Buka di Google Maps",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
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
          Icon(Icons.location_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Posyandu tidak ditemukan.",
            style: TextStyle(color: AppColor.textGrey),
          ),
        ],
      ),
    );
  }
}
