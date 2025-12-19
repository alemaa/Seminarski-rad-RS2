import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InventoryReportScreen extends StatefulWidget {
  const InventoryReportScreen({Key? key}) : super(key: key);

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  List<Inventory> _inventory = [];
  bool _isLoading = true;

  bool _lowStockOnly = false;
  static const int lowStockThreshold = 5;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    final provider = context.read<InventoryProvider>();

    try {
      final result = await provider.get();
      setState(() {
        _inventory = result.result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportInventoryPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Inventory Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),

              pw.Text('Total products: ${_inventory.length}'),
              pw.Text('Total quantity: $totalQuantity'),

              pw.SizedBox(height: 20),

              pw.Table.fromTextArray(
                headers: ['Product', 'Quantity', 'Status'],
                data: _inventory.map((i) {
                  final isLow = (i.quantity ?? 0) <= 5;

                  return [
                    i.productName ?? '',
                    i.quantity?.toString() ?? '0',
                    isLow ? 'LOW' : 'OK',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  int get totalQuantity =>
      _inventory.fold(0, (sum, i) => sum + (i.quantity ?? 0));

  @override
  Widget build(BuildContext context) {
    final displayedInventory = _lowStockOnly
        ? _inventory
              .where((i) => (i.quantity ?? 0) <= lowStockThreshold)
              .toList()
        : _inventory;

    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B5A3C),
        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
        label: const Text('Print PDF', style: TextStyle(color: Colors.white)),
        onPressed: _exportInventoryPdf,
      ),

      appBar: AppBar(
        title: const Text('Inventory report'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total products: ${_inventory.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total quantity: $totalQuantity',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Checkbox(
                        value: _lowStockOnly,
                        onChanged: (value) {
                          setState(() {
                            _lowStockOnly = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF8B5A3C),
                      ),
                      const Text(
                        'Low stock only (≤ 5)',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.separated(
                      itemCount: displayedInventory.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = displayedInventory[index];

                        final isLowStock =
                            (item.quantity ?? 0) <= lowStockThreshold;

                        return Card(
                          color: const Color(0xFFD2B48C),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              item.productName ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text('Quantity: ${item.quantity}'),
                            trailing: isLowStock
                                ? const Text(
                                    'LOW',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
