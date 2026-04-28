import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🔥 Import Service & Model
import '../../services/firestore_service.dart';
import '../../models/child_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini untuk Timestamp formatting jika diperlukan, atau ganti dengan intl.
import 'package:intl/intl.dart'; // 🔥 Import intl untuk format waktu

// 🔥 Import Sistem Tema
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

// 🔥 Import Semua Screen Modular
import '../growth/growth_chart_screen.dart';
import '../posyandu/posyandu_screen.dart';
import '../edukasi/edukasi_screen.dart';
import '../profil/profil_screen.dart';
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
  bool _hasUnreadNotif = true;

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    final List<Widget> pages = [
      _buildMainDashboard(firestore),
      _buildIbuChildList(firestore),
      const PosyanduScreen(),
      const EdukasiScreen(),
      const ProfilScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Keluar Aplikasi?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "Apakah Anda yakin ingin keluar dari aplikasi GrowPosy?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: AppColor.textGrey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.errorRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Keluar",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.bgWhite,
        body: Stack(
          children: [
            IndexedStack(index: _selectedIndex, children: pages),
            _buildFloatingNavBar(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 🔥 TAB 1: DAFTAR ANAK (Dengan Tombol Tambah di Bawah Kanan)
  // ==========================================
  Widget _buildIbuChildList(FirestoreService firestore) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // Agar background menyatu dengan parent
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 90.0,
        ), // Hindari tab bar menutupi tombol
        child: FloatingActionButton.extended(
          backgroundColor: AppColor.primaryGreen,
          onPressed: () {
            Navigator.pushNamed(context, '/add_child');
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Tambah Anak",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SafeArea(
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
                        "Belum ada profil anak. Silakan klik tombol di bawah.",
                        style: TextStyle(color: AppColor.textGrey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 100,
                    ),
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
            _buildTopProfileHeader(firestore), // 🔥 Update: Kirim firestore ke sini
            _buildChildSelector(firestore),
            _buildGrowthStatusCard(firestore),
            _buildQuickMenu(),
            _buildSectionTitle(
              "Jadwal Mendatang",
              "Lihat Semua",
              () => setState(() => _selectedIndex = 2),
            ),
            _buildUpcomingSchedule(firestore), // 🔥 Update: Ambil jadwal dari firestore
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

  Widget _buildTopProfileHeader(FirestoreService firestore) {
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
          GestureDetector(
            onTap: () {
              setState(() => _hasUnreadNotif = false);
              _showNotificationPanel(context, firestore); // 🔥 Buka Panel Notifikasi
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
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
                if (_hasUnreadNotif)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColor.errorRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 UPDATE: Menggunakan StreamBuilder untuk menampilkan pengumuman secara Real-Time
  void _showNotificationPanel(BuildContext context, FirestoreService firestore) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text("Notifikasi & Pengumuman", style: AppTextStyle.heading1),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: firestore.getPengumuman(), // 🔥 Listen ke Firebase
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColor.primaryGreen),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text("Gagal memuat notifikasi"));
                    }

                    final pengumumanList = snapshot.data ?? [];

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Notifikasi Statis / Default
                        _buildNotifItem(
                          icon: Icons.auto_graph_rounded,
                          color: AppColor.primaryGreen,
                          title: "Data Pertumbuhan Diperbarui",
                          subtitle:
                              "Kader mungkin baru saja memasukkan data anak Anda. Cek grafik KMS secara berkala.",
                          time: "Sistem",
                          onTap: () {
                            Navigator.pop(context);
                            setState(() => _selectedIndex = 1);
                          },
                        ),
                        
                        // 🔥 Merender Daftar Pengumuman dari Database
                        ...pengumumanList.map((data) {
                          // Formatting Waktu (Timestamp ke String)
                          String timeStr = "Baru saja";
                          if (data['createdAt'] != null) {
                             final timestamp = data['createdAt'] as Timestamp;
                             timeStr = DateFormat('dd MMM, HH:mm').format(timestamp.toDate());
                          }

                          return _buildNotifItem(
                            icon: Icons.campaign_rounded,
                            color: Colors.indigo,
                            title: "Pengumuman dari Kader 📢",
                            subtitle: data['pesan'] ?? "Pesan tidak tersedia",
                            time: timeStr,
                            onTap: () => Navigator.pop(context),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotifItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColor.borderGrey, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppColor.textGrey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColor.textGrey,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 Selector Anak Murni (Tanpa Tombol Tambah di Ujung)
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
            itemCount: children.length,
            itemBuilder: (context, index) {
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

              StreamBuilder<List<Map<String, dynamic>>>(
                stream: firestore.getGrowth(child.id),
                builder: (context, growthSnap) {
                  String weight = "-";
                  String height = "-";
                  String imunisasiTerakhir = "-"; // 🔥 Imunisasi Dikembalikan

                  if (growthSnap.hasData && growthSnap.data!.isNotEmpty) {
                    final latestData = growthSnap.data!.last;
                    weight = latestData['weight'].toString();
                    height = latestData['height'].toString();

                    imunisasiTerakhir =
                        latestData['imunisasi']?.toString() ?? "-";
                    if (imunisasiTerakhir.isEmpty) imunisasiTerakhir = "-";
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(child: _buildSmallStat("Berat", weight, "kg")),
                      Expanded(child: _buildSmallStat("Tinggi", height, "cm")),
                      Expanded(
                        child: _buildTextStat("Imunisasi", imunisasiTerakhir),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
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

  Widget _buildTextStat(String label, String value) {
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
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColor.primaryGreen,
            fontWeight: FontWeight.w800,
            fontSize: 14,
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

  // 🔥 UPDATE: Mengambil Jadwal Posyandu Mendatang dari Firebase
  Widget _buildUpcomingSchedule(FirestoreService firestore) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestore.getJadwal(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator(color: AppColor.primaryGreen));
        }

        final jadwalList = snapshot.data ?? [];
        if (jadwalList.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColor.borderGrey),
            ),
            child: const Center(
              child: Text("Belum ada jadwal kegiatan", style: TextStyle(color: AppColor.textGrey)),
            ),
          );
        }

        // Ambil jadwal paling terbaru
        final jadwal = jadwalList.first;

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
                child: Column(
                  children: [
                    Text(
                      jadwal['tanggal']?.toString() ?? "-",
                      style: const TextStyle(
                        color: AppColor.errorRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      jadwal['bulan']?.toString() ?? "-",
                      style: const TextStyle(
                        color: AppColor.errorRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jadwal['lokasi']?.toString() ?? "Posyandu",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      jadwal['kegiatan']?.toString() ?? "-",
                      style: const TextStyle(color: AppColor.textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColor.textGrey),
            ],
          ),
        );
      }
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(
              title: title,
              category: category,
              color: color,
              time: "3 Min Read",
              icon: Icons
                  .tips_and_updates_rounded, // Sedikit disesuaikan agar lebih menarik
              content:
                  "Ini adalah artikel ringkasan mengenai $category.\n\n"
                  "Membaca informasi dan panduan medis seputar $title sangat penting untuk menunjang tumbuh kembang anak Anda agar tetap sehat, aktif, dan terhindar dari penyakit.\n\n"
                  "Untuk panduan nutrisi, pola asuh, dan jadwal imunisasi yang lebih komprehensif, silakan kunjungi menu 'Pusat Edukasi' di aplikasi GrowPosy.",
              // 🔥 PERBAIKAN: Menambahkan parameter 'source' yang kini wajib diisi
              source: "Ringkasan Edukasi Harian - Tim Dokter GrowPosy",
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
            // 🏷️ Kategori Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),
            // 📝 Judul Artikel
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                height: 1.3,
                color: AppColor.textBlack, // Tambahan warna agar lebih tegas
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            // ➡️ Teks Baca Selengkapnya
            Row(
              children: [
                const Text(
                  "Baca selengkapnya",
                  style: TextStyle(
                    color: AppColor.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 12,
                  color: color, // Panah kecil menyesuaikan warna kategori
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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