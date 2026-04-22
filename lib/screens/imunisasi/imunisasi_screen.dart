import 'package:flutter/material.dart';

// 🔥 Import Sistem Tema
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

class ImunisasiScreen extends StatefulWidget {
  const ImunisasiScreen({super.key});

  @override
  State<ImunisasiScreen> createState() => _ImunisasiScreenState();
}

class _ImunisasiScreenState extends State<ImunisasiScreen> {
  // ==========================================
  // 💾 DATA DUMMY (Nantinya diganti fetch dari Firebase)
  // ==========================================
  final List<Map<String, dynamic>> jadwalImunisasi = [
    {
      "usia": "0 Bulan",
      "vaksin": "Hepatitis B0, Polio 1",
      "status": "Selesai",
      "tanggal": "12 Jan 2024",
    },
    {
      "usia": "1 Bulan",
      "vaksin": "BCG, Polio 2",
      "status": "Selesai",
      "tanggal": "15 Feb 2024",
    },
    {
      "usia": "2 Bulan",
      "vaksin": "DPT-HB-Hib 1, Polio 3",
      "status": "Selesai",
      "tanggal": "14 Mar 2024",
    },
    {
      "usia": "3 Bulan",
      "vaksin": "DPT-HB-Hib 2, Polio 4",
      "status": "Selesai",
      "tanggal": "16 Apr 2024",
    },
    {
      "usia": "4 Bulan",
      "vaksin": "DPT-HB-Hib 3, Polio 5, IPV",
      "status": "Belum",
      "tanggal": "-",
    },
    {
      "usia": "9 Bulan",
      "vaksin": "Campak / MR",
      "status": "Belum",
      "tanggal": "-",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      appBar: AppBar(
        backgroundColor: AppColor.bgWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Buku Imunisasi",
          style: TextStyle(
            color: AppColor.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 HEADER INFO
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColor.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColor.primaryGreen,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Jadwal imunisasi disesuaikan dengan standar Kementerian Kesehatan RI.",
                      style: TextStyle(
                        color: AppColor.primaryGreen,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔥 LIST JADWAL
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: jadwalImunisasi.length,
              itemBuilder: (context, index) {
                final item = jadwalImunisasi[index];
                final isDone = item['status'] == 'Selesai';

                return _buildImunisasiCard(item, isDone);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🎨 WIDGET KARTU IMUNISASI
  // ==========================================
  Widget _buildImunisasiCard(Map<String, dynamic> item, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDone ? AppColor.primaryGreen.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone
              ? AppColor.primaryGreen.withOpacity(0.5)
              : AppColor.borderGrey,
          width: isDone ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isDone)
            BoxShadow(
              color: AppColor.primaryGreen.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔵 IKON STATUS
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDone
                  ? AppColor.primaryGreen
                  : AppColor.borderGrey.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check_rounded : Icons.vaccines_rounded,
              color: isDone ? Colors.white : AppColor.textGrey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // 🔵 DETAIL KONTEN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Usia ${item['usia']}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDone
                            ? AppColor.primaryGreen
                            : AppColor.textBlack,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColor.primaryGreen.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['status'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDone ? AppColor.primaryGreen : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item['vaksin'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColor.textBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: isDone ? AppColor.textGrey : Colors.transparent,
                    ),
                    if (isDone) const SizedBox(width: 6),
                    Text(
                      isDone
                          ? "Diberikan pada: ${item['tanggal']}"
                          : "Belum diberikan",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDone ? AppColor.textGrey : AppColor.borderGrey,
                        fontStyle: isDone ? FontStyle.normal : FontStyle.italic,
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
  }
}
