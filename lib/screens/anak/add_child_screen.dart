import 'package:flutter/material.dart';
import '../../models/child_model.dart';
import '../../services/child_service.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  void save() {
    final child = ChildModel(
      name: nameController.text,
      age: int.tryParse(ageController.text) ?? 0,
      growth: [
        GrowthData(
          weight: double.tryParse(weightController.text) ?? 0,
          height: double.tryParse(heightController.text) ?? 0,
        ),
      ],
    );

    ChildService.addChild(child);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Anak")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nama"),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: "Umur"),
            ),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: "Berat"),
            ),
            TextField(
              controller: heightController,
              decoration: const InputDecoration(labelText: "Tinggi"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: save, child: const Text("Simpan")),
          ],
        ),
      ),
    );
  }
}
