import 'package:flutter/material.dart';

class EdukasiScreen extends StatelessWidget {
  const EdukasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edukasi")),
      body: const Center(child: Text("Halaman Edukasi")),
    );
  }
}
