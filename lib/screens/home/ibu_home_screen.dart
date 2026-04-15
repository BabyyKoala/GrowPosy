import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/child_model.dart';
import '../growth/growth_chart_screen.dart';

class HomeIbuScreen extends StatefulWidget {
  const HomeIbuScreen({super.key});

  @override
  State<HomeIbuScreen> createState() => _HomeIbuScreenState();
}

class _HomeIbuScreenState extends State<HomeIbuScreen> {
  // Palette warna sesuai branding Figma
  final Color primaryGreen = const Color(0xFF00D15A);
  final Color bgLight = const Color(0xFFF8FBF9);
  
  int _selectedIndex = 0; // Index aktif untuk Bottom Navbar
  int _selectedChildIndex = 0; // Index anak yang dipilih di Beranda

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    // --- DAFTAR HALAMAN NAVBAR (SEMUA SUDAH TERISI) ---
    final List<Widget> pages = [
      _buildMainDashboard(firestore),         // Index 0: Dashboard Beranda
      _buildChildListTab(firestore),          // Index 1: Manajemen Data Anak
      _buildPosyanduTab(),                    // Index 2: Lokasi & Jadwal Posyandu
      _buildEdukasiTab(),                     // Index 3: Portal Edukasi Bunda
      _buildProfileTab(),                     // Index 4: Profil & Logout
    ];

    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          // IndexedStack digunakan agar state widget tidak reset saat pindah tab
          IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          _buildFloatingNavBar(),
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
            _buildGrowthStatusCard(firestore),
            _buildQuickMenu(),
            _buildSectionTitle("Jadwal Mendatang", "Lihat Semua"),
            _buildUpcomingSchedule(),
            _buildSectionTitle("Edukasi Pilihan", "Semua"),
            _buildArticleList(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: DATA ANAK (FULL CONTENT)
  // ==========================================
  Widget _buildChildListTab(FirestoreService firestore) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInternalPageHeader("Data Buah Hati"),
          Expanded(
            child: StreamBuilder<List<ChildModel>>(
              stream: firestore.getChildren(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final children = snapshot.data!;
                if (children.isEmpty) return _buildEmptyState(Icons.child_care, "Belum ada data anak.");
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: children.length,
                  itemBuilder: (context, index) => _buildChildCardItem(children[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: LOKASI POSYANDU (FULL CONTENT)
  // ==========================================
  Widget _buildPosyanduTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInternalPageHeader("Lokasi Posyandu"),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildPosyanduCard("Posyandu Mawar", "Jl. Melati No. 12, Desa Sukamaju", "0.5 km"),
                _buildPosyanduCard("Posyandu Melati", "Jl. Anggrek No. 45, Desa Sukamaju", "1.2 km"),
                _buildPosyanduCard("Posyandu Kenanga", "Jl. Dahlia No. 03, Desa Mekar", "2.8 km"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: EDUKASI BUNDA (FULL CONTENT)
  // ==========================================
  Widget _buildEdukasiTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInternalPageHeader("Edukasi Bunda"),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildArticleTile("Menu MPASI Sehat 6-9 Bulan", "Nutrisi", Icons.restaurant),
                _buildArticleTile("Pentingnya Imunisasi Dasar", "Kesehatan", Icons.vaccines),
                _buildArticleTile("Tips Menstimulasi Motorik Bayi", "Perkembangan", Icons.toys),
                _buildArticleTile("Mengenal Gejala Stunting", "Kesehatan", Icons.warning_amber_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: PROFIL & LOGOUT (AKTIF)
  // ==========================================
  Widget _buildProfileTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50, 
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/images/avatar_ibu.png')
            ),
            const SizedBox(height: 16),
            const Text("Bunda Siti Siska", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("bunda.siska@email.com", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            _buildProfileMenu(Icons.person_outline, "Informasi Akun", () {}),
            _buildProfileMenu(Icons.notifications_active_outlined, "Notifikasi", () {}),
            _buildProfileMenu(Icons.security_outlined, "Privasi & Keamanan", () {}),
            const Divider(height: 40),
            ListTile(
              onTap: () => _showLogoutDialog(),
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text("Keluar Akun", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              tileColor: Colors.red.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MODULAR UI COMPONENTS
  // ==========================================

  Widget _buildInternalPageHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildPosyanduCard(String name, String address, String distance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[100]!)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.location_on, color: primaryGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(address, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(distance, style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildArticleTile(String title, String category, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: Icon(icon, color: primaryGreen),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(category, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: () {},
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
          border: Border.all(color: Colors.grey[50]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? primaryGreen : Colors.grey[400], size: 26),
          Text(label, style: TextStyle(color: isSelected ? primaryGreen : Colors.grey[400], fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  // --- LOGIKA LOGOUT MENU ---
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Keluar Akun?"),
        content: const Text("Anda akan keluar dari aplikasi GrowPosy. Tekan Ya untuk kembali ke menu login."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              // Navigasi ke rute '/login' dan hapus semua history stack navigasi
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN BERANDA ---
  Widget _buildTopProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        children: [
          const CircleAvatar(radius: 22, backgroundImage: AssetImage('assets/images/avatar_ibu.png')),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Selamat Pagi, Siti 👋", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Kamis, 16 April 2026", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          _buildNotificationIcon(),
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
            padding: const EdgeInsets.only(left: 24),
            itemCount: children.length + 1,
            itemBuilder: (context, index) {
              if (index == children.length) return _buildAddChildButton();
              final child = children[index];
              bool isSelected = _selectedChildIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedChildIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? primaryGreen : Colors.grey[200]!),
                  ),
                  child: Center(child: Text(child.name, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
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
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
        final child = snapshot.data![_selectedChildIndex];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)]),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Icon(Icons.auto_graph, color: primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  const Text("Status Pertumbuhan", style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
                _statusBadge("NORMAL"),
              ]),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _buildSmallStat("Berat", "12.5", "kg"),
                _buildSmallStat("Tinggi", "87", "cm"),
                _buildSmallStat("Lingkar", "47", "cm"),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GrowthChartScreen(childId: child.id, age: child.age))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Lihat Detail Grafik", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickMenu() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _quickIconItem(Icons.edit_document, "Catat", Colors.blue, () {}),
        _quickIconItem(Icons.vaccines, "Imunisasi", Colors.orange, () {}),
        _quickIconItem(Icons.location_on, "Posyandu", Colors.green, () => setState(() => _selectedIndex = 2)),
        _quickIconItem(Icons.menu_book, "Edukasi", Colors.purple, () => setState(() => _selectedIndex = 3)),
      ]),
    );
  }

  Widget _quickIconItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: color)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11)),
      ]),
    );
  }

  Widget _buildUpcomingSchedule() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)), child: const Text("15\nApr", textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        const SizedBox(width: 16),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Posyandu Mawar", style: TextStyle(fontWeight: FontWeight.bold)), Text("Imunisasi & Vitamin A", style: TextStyle(color: Colors.grey, fontSize: 12))])),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ]),
    );
  }

  Widget _buildProfileMenu(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: Colors.grey[700]), title: Text(title), trailing: const Icon(Icons.chevron_right, size: 18), onTap: onTap);
  }

