import 'package:flutter/material.dart';
import '../utils/app_session.dart';
import '../screens/qr_scan_screen.dart';

Future<void> showSelectTableDialog(BuildContext context) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: const Text("Select table"),
        content: const Text(
          "Scan the QR code on your table or enter the table number manually.",
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text("Scan QR"),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrScanScreen()),
              );
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.keyboard),
            label: const Text("Enter number"),
            onPressed: () {
              Navigator.pop(ctx);
              showEnterTableDialog(context);
            },
          ),
        ],
      );
    },
  );
}

void showEnterTableDialog(BuildContext context) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text("Enter table number"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "e.g. 5"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val == null || val <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid table number")),
                );
                return;
              }

              AppSession.tableId = val;
              Navigator.pop(ctx);
            },
            child: const Text("Confirm"),
          ),
        ],
      );
    },
  );
}
