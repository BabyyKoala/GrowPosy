import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();

  String selectedGender = 'Laki-laki';

  final firestore = FirestoreService();

  void save() async {
    if (nameController.text.isEmpty || ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan umur wajib diisi")),
      );
      return;
    }

    await firestore.addChild(
      name: nameController.text,
      age: int.tryParse(ageController.text) ?? 0,
      gender: selectedGender,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
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
              decoration: const InputDecoration(labelText: "Nama Anak"),
            ),

            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Umur"),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedGender,
              items: const [
                DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedGender = value!;
                });
              },
              decoration: const InputDecoration(labelText: "Jenis Kelamin"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: save, child: const Text("Simpan")),
          ],
        ),
      ),
    );
  }
}