  Widget _buildSmallStat(String label, String value, String unit) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      RichText(text: TextSpan(children: [
        TextSpan(text: value, style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 18)),
        TextSpan(text: " $unit", style: TextStyle(color: primaryGreen, fontSize: 10)),
      ])),
    ]);
  }

  Widget _buildChildCardItem(ChildModel child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        CircleAvatar(backgroundColor: child.gender == 'L' ? Colors.blue[50] : Colors.pink[50], child: Icon(child.gender == 'L' ? Icons.face : Icons.face_3, color: child.gender == 'L' ? Colors.blue : Colors.pink)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(child.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text("${child.age} Tahun")])),
        IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GrowthChartScreen(childId: child.id, age: child.age))), icon: const Icon(Icons.arrow_forward_ios, size: 14)),
      ]),
    );
  }

  Widget _statusBadge(String txt) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text(txt, style: TextStyle(color: primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)));
  Widget _buildSectionTitle(String t, String a) => Padding(padding: const EdgeInsets.fromLTRB(24, 32, 24, 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(a, style: TextStyle(color: primaryGreen, fontSize: 13, fontWeight: FontWeight.bold))]));
  Widget _buildAddChildButton() => Container(margin: const EdgeInsets.only(right: 24), width: 45, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.add, color: Colors.grey));
  Widget _buildNotificationIcon() => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle), child: const Icon(Icons.notifications_none_rounded, size: 24, color: Colors.blue));
  Widget _buildArticleList() => const Padding(padding: EdgeInsets.only(left: 24), child: Text("Memuat artikel edukasi...", style: TextStyle(fontSize: 12, color: Colors.grey)));
}