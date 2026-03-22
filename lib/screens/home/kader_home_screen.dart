import 'package:flutter/material.dart';
import '../../widgets/custom_card.dart';

class HomeKaderScreen extends StatelessWidget {
  const HomeKaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 HEADER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.local_hospital, color: Colors.green),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        "Halo, Kader 👋\nKelola data posyandu hari ini",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 🔥 STAT
              Row(
                children: [
                  _statCard("120", "Total Anak"),
                  const SizedBox(width: 10),
                  _statCard("5", "Kegiatan"),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                "Menu Utama",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              CustomCard(
                title: "Data Anak",
                subtitle: "Kelola semua data anak",
                icon: Icons.groups,
                color: Colors.blue,
                onTap: () {},
              ),

              CustomCard(
                title: "Jadwal Posyandu",
                subtitle: "Atur jadwal kegiatan",
                icon: Icons.calendar_today,
                color: Colors.orange,
                onTap: () {},
              ),

              CustomCard(
                title: "Laporan",
                subtitle: "Rekap data kesehatan",
                icon: Icons.bar_chart,
                color: Colors.purple,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
