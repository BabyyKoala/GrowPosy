import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// 🔥 Import Service
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

// 🔥 Import Sistem Tema & Custom Widgets
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_text_field.dart';

import '../growth/add_growth_screen.dart';
import '../posyandu/laporan_bulanan_screen.dart'; // 🔥 IMPORT BARU

class HomeKaderScreen extends StatefulWidget {
  const HomeKaderScreen({super.key});

  @override
  State<HomeKaderScreen> createState() => _HomeKaderScreenState();
}

class _HomeKaderScreenState extends State<HomeKaderScreen> {
  int _selectedIndex = 0;
  String searchQuery = '';

  // 🔥 TAMBAHAN: Controller agar teks pencarian tidak hilang saat pindah tab
  final TextEditingController _searchController = TextEditingController();

  late final FirestoreService _firestore;
  late final Stream<int> _totalChildrenStream;
  late final Stream<List<Map<String, dynamic>>> _childrenStream;
  late final Stream<List<Map<String, dynamic>>> _jadwalStream;

  @override
  void initState() {
    super.initState();
    _firestore = FirestoreService();
    _totalChildrenStream = _firestore.getTotalAllChildren();
    _childrenStream = _firestore.getAllChildrenForKader();
    _jadwalStream = _firestore.getJadwal();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildBerandaTab(),
      _buildDataBalitaTab(),
      _buildJadwalTab(),
      _buildProfileTab(),
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
              "Apakah Anda yakin ingin menutup aplikasi GrowPosy?",
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
  // TAB 0: BERANDA (DASHBOARD)
  // ==========================================
  Widget _buildBerandaTab() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 10,
          bottom: 120, // Menghindari tertutup navbar
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdminHeader(),
            const SizedBox(height: 32),

            const Text("Ringkasan Wilayah", style: AppTextStyle.heading1),
            const SizedBox(height: 16),
            Row(
              children: [
                StreamBuilder<int>(
                  stream: _totalChildrenStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildStatBox(
                        value: "...",
                        label: "Memuat...",
                        icon: Icons.groups_rounded,
                        color: Colors.blue,
                      );
                    }
                    if (snapshot.hasError) {
                      return _buildStatBox(
                        value: "!",
                        label: "Error",
                        icon: Icons.error_outline,
                        color: AppColor.errorRed,
                      );
                    }
                    return _buildStatBox(
                      value: snapshot.hasData ? snapshot.data.toString() : "0",
                      label: "Total Balita",
                      icon: Icons.groups_rounded,
                      color: Colors.blue,
                    );
                  },
                ),
                const SizedBox(width: 16),
                _buildStatBox(
                  value: "Posyandu\nMelati",
                  label: "Wilayah Kerja",
                  icon: Icons.location_on_rounded,
                  color: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 35),
            const Text("Menu Cepat", style: AppTextStyle.heading1),
            const SizedBox(height: 16),

            CustomCard(
              title: "Input Pertumbuhan (KMS)",
              subtitle: "Pilih balita di Tab Data Anak untuk menimbang",
              icon: Icons.add_chart_rounded,
              color: AppColor.primaryGreen,
              onTap: () {
                setState(() => _selectedIndex = 1);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "🔍 Silakan cari nama anak lalu tekan tombol 'Input'",
                    ),
                    backgroundColor: AppColor.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            CustomCard(
              title: "Kirim Pengumuman",
              subtitle: "Broadcast pesan ke HP para ibu",
              icon: Icons.campaign_rounded,
              color: Colors.indigo,
              onTap: () => _showPengumumanBottomSheet(context),
            ),
            const SizedBox(height: 12),

            CustomCard(
              title: "Laporan Bulanan",
              subtitle: "Lihat dan unduh rekap data",
              icon: Icons.description_rounded,
              color: AppColor.errorRed,
              onTap: () {
                // 🔥 Pindah ke Layar Laporan yang baru kita buat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LaporanBulananScreen()),
                );
              },
            ),

            const SizedBox(height: 32),
            _buildSyncAlert(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: DATA BALITA (PENCARIAN)
  // ==========================================
  Widget _buildDataBalitaTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: Text("Data Balita", style: AppTextStyle.heading1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: TextField(
              controller: _searchController, // Menggunakan controller
              onChanged: (value) =>
                  setState(() => searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Cari nama anak...",
                hintStyle: const TextStyle(color: AppColor.textGrey),
                prefixIcon: const Icon(Icons.search, color: AppColor.textGrey),
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
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _childrenStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryGreen,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColor.errorRed,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Gagal memuat data dari Firebase.\n\nDetail Error:\n${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColor.errorRed,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada data balita terdaftar.",
                      style: TextStyle(color: AppColor.textGrey),
                    ),
                  );
                }

                final children = snapshot.data!.where((child) {
                  final name = (child['name'] ?? 'Tanpa Nama')
                      .toString()
                      .toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                if (children.isEmpty) {
                  return const Center(
                    child: Text(
                      "Anak tidak ditemukan.",
                      style: TextStyle(color: AppColor.textGrey),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 10,
                    bottom: 120, // Menghindari tertutup navbar
                  ),
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    final isBoy = child['gender'] == 'L';
                    final childName = child['name']?.toString() ?? 'Tanpa Nama';
                    final childAge = child['age']?.toString() ?? '0';
                    final childId = child['id']?.toString() ?? '';
                    final userId = child['userId']?.toString() ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColor.borderGrey),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: isBoy
                              ? Colors.blue[50]
                              : Colors.pink[50],
                          child: Icon(
                            isBoy ? Icons.face : Icons.face_3,
                            color: isBoy ? Colors.blue : Colors.pink,
                          ),
                        ),
                        title: Text(
                          childName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "$childAge Bulan",
                          style: const TextStyle(
                            color: AppColor.textGrey,
                            fontSize: 13,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            if (childId.isEmpty || userId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Data ID Anak tidak valid!"),
                                  backgroundColor: AppColor.errorRed,
                                ),
                              );
                              return;
                            }
                            // Buka AddGrowthScreen untuk input data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddGrowthScreen(
                                  childId: childId,
                                  userId: userId,
                                  childName: childName,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryGreen.withOpacity(
                              0.1,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Input",
                            style: TextStyle(
                              color: AppColor.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
  // TAB 2: JADWAL POSYANDU
  // ==========================================
  Widget _buildJadwalTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Jadwal Kegiatan", style: AppTextStyle.heading1),
                GestureDetector(
                  onTap: () => _showAddJadwalBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primaryGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text(
                          "Tambah",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              "Kelola tanggal buka posyandu agar ibu-ibu mendapat notifikasi.",
              style: AppTextStyle.bodyText,
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _jadwalStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryGreen,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error memuat jadwal: ${snapshot.error}",
                      style: const TextStyle(color: AppColor.errorRed),
                    ),
                  );
                }

                final jadwalListFromDb = snapshot.data ?? [];
                if (jadwalListFromDb.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada jadwal posyandu.",
                      style: TextStyle(color: AppColor.textGrey),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 100, // Hindari navbar
                  ),
                  itemCount: jadwalListFromDb.length,
                  itemBuilder: (context, index) {
                    final jadwal = jadwalListFromDb[index];
                    final isNext = index == 0; // Highlight jadwal teratas

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isNext
                              ? AppColor.primaryGreen
                              : AppColor.borderGrey,
                          width: isNext ? 1.5 : 1,
                        ),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isNext
                                  ? AppColor.primaryGreen.withOpacity(0.1)
                                  : AppColor.bgWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isNext
                                    ? Colors.transparent
                                    : AppColor.borderGrey,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  jadwal['tanggal']?.toString() ?? '-',
                                  style: TextStyle(
                                    color: isNext
                                        ? AppColor.primaryGreen
                                        : AppColor.textBlack,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                Text(
                                  jadwal['bulan']?.toString() ?? '-',
                                  style: TextStyle(
                                    color: isNext
                                        ? AppColor.primaryGreen
                                        : AppColor.textGrey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isNext
                                        ? Colors.orange.withOpacity(0.1)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    jadwal['status']?.toString() ?? 'Terjadwal',
                                    style: TextStyle(
                                      color: isNext
                                          ? Colors.orange
                                          : AppColor.textGrey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  jadwal['lokasi']?.toString() ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColor.textBlack,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: AppColor.textGrey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      jadwal['waktu']?.toString() ?? '-',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColor.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.vaccines_rounded,
                                      size: 14,
                                      color: AppColor.textGrey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        jadwal['kegiatan']?.toString() ?? '-',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColor.textGrey,
                                          height: 1.3,
                                        ),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FITUR KADER (BOTTOM SHEETS & DIALOGS)
  // ==========================================

  void _showAddJadwalBottomSheet(BuildContext context) {
    final agendaController = TextEditingController();
    final lokasiController = TextEditingController(text: "Posyandu Melati");
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tambah Jadwal Baru",
                    style: AppTextStyle.heading1,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Tanggal",
                              style: AppTextStyle.inputLabel,
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  setModalState(() => selectedDate = date);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      color: AppColor.primaryGreen,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      selectedDate == null
                                          ? "Pilih Tanggal"
                                          : DateFormat(
                                              'dd MMM yyyy',
                                            ).format(selectedDate!),
                                      style: TextStyle(
                                        color: selectedDate == null
                                            ? AppColor.textGrey
                                            : AppColor.textBlack,
                                      ),
                                    ),
                                  ],
                                ),
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
                            const Text(
                              "Jam Mulai",
                              style: AppTextStyle.inputLabel,
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: const TimeOfDay(
                                    hour: 8,
                                    minute: 0,
                                  ),
                                );
                                if (time != null) {
                                  setModalState(() => selectedTime = time);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      selectedTime == null
                                          ? "Pilih Jam"
                                          : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}", // Format aman tanpa context
                                      style: TextStyle(
                                        color: selectedTime == null
                                            ? AppColor.textGrey
                                            : AppColor.textBlack,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text("Lokasi Posyandu", style: AppTextStyle.inputLabel),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: lokasiController,
                    hintText: "Lokasi kegiatan",
                    prefixIcon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 16),

                  const Text("Agenda Kegiatan", style: AppTextStyle.inputLabel),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: agendaController,
                    hintText: "Contoh: Imunisasi Campak & Timbang",
                    prefixIcon: Icons.event_note_rounded,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (selectedDate != null &&
                            selectedTime != null &&
                            agendaController.text.isNotEmpty &&
                            lokasiController.text.isNotEmpty) {
                          String strTanggal = DateFormat(
                            'dd',
                          ).format(selectedDate!);
                          String strBulan = DateFormat(
                            'MMM',
                          ).format(selectedDate!);

                          // Format 24 Jam agar konsisten
                          String jamFormat =
                              "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";
                          String strWaktu = "$jamFormat - Selesai";

                          await _firestore.addJadwal({
                            'tanggal': strTanggal,
                            'bulan': strBulan,
                            'lokasi': lokasiController.text,
                            'waktu': strWaktu,
                            'kegiatan': agendaController.text,
                            'status': 'Akan Datang',
                          });

                          if (!context.mounted) return;
                          Navigator.pop(context); // Tutup bottomsheet

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Jadwal berhasil ditambahkan!"),
                              backgroundColor: AppColor.primaryGreen,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Harap lengkapi semua data!"),
                              backgroundColor: AppColor.errorRed,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Simpan Jadwal",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPengumumanBottomSheet(BuildContext context) {
    final pesanController = TextEditingController();
    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kirim Pengumuman 📢",
                    style: AppTextStyle.heading1,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Pesan ini akan otomatis muncul di beranda aplikasi seluruh Ibu di wilayah Anda.",
                    style: AppTextStyle.bodyText,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: pesanController,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Contoh: Diingatkan besok jam 8 pagi ada PIN Polio di Balai Desa...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.indigo, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSending
                          ? null
                          : () async {
                              final pesan = pesanController.text.trim();
                              if (pesan.isEmpty) return;
                              
                              setModalState(() => isSending = true);

                              try {
                                // 🔥 KONEKSI KE FIREBASE
                                await _firestore.sendPengumuman(pesan);

                                if (!context.mounted) return;
                                Navigator.pop(context); // Tutup bottomsheet

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("✅ Pengumuman berhasil disebarkan!"),
                                    backgroundColor: Colors.indigo,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: AppColor.errorRed,
                                  ),
                                );
                                setModalState(() => isSending = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isSending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Kirim Broadcast",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 3: PROFIL & LOGOUT
  // ==========================================
  Widget _buildProfileTab() {
    final user = FirebaseAuth.instance.currentUser;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColor.borderGrey,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                size: 64,
                color: AppColor.textGrey,
              ),
            ),
            const SizedBox(height: 16),
            const Text("Akun Kader", style: AppTextStyle.heading1),
            Text(
              user?.email ?? "Email tidak tersedia",
              style: AppTextStyle.bodyText,
            ),
            const SizedBox(height: 40),

            _buildProfileMenu(
              Icons.person_outline,
              "Informasi Akun",
              () => _showAccountInfoDialog(user?.email),
            ),
            _buildProfileMenu(
              Icons.security_outlined,
              "Ubah Kode Undangan Kader",
              () => _showKodeUndanganDialog(),
            ),
            _buildProfileMenu(
              Icons.help_outline_rounded,
              "Pusat Bantuan",
              () => _showHelpCenter(),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: AppColor.borderGrey),
            ),
            ListTile(
              onTap: _showLogoutDialog,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColor.errorRed,
                ),
              ),
              title: const Text(
                "Keluar Akun",
                style: TextStyle(
                  color: AppColor.errorRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountInfoDialog(String? email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Informasi Akun",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Peran",
              style: TextStyle(color: AppColor.textGrey, fontSize: 12),
            ),
            const Text(
              "Admin / Kader Posyandu",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              "Email Terdaftar",
              style: TextStyle(color: AppColor.textGrey, fontSize: 12),
            ),
            Text(
              email ?? "-",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tutup",
              style: TextStyle(color: AppColor.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showKodeUndanganDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Kode Undangan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Berikan kode ini kepada Ibu untuk mendaftar ke posyandu Anda.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "POSYANDU-BWI", // Kode Statis UI
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tutup",
              style: TextStyle(color: AppColor.textGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Kode disalin ke Clipboard!"),
                  backgroundColor: AppColor.primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Salin Kode",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Pusat Bantuan Kader", style: AppTextStyle.heading1),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(
                  Icons.contact_support_rounded,
                  color: AppColor.primaryGreen,
                ),
                title: Text("Hubungi Super Admin"),
                subtitle: Text("WhatsApp: 0812-XXXX-XXXX"),
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.menu_book_rounded,
                  color: AppColor.primaryGreen,
                ),
                title: Text("Panduan Penggunaan"),
                subtitle: Text("Baca cara menginput data balita"),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.primaryGreen, Color(0xFF00A045)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Halo, Kader!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Semangat melayani hari ini.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColor.borderGrey),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColor.textBlack,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColor.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_done_rounded, color: Colors.blue, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Sistem Online. Data posyandu otomatis tersinkronisasi.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColor.bgWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.borderGrey),
        ),
        child: Icon(icon, color: AppColor.textBlack),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColor.textGrey,
      ),
      onTap: onTap,
    );
  }

  // ==========================================
  // FLOATING BOTTOM NAVBAR KADER
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
            _navIconItem(Icons.dashboard_rounded, "Beranda", 0),
            _navIconItem(Icons.people_alt_rounded, "Data Balita", 1),
            _navIconItem(Icons.event_available_rounded, "Jadwal", 2),
            _navIconItem(Icons.person_rounded, "Profil", 3),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Keluar Akun?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Sesi Anda sebagai Kader akan diakhiri.",
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: AppColor.textGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService().logout();
              if (!mounted) return;
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Ya, Keluar",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}