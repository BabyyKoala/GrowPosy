import 'package:flutter/material.dart';

// 🔥 Import Service & Model
import '../../services/firestore_service.dart';
import '../../models/child_model.dart';

// 🔥 Import Sistem Tema
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

// 🔥 Import Semua Screen Modular
import '../growth/growth_chart_screen.dart';
// import '../child/child_list_screen.dart'; // ❌ KITA MATIKAN: Ini layar milik Kader
import '../posyandu/posyandu_screen.dart';
import '../edukasi/edukasi_screen.dart';
import '../profil/profil_screen.dart';

// 🔥 IMPORT HALAMAN BARU
import '../imunisasi/imunisasi_screen.dart';
import '../edukasi/article_detail_screen.dart';

class HomeIbuScreen extends StatefulWidget {
  const HomeIbuScreen({super.key});

  @override
  State<HomeIbuScreen> createState() => _HomeIbuScreenState();
}

class _HomeIbuScreenState extends State<HomeIbuScreen> {
  int _selectedIndex = 0;
  int _selectedChildIndex = 0;

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    // ==========================================
    // 🚀 DAFTAR HALAMAN NAVBAR KHUSUS IBU
    // ==========================================
    final List<Widget> pages = [
      _buildMainDashboard(firestore), // Index 0: Beranda
      _buildIbuChildList(
        firestore,
      ), // 🔥 Index 1: PERBAIKAN - Daftar Anak Khusus Ibu (Hanya Lihat Grafik)
      const PosyanduScreen(), // Index 2: Lokasi Posyandu
      const EdukasiScreen(), // Index 3: Portal Edukasi
      const ProfilScreen(), // Index 4: Profil
    ];

    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: pages),
          _buildFloatingNavBar(),
        ],
      ),
    );
  }

  // ==========================================
  // 🔥 TAB 1: DAFTAR ANAK KHUSUS IBU (ANTI-INPUT)
  // ==========================================
  Widget _buildIbuChildList(FirestoreService firestore) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text("Pantau Grafik Anak", style: AppTextStyle.heading1),
          ),
          Expanded(
            child: StreamBuilder<List<ChildModel>>(
              stream: firestore.getChildren(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryGreen,
                    ),
                  );
                }

                final children = snapshot.data ?? [];
                if (children.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada profil anak. Tambahkan di Beranda.",
                      style: TextStyle(color: AppColor.textGrey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColor.borderGrey),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: AppColor.primaryGreen.withOpacity(
                            0.1,
                          ),
                          child: const Icon(
                            Icons.face,
                            color: AppColor.primaryGreen,
                          ),
                        ),
                        title: Text(
                          child.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColor.textBlack,
                          ),
                        ),
                        subtitle: Text("Usia: ${child.age} bulan"),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColor.primaryGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.show_chart,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onTap: () {
                          // 🔥 IBU HANYA BISA MASUK KE GRAFIK (VIEW ONLY)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GrowthChartScreen(
                                childId: child.id,
                                age: child.age,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 0: DASHBOARD UTAMA (BERANDA)
  // ==========================================
  Widget _buildMainDashboard(FirestoreService firestore) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopProfileHeader(),
            _buildChildSelector(firestore),
            _buildGrowthStatusCard(
              firestore,
            ), // 🔥 Diperbarui dengan data Real-time
            _buildQuickMenu(),
            _buildSectionTitle(
              "Jadwal Mendatang",
              "Lihat Semua",
              () => setState(() => _selectedIndex = 2),
            ),
            _buildUpcomingSchedule(),
            _buildSectionTitle(
              "Edukasi Pilihan",
              "Semua",
              () => setState(() => _selectedIndex = 3),
            ),
            _buildHorizontalArticleList(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // KOMPONEN DASHBOARD BERANDA
  // ==========================================

  Widget _buildTopProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColor.borderGrey,
            backgroundImage: AssetImage('assets/images/avatar_ibu.png'),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo Bunda 👋",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textBlack,
                ),
              ),
              Text(
                "Pantau tumbuh kembang si kecil",
                style: TextStyle(color: AppColor.textGrey, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.borderGrey),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 22,
              color: AppColor.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildSelector(FirestoreService firestore) {
    return StreamBuilder<List<ChildModel>>(
      stream: firestore.getChildren(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 80);

        final children = snapshot.data!;
        return Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 24),
            itemCount: children.length + 1,
            itemBuilder: (context, index) {
              if (index == children.length) {
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/add_child'),
                  child: Container(
                    margin: const EdgeInsets.only(right: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColor.bgWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColor.primaryGreen,
                        width: 1.5,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: AppColor.primaryGreen, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "Tambah",
                          style: TextStyle(
                            color: AppColor.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final child = children[index];
              bool isSelected = _selectedChildIndex == index;

              return GestureDetector(
                onTap: () => setState(() => _selectedChildIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColor.primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColor.primaryGreen
                          : AppColor.borderGrey,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColor.primaryGreen.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      child.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColor.textBlack,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGrowthStatusCard(FirestoreService firestore) {
    return StreamBuilder<List<ChildModel>>(
      stream: firestore.getChildren(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColor.borderGrey),
            ),
            child: const Center(
              child: Text(
                "Silakan tambah profil anak terlebih dahulu.",
                style: TextStyle(color: AppColor.textGrey),
              ),
            ),
          );
        }

        final validIndex = _selectedChildIndex < snapshot.data!.length
            ? _selectedChildIndex
            : 0;
        final child = snapshot.data![validIndex];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.auto_graph_rounded,
                        color: AppColor.primaryGreen,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Status Pertumbuhan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "TERBARU",
                      style: TextStyle(
                        color: AppColor.primaryGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 🔥 PERBAIKAN: MENGAMBIL DATA ASLI DARI FIREBASE (BUKAN DUMMY)
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: firestore.getGrowth(child.id),
                builder: (context, growthSnap) {
                  String weight = "-";
                  String height = "-";

                  if (growthSnap.hasData && growthSnap.data!.isNotEmpty) {
                    final latestData =
                        growthSnap.data!.last; // Data paling ujung (terbaru)
                    weight = latestData['weight'].toString();
                    height = latestData['height'].toString();
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSmallStat("Berat", weight, "kg"),
                      _buildSmallStat("Tinggi", height, "cm"),
                      _buildSmallStat(
                        "Lingkar",
                        "-",
                        "cm",
                      ), // Belum diimplementasikan
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 🔥 TOMBOL INI HANYA MEMBUKA GRAFIK KMS (VIEW ONLY)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GrowthChartScreen(
                          childId: child.id,
                          age: child.age,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Lihat Detail Grafik KMS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSmallStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColor.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  color: AppColor.primaryGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
              TextSpan(
                text: " $unit",
                style: const TextStyle(
                  color: AppColor.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickMenu() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _quickIconItem(
            Icons.face_rounded,
            "Data Anak",
            Colors.blue,
            () => setState(() => _selectedIndex = 1),
          ),
          _quickIconItem(Icons.vaccines, "Imunisasi", Colors.orange, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ImunisasiScreen()),
            );
          }),
          _quickIconItem(
            Icons.location_on,
            "Posyandu",
            AppColor.primaryGreen,
            () => setState(() => _selectedIndex = 2),
          ),
          _quickIconItem(
            Icons.menu_book,
            "Edukasi",
            Colors.purple,
            () => setState(() => _selectedIndex = 3),
          ),
        ],
      ),
    );
  }

  Widget _quickIconItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColor.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String t, String a, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            t,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: onAction,
            child: Text(
              a,
              style: const TextStyle(
                color: AppColor.primaryGreen,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSchedule() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.borderGrey),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.errorRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text(
                  "15",
                  style: TextStyle(
                    color: AppColor.errorRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "Apr",
                  style: TextStyle(
                    color: AppColor.errorRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Posyandu Mawar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  "Imunisasi Dasar & Vitamin A",
                  style: TextStyle(color: AppColor.textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColor.textGrey),
        ],
      ),
    );
  }

  Widget _buildHorizontalArticleList() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 24),
        children: [
          _buildMiniArticleCard(
            "Nutrisi",
            "Menu MPASI Sehat 6-9 Bulan",
            Colors.orange,
          ),
          _buildMiniArticleCard(
            "Kesehatan",
            "Pentingnya Imunisasi Dasar",
            Colors.blue,
          ),
          _buildMiniArticleCard(
            "Tumbuh",
            "Mendeteksi Gejala Stunting",
            AppColor.errorRed,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniArticleCard(String category, String title, Color color) {
    return GestureDetector(
      onTap: () {
        // 🔥 PERBAIKAN: Menambahkan parameter yang dibutuhkan ArticleDetailScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(
              title: title,
              category: category,
              color: color,
              // Karena ini Mini Card statis, kita berikan data konten dummy default
              // Kamu bisa menyesuaikan teks ini jika mau
              time: "5 min read",
              icon: Icons.menu_book_rounded,
              content:
                  "Ini adalah artikel singkat mengenai $category. \n\nMembaca informasi seputar $title sangat penting untuk menunjang tumbuh kembang anak Anda agar tetap sehat dan ceria. Jangan ragu untuk selalu berkonsultasi dengan kader posyandu atau bidan terdekat untuk informasi lebih lanjut.",
            ),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            const Text(
              "Baca selengkapnya",
              style: TextStyle(color: AppColor.textGrey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FLOATING BOTTOM NAVBAR
  // ==========================================
  Widget _buildFloatingNavBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navIconItem(Icons.home_rounded, "Beranda", 0),
            _navIconItem(Icons.face_rounded, "Anak", 1),
            _navIconItem(Icons.location_on_rounded, "Posyandu", 2),
            _navIconItem(Icons.menu_book_rounded, "Edukasi", 3),
            _navIconItem(Icons.person_rounded, "Profil", 4),
          ],
        ),
      ),
    );
  }

  Widget _navIconItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primaryGreen.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColor.primaryGreen : AppColor.textGrey,
              size: 24,
            ),
            if (isSelected) const SizedBox(height: 4),
            if (isSelected)
              Text(
                label,
                style: const TextStyle(
                  color: AppColor.primaryGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
