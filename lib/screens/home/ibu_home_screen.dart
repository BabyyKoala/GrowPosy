import 'package:flutter/material.dart';
import '../../widgets/custom_card.dart';
import '../anak/child_list_screen.dart';

class HomeIbuScreen extends StatelessWidget {
  const HomeIbuScreen({super.key});

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
                    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.green),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        "Halo, Ibu 👋\nPantau tumbuh kembang anak hari ini",
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
                  _statCard("1", "Anak"),
                  const SizedBox(width: 10),
                  _statCard("Normal", "Status"),
                ],
              ),

              const SizedBox(height: 25),

              // 🔥 QUICK MENU
              const Text(
                "Menu Utama",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              CustomCard(
                title: "Data Anak",
                subtitle: "Lihat dan kelola data anak",
                icon: Icons.child_friendly,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChildListScreen()),
                  );
                },
              ),

              CustomCard(
                title: "Catatan Kesehatan",
                subtitle: "Pantau pertumbuhan anak",
                icon: Icons.monitor_heart,
                color: Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChildListScreen()),
                  );
                },
              ),

              CustomCard(
                title: "Edukasi",
                subtitle: "Artikel kesehatan anak",
                icon: Icons.menu_book,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChildListScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 STAT CARD
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
