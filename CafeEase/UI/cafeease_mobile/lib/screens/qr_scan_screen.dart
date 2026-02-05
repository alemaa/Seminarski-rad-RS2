import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/app_session.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan table QR")),
      body: MobileScanner(
        onDetect: (capture) {
          if (_handled) return;

          final barcode =
              capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
          final raw = barcode?.rawValue;
          if (raw == null) return;

          debugPrint("QR RAW ='${raw}'");

          int? tableId;

          final uri = Uri.tryParse(raw);
          if (uri != null && uri.queryParameters.containsKey('tableId')) {
            tableId = int.tryParse(uri.queryParameters['tableId']!);
          } else {
            tableId = int.tryParse(raw);
          }

          if (tableId == null || tableId <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid QR code")),
            );
            return;
          }

          _handled = true;
          AppSession.tableId = tableId;
          Navigator.pop(context);
        },
      ),
    );
  }
}
