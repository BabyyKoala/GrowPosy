import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  final FirestoreService firestore = FirestoreService();

  final codeController = TextEditingController();

  bool isLoading = false;

  // 🔥 PILIH IBU
  Future<void> selectIbu() async {
    setState(() => isLoading = true);

    await firestore.setUserRole('ibu');

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/home_ibu');
  }

  // 🔥 PILIH KADER (PAKAI KODE)
  Future<void> selectKader() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Kode wajib diisi")));
      return;
    }

    setState(() => isLoading = true);

    final isValid = await firestore.verifyInviteCode(code);

    if (!isValid) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kode tidak valid atau sudah digunakan"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await firestore.setUserRole('kader');
    await firestore.useInviteCode(code, uid);

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/home_kader');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Role")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Pilih peran Anda", style: TextStyle(fontSize: 18)),

            const SizedBox(height: 30),

            // 🔥 IBU BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : selectIbu,
                child: const Text("Masuk sebagai Ibu"),
              ),
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 20),

            // 🔥 INPUT KODE KADER
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: "Kode Kader",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : selectKader,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Verifikasi sebagai Kader"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
