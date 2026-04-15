import 'package:flutter/material.dart';
import '../../models/child_model.dart';
import '../../services/firestore_service.dart';
import '../child/add_child_screen.dart';
import '../growth/growth_chart_screen.dart';

class ChildListScreen extends StatelessWidget {
  const ChildListScreen({super.key});

  void showAddGrowthDialog(BuildContext context, String childId) {
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final firestore = FirestoreService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Input Pertumbuhan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Berat (kg)"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Tinggi (cm)"),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final weight = double.tryParse(weightController.text) ?? 0;
                    final height = double.tryParse(heightController.text) ?? 0;

                    await firestore.addGrowth(
                      childId: childId,
                      weight: weight,
                      height: height,
                    );

                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text("Data Anak")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddChildScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<ChildModel>>(
        stream: firestore.getChildren(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final children = snapshot.data!;

          if (children.isEmpty) {
            return const Center(child: Text("Belum ada data anak"));
          }

          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];

              return ListTile(
                isThreeLine: true,
                title: Text(child.name),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Umur: ${child.age} tahun"),

                    StreamBuilder<double?>(
                      stream: firestore.getLastWeight(child.id),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text("Berat: -");
                        }

                        final weight = snapshot.data;

                        if (weight == null) {
                          return const Text("Belum ada data berat");
                        }

                        return Text("Berat terakhir: $weight kg");
                      },
                    ),
                  ],
                ),

                trailing: IconButton(
                  icon: const Icon(Icons.add_chart, color: Colors.green),
                  onPressed: () {
                    showAddGrowthDialog(context, child.id);
                  },
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GrowthChartScreen(childId: child.id, age: child.age),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
