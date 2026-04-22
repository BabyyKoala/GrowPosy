import 'package:flutter/material.dart';

// 🔥 Import Sistem Tema
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

// 🔥 PERBAIKAN 1: Import layar detail artikel agar bisa diakses
// Pastikan path import ini sesuai dengan struktur foldermu.
// Jika kedua file ini berada dalam satu folder, cukup gunakan:
// import 'article_detail_screen.dart';
import 'article_detail_screen.dart';

class EdukasiScreen extends StatefulWidget {
  const EdukasiScreen({super.key});

  @override
  State<EdukasiScreen> createState() => _EdukasiScreenState();
}

class _EdukasiScreenState extends State<EdukasiScreen> {
  String selectedCategory = 'Semua';
  String searchQuery = '';

  // 🔥 Mock Data (Data Dummy) Artikel
  // Menambahkan field 'content' agar setiap artikel punya isi yang berbeda
  final List<Map<String, dynamic>> articles = [
    {
      'title': 'Menu MPASI Sehat 6-9 Bulan Tanpa Ribet',
      'category': 'Nutrisi',
      'time': '5 min read',
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'content':
          'Memasuki usia 6 bulan, kebutuhan gizi bayi mulai meningkat dan ASI saja tidak lagi cukup. Memulai MPASI (Makanan Pendamping ASI) adalah langkah penting.\n\nKunci utamanya adalah memberikan makanan yang kaya akan zat besi dan mudah dicerna. Contoh menu tanpa ribet: Bubur halus hati ayam dengan tambahan sedikit margarin/minyak kelapa, atau pure kentang campur daging sapi giling halus.\n\nPastikan tekstur makanan disesuaikan dengan kemampuan mengunyah bayi Anda. Mulailah dengan tekstur lumat (puree) dan perlahan naik ke tekstur cincang halus.',
    },
    {
      'title': 'Jadwal Imunisasi Dasar Lengkap Kemenkes',
      'category': 'Kesehatan',
      'time': '4 min read',
      'icon': Icons.vaccines,
      'color': Colors.blue,
      'content':
          'Imunisasi adalah perlindungan terbaik agar balita terhindar dari penyakit berbahaya. Berikut adalah jadwal standar imunisasi dasar menurut Kementerian Kesehatan RI:\n\n- Umur 0 bulan: Hepatitis B0\n- Umur 1 bulan: BCG, Polio 1\n- Umur 2 bulan: DPT-HB-Hib 1, Polio 2, Rotavirus\n- Umur 3 bulan: DPT-HB-Hib 2, Polio 3, Rotavirus\n- Umur 4 bulan: DPT-HB-Hib 3, Polio 4, IPV\n- Umur 9 bulan: Campak/MR\n\nBawalah anak ke Posyandu atau Puskesmas secara rutin agar tidak tertinggal jadwal imunisasinya.',
    },
    {
      'title': 'Tips Menstimulasi Motorik Kasar Bayi',
      'category': 'Perkembangan',
      'time': '6 min read',
      'icon': Icons.toys,
      'color': Colors.purple,
      'content':
          'Perkembangan motorik kasar mencakup kemampuan duduk, merangkak, berdiri, dan berjalan. Stimulasi yang tepat dari orang tua sangat dibutuhkan.\n\n1. Tummy Time: Lakukan sejak dini untuk memperkuat otot leher dan punggung bayi.\n2. Pancing dengan Mainan: Letakkan mainan favorit sedikit di luar jangkauan untuk merangsang bayi merangkak maju.\n3. Pegangan yang Aman: Sediakan area yang aman bagi bayi untuk belajar merambat atau berdiri berpegangan pada furnitur.\n\nSetiap anak berkembang dengan kecepatan berbeda, jadi jangan memaksakan jika bayi belum siap.',
    },
    {
      'title': 'Mendeteksi Gejala Awal Stunting pada Anak',
      'category': 'Kesehatan',
      'time': '7 min read',
      'icon': Icons.warning_amber_rounded,
      'color': AppColor.errorRed,
      'content':
          'Stunting bukan sekadar tubuh pendek, melainkan kondisi gagal tumbuh akibat kurang gizi kronis di 1000 Hari Pertama Kehidupan. Kondisi ini juga memengaruhi perkembangan kecerdasan otak anak.\n\nGejala Awal yang Perlu Diwaspadai:\n1. Pertumbuhan gigi terlambat.\n2. Performa atau memori belajar yang buruk saat masuk usia pra-sekolah.\n3. Anak menjadi lebih pendiam dan tidak banyak melakukan *eye contact* di usia 8-10 bulan.\n4. Pertumbuhan tinggi badan yang melambat (berada di bawah garis merah pada kurva KMS).\n\nJika menemui tanda tersebut, segera intervensi dengan memperbaiki nutrisi MPASI dan berkonsultasi ke ahlinya.',
    },
    {
      'title': 'Resep Camilan Tinggi Kalori Penambah Berat Badan',
      'category': 'Nutrisi',
      'time': '4 min read',
      'icon': Icons.ramen_dining,
      'color': Colors.orange,
      'content':
          'Banyak ibu khawatir ketika berat badan si kecil susah naik. Solusinya bukan memberikan camilan manis berlebihan, tetapi camilan sehat padat kalori (Double Protein/Karbo).\n\nCoba resep ini: Perkedel Kentang Keju Telur Puyuh.\nKukus kentang hingga empuk, haluskan. Campur dengan telur puyuh rebus yang sudah dilumatkan, sedikit daging ayam cincang, dan parutan keju. Bentuk bulat-bulat lalu goreng dengan mentega.\n\nCamilan ini tidak hanya lezat, tetapi mengandung karbohidrat, protein hewani, dan lemak sehat yang efektif mendongkrak berat badan balita secara aman.',
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
                      return _buildArticleCard(
                        context,
                        article,
                      ); // Melempar context
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

  Widget _buildArticleCard(BuildContext context, Map<String, dynamic> article) {
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
            // 🔥 PERBAIKAN 2: Navigasi ke halaman baca artikel detail
            // Mengirimkan data artikel spesifik ke ArticleDetailScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleDetailScreen(
                  title: article['title'],
                  category: article['category'],
                  time: article['time'],
                  content: article['content'],
                  icon: article['icon'],
                  color: article['color'],
                ),
              ),
            );
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
