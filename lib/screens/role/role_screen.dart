import 'package:flutter/material.dart';
import '../../services/session_service.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  String? selectedRole;

  void selectRole(String role) {
    setState(() {
      selectedRole = role;
    });
  }

  void continueRole() async {
    if (selectedRole == null) return;

    await SessionService.setRole(selectedRole!);

    if (!mounted) return;

    if (selectedRole == 'ibu') {
      Navigator.pushReplacementNamed(context, '/home_ibu');
    } else {
      Navigator.pushReplacementNamed(context, '/home_kader');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // 🔥 HEADER
              const Text(
                "Pilih Peran Anda",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Agar pengalaman lebih sesuai",
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 40),

              // 🔥 CARD CONTAINER
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      _roleCard(
                        title: "Ibu / Orang Tua",
                        desc: "Pantau tumbuh kembang anak",
                        icon: Icons.child_care,
                        value: "ibu",
                      ),

                      const SizedBox(height: 20),

                      _roleCard(
                        title: "Kader Posyandu",
                        desc: "Kelola data dan kegiatan",
                        icon: Icons.local_hospital,
                        value: "kader",
                      ),

                      const Spacer(),

                      // 🔥 BUTTON LANJUT
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: selectedRole == null ? null : continueRole,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Lanjutkan",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 ROLE CARD
  Widget _roleCard({
    required String title,
    required String desc,
    required IconData icon,
    required String value,
  }) {
    final isSelected = selectedRole == value;

    return GestureDetector(
      onTap: () => selectRole(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            // ICON
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.green),
            ),

            const SizedBox(width: 15),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            // CHECK
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
