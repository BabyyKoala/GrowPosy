import 'package:flutter/material.dart';

// 🔥 Import Sistem Tema
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

class EdukasiScreen extends StatefulWidget {
  const EdukasiScreen({super.key});

  @override
  State<EdukasiScreen> createState() => _EdukasiScreenState();
}

class _EdukasiScreenState extends State<EdukasiScreen> {
  String selectedCategory = 'Semua';
  String searchQuery = '';

  // 🔥 Mock Data (Data Dummy) Artikel
  // Nantinya data ini bisa kamu pindahkan ke Firestore jika ingin artikelnya dinamis
  final List<Map<String, dynamic>> articles = [
    {
      'title': 'Menu MPASI Sehat 6-9 Bulan Tanpa Ribet',
      'category': 'Nutrisi',
      'time': '5 min read',
      'icon': Icons.restaurant,
      'color': Colors.orange,
    },
    {
      'title': 'Jadwal Imunisasi Dasar Lengkap Kemenkes',
      'category': 'Kesehatan',
      'time': '4 min read',
      'icon': Icons.vaccines,
      'color': Colors.blue,
    },
    {
      'title': 'Tips Menstimulasi Motorik Kasar Bayi',
      'category': 'Perkembangan',
      'time': '6 min read',
      'icon': Icons.toys,
      'color': Colors.purple,
    },
    {
      'title': 'Mendeteksi Gejala Awal Stunting pada Anak',
      'category': 'Kesehatan',
      'time': '7 min read',
      'icon': Icons.warning_amber_rounded,
      'color': AppColor.errorRed,
    },
    {
      'title': 'Resep Camilan Tinggi Kalori Penambah Berat Badan',
      'category': 'Nutrisi',
      'time': '4 min read',
      'icon': Icons.ramen_dining,
      'color': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 🔥 Logika Filter Berdasarkan Pencarian & Kategori
    final filteredArticles = articles.where((article) {
      final matchCategory =
          selectedCategory == 'Semua' ||
          article['category'] == selectedCategory;
      final matchSearch = article['title'].toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      return matchCategory && matchSearch;
    }).toList();

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
          "Portal Edukasi",
          style: TextStyle(
            color: AppColor.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 HEADER & SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Temukan Artikel", style: AppTextStyle.heading1),
                const SizedBox(height: 8),
                const Text(
                  "Pilih bacaan yang tepat untuk mendukung tumbuh kembang si kecil.",
                  style: AppTextStyle.bodyText,
                ),
                const SizedBox(height: 20),

                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: "Cari topik (mis. MPASI, Imunisasi)",
                    hintStyle: const TextStyle(color: AppColor.textGrey),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColor.textGrey,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColor.primaryGreen,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔥 KATEGORI CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 10.0,
            ),
            child: Row(
              children: ['Semua', 'Nutrisi', 'Kesehatan', 'Perkembangan'].map((
                category,
              ) {
                final isSelected = selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColor.primaryGreen : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColor.primaryGreen
                            : AppColor.borderGrey,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColor.textBlack,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 🔥 DAFTAR ARTIKEL
          Expanded(
            child: filteredArticles.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 10.0,
                    ),
                    itemCount: filteredArticles.length,
                    itemBuilder: (context, index) {
                      final article = filteredArticles[index];
                      return _buildArticleCard(article);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // WIDGET COMPONENTS
  // ==========================

  Widget _buildArticleCard(Map<String, dynamic> article) {
    final Color color = article['color'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // TODO: Navigasi ke halaman baca artikel detail
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(article['icon'], color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          article['category'],
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppColor.textGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            article['time'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColor.textGrey,
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
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppColor.borderGrey),
          const SizedBox(height: 16),
          const Text(
            "Artikel tidak ditemukan.\nCoba kata kunci lain.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColor.textGrey, height: 1.5),
          ),
        ],
      ),
    );
  }
}
