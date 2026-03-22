import 'package:flutter/material.dart';
import '../../models/child_model.dart';
import '../../services/child_service.dart';
import 'add_child_screen.dart';
import 'chart_screen.dart';

class ChildListScreen extends StatefulWidget {
  const ChildListScreen({super.key});

  @override
  State<ChildListScreen> createState() => _ChildListScreenState();
}

class _ChildListScreenState extends State<ChildListScreen> {
  List<ChildModel> children = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() {
    final data = ChildService.getChildren(); // ❗ TANPA await
    setState(() => children = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Anak")),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddChildScreen()),
          );

          load();
        },
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];

          return ListTile(
            title: Text(child.name),

            // ✅ ambil dari growth
            subtitle: Text("Berat terakhir: ${child.growth.last.weight} kg"),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChartScreen(child: child), // ✅ FIX
                ),
              );
            },
          );
        },
      ),
    );
  }
}
