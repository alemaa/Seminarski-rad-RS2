import 'package:flutter/material.dart';

class CustomizationResult {
  final String size;
  final String milkType;
  final int sugarLevel;
  final String note;

  CustomizationResult({
    required this.size,
    required this.milkType,
    required this.sugarLevel,
    required this.note,
  });
}

Future<CustomizationResult?> showCustomizeDialog(BuildContext context) {
  String size = "M";
  String milkType = "Regular";
  int sugarLevel = 1;
  final noteCtrl = TextEditingController();

  return showDialog<CustomizationResult>(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text("Customize"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Size"),
                RadioListTile(
                  value: "S",
                  groupValue: size,
                  title: const Text("S"),
                  onChanged: (v) => setState(() => size = v as String),
                ),
                RadioListTile(
                  value: "M",
                  groupValue: size,
                  title: const Text("M"),
                  onChanged: (v) => setState(() => size = v as String),
                ),
                RadioListTile(
                  value: "L",
                  groupValue: size,
                  title: const Text("L"),
                  onChanged: (v) => setState(() => size = v as String),
                ),
                const SizedBox(height: 8),
                const Text("Milk"),
                DropdownButton<String>(
                  value: milkType,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: "Regular", child: Text("Regular")),
                    DropdownMenuItem(value: "Soy", child: Text("Soy")),
                    DropdownMenuItem(value: "Oat", child: Text("Oat")),
                  ],
                  onChanged: (v) => setState(() => milkType = v ?? "Regular"),
                ),
                const SizedBox(height: 8),
                const Text("Sugar"),
                Row(
                  children: [
                    IconButton(
                      onPressed: sugarLevel > 0
                          ? () => setState(() => sugarLevel--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text("$sugarLevel"),
                    IconButton(
                      onPressed: sugarLevel < 3
                          ? () => setState(() => sugarLevel++)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text("Note"),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    hintText: "e.g. extra hot",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  ctx,
                  CustomizationResult(
                    size: size,
                    milkType: milkType,
                    sugarLevel: sugarLevel,
                    note: noteCtrl.text.trim(),
                  ),
                );
              },
              child: const Text("Add"),
            ),
          ],
        ),
      );
    },
  );
}
