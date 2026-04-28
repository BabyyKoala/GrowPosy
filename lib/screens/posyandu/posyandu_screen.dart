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

  // 🔥 FITUR BARU: Data diperkaya dengan Jam Buka, Kegiatan, dan Kontak Kader
  final List<Map<String, String>> posyanduList = [
    {
      'nama': 'Posyandu Mawar',
      'alamat': 'Jl. Melati No. 12, Desa Sukamaju',
      'jarak': '0.5 km',
      'status': 'Buka Besok',
      'jam_buka': '08:00 - 11:30 WIB',
      'kegiatan': 'Imunisasi Dasar & Timbang Berat Badan',
      'kader': 'Ibu Siti Khadijah',
      'telepon': '081234567890',
    },
    {
      'nama': 'Posyandu Melati',
      'alamat': 'Jl. Anggrek No. 45, Desa Sukamaju',
      'jarak': '1.2 km',
      'status': 'Tutup',
      'jam_buka': '09:00 - 12:00 WIB',
      'kegiatan': 'Pemberian Vitamin A & Cek Stunting',
      'kader': 'Ibu Ratnasari',
      'telepon': '085678901234',
    },
    {
      'nama': 'Posyandu Kenanga',
      'alamat': 'Jl. Dahlia No. 03, Desa Mekar',
      'jarak': '2.8 km',
      'status': 'Tutup',
      'jam_buka': '08:30 - 11:00 WIB',
      'kegiatan': 'Timbang Berat Badan & Edukasi MPASI',
      'kader': 'Ibu Fatimah',
      'telepon': '082134567891',
    },
    {
      'nama': 'Posyandu Cempaka',
      'alamat': 'Jl. Flamboyan No. 10, Desa Mekar',
      'jarak': '3.1 km',
      'status': 'Buka Besok',
      'jam_buka': '08:00 - 12:00 WIB',
      'kegiatan': 'Imunisasi Campak & Cek Ibu Hamil',
      'kader': 'Bidan Ayu',
      'telepon': '081198765432',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Logika Filter Pencarian
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
                    "Temukan pusat layanan kesehatan balita terdekat beserta jadwal operasionalnya.",
                    style: AppTextStyle.bodyText,
                  ),
                  const SizedBox(height: 20),

                  // SEARCH BAR
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
                                              Expanded(
                                                child: Text(
                                                  posyandu['nama']!,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: AppColor.textBlack,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
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
                                          const SizedBox(height: 8),

                                          // 🔥 FITUR BARU: Indikator Kegiatan Singkat
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.event_note_rounded,
                                                size: 14,
                                                color: AppColor.primaryGreen,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  posyandu['kegiatan']!,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColor.textBlack,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
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
                                                "Lihat Detail →",
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

  // 🔥 FITUR BARU: Dialog Detail Lokasi yang Jauh Lebih Lengkap
  void _showLocationDetail(Map<String, String> posyandu) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center Drag Indicator
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Text(posyandu['nama']!, style: AppTextStyle.heading1),
            const SizedBox(height: 8),
            Text(posyandu['alamat']!, style: AppTextStyle.bodyText),
            const SizedBox(height: 20),

            // Informasi Lengkap
            _buildDetailRow(
              Icons.access_time_filled_rounded,
              "Jam Operasional",
              posyandu['jam_buka']!,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.vaccines_rounded,
              "Agenda Utama",
              posyandu['kegiatan']!,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.person_pin_rounded,
              "Penanggung Jawab",
              posyandu['kader']!,
              AppColor.primaryGreen,
            ),

            const SizedBox(height: 32),

            // 🔥 FITUR BARU: Double Action Buttons (Maps & Telepon)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Mengalihkan ke WhatsApp Kader..."),
                          backgroundColor: AppColor.primaryGreen,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.chat_rounded,
                      color: AppColor.primaryGreen,
                      size: 20,
                    ),
                    label: const Text(
                      "Hubungi",
                      style: TextStyle(
                        color: AppColor.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryGreen.withOpacity(0.1),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: AppColor.primaryGreen.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Membuka Google Maps..."),
                          backgroundColor: Colors.indigo,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.directions,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      "Rute",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // Widget Bantuan untuk Item Detail
  Widget _buildDetailRow(
    IconData icon,
    String title,
    String value,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColor.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColor.textBlack,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
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
