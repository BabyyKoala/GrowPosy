import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class AddGrowthScreen extends StatefulWidget {
  final String childId;

  const AddGrowthScreen({super.key, required this.childId});

  @override
  State<AddGrowthScreen> createState() => _AddGrowthScreenState();
}

class _AddGrowthScreenState extends State<AddGrowthScreen> {
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  final firestore = FirestoreService();

  void saveGrowth() async {
    if (weightController.text.isEmpty || heightController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Isi semua data")));
      return;
    }

    await firestore.addGrowth(
      childId: widget.childId,
      weight: double.parse(weightController.text),
      height: double.parse(heightController.text),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Input Pertumbuhan")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Berat (kg)"),
            ),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Tinggi (cm)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: saveGrowth, child: const Text("Simpan")),
          ],
        ),
      ),
    );
  }
}
