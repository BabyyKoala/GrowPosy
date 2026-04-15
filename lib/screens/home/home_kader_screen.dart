import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_card.dart';

class HomeKaderScreen extends StatefulWidget {
  const HomeKaderScreen({super.key});

  @override
  State<HomeKaderScreen> createState() => _HomeKaderScreenState();
}

class _HomeKaderScreenState extends State<HomeKaderScreen> {
  final Color primaryGreen = const Color(0xFF00D15A);
  final Color bgLight = const Color(0xFFF8FBF9);

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdminHeader(),
              const SizedBox(height: 32),
              const Text("Ringkasan Wilayah", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  StreamBuilder<int>(
                    stream: firestore.getTotalAllChildren(),
                    builder: (context, snapshot) {
                      return _buildStatBox(
                        value: snapshot.hasData ? snapshot.data.toString() : "0",
                        label: "Total Anak",
                        icon: Icons.groups_rounded,
                        color: Colors.blue,
                      );
                    }
                  ),
                  const SizedBox(width: 16),
                  _buildStatBox(value: "Desa A", label: "Wilayah Kerja", icon: Icons.location_on_rounded, color: Colors.orange),
                ],
              ),
              const SizedBox(height: 35),
              const Text("Manajemen Data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              CustomCard(
                title: "Input Pertumbuhan",
                subtitle: "Catat Berat & Tinggi Badan",
                icon: Icons.add_chart_rounded,
                color: primaryGreen,
                onTap: () => Navigator.pushNamed(context, '/list_anak_kader'),
              ),
              CustomCard(
                title: "Jadwal Kegiatan",
                subtitle: "Atur tanggal posyandu",
                icon: Icons.calendar_month_rounded,
                color: Colors.indigo,
                onTap: () {},
              ),
              CustomCard(
                title: "Laporan Bulanan",
                subtitle: "Unduh data rekap",
                icon: Icons.description_rounded,
                color: Colors.redAccent,
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _buildSyncAlert(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryGreen, const Color(0xFF00B34D)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 32)),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Halo, Kader!", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Data akurat, balita sehat.", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
          ]),
        ],
      ),
    );
  }

  Widget _buildStatBox({required String value, required String label, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -1)),
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFE8F4FF), borderRadius: BorderRadius.circular(16)),
      child: const Row(children: [
        Icon(Icons.check_circle_rounded, color: Colors.blue, size: 24),
        SizedBox(width: 12),
        Expanded(child: Text("Sistem Online. Data tersinkronisasi otomatis.", style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}