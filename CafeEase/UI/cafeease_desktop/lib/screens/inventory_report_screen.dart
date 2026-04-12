import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InventoryReportScreen extends StatefulWidget {
  const InventoryReportScreen({super.key});

  @override
  State<InventoryReportScreen> createState() => _InventoryReportScreenState();
}

class _InventoryReportScreenState extends State<InventoryReportScreen> {
  List<Inventory> _inventory = [];
  bool _isLoading = true;

  bool _lowStockOnly = false;

  static const int lowStockThreshold = 5;
  static const String stockUnit = 'pcs';

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

  bool _isLowStock(Inventory item) {
    return (item.quantity ?? 0) <= lowStockThreshold;
  }

  List<Inventory> get _displayedInventory {
    final items = List<Inventory>.from(_inventory);

    if (_lowStockOnly) {
      items.retainWhere(_isLowStock);
    }

    items.sort((a, b) {
      final aLow = _isLowStock(a);
      final bLow = _isLowStock(b);

      if (aLow != bLow) {
        return aLow ? -1 : 1;
      }

      final aQty = a.quantity ?? 0;
      final bQty = b.quantity ?? 0;

      return aQty.compareTo(bQty);
    });

    return items;
  }

  Future<void> _exportInventoryPdf() async {
    final pdf = pw.Document();
    final displayedInventory = _displayedInventory;

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
              pw.SizedBox(height: 12),
              pw.Text('Total products: ${displayedInventory.length}'),
              pw.Text(
                'Total quantity: ${_totalQuantity(displayedInventory)} $stockUnit',
              ),
              pw.Text('Low stock threshold: <= $lowStockThreshold $stockUnit'),
              pw.Text('Filter active: ${_lowStockOnly ? "YES" : "NO"}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Product', 'Quantity', 'Unit', 'Threshold', 'Status'],
                data: displayedInventory.map((i) {
                  final quantity = i.quantity ?? 0;
                  final isLow = _isLowStock(i);

                  return [
                    i.productName ?? '',
                    quantity.toString(),
                    stockUnit,
                    '<= $lowStockThreshold',
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

  int _totalQuantity(List<Inventory> items) {
    return items.fold(0, (sum, i) => sum + (i.quantity ?? 0));
  }

  int get totalQuantity => _totalQuantity(_inventory);

  @override
  Widget build(BuildContext context) {
    final displayedInventory = _displayedInventory;

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
                    'Total quantity: $totalQuantity $stockUnit',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Low stock threshold: ≤ $lowStockThreshold $stockUnit',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
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
                      const Expanded(
                        child: Text(
                          'Low stock only (≤ 5 pcs)',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
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
                        final quantity = item.quantity ?? 0;
                        final isLowStock = _isLowStock(item);

                        final progressValue = (quantity / lowStockThreshold)
                            .clamp(0.0, 1.0);

                        return Card(
                          color: const Color(0xFFD2B48C),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.productName ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (isLowStock)
                                      const Chip(
                                        label: Text(
                                          'LOW',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        backgroundColor: Colors.red,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      )
                                    else
                                      const Chip(
                                        label: Text(
                                          'OK',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        backgroundColor: Colors.green,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Quantity: $quantity $stockUnit',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Low stock threshold: ≤ $lowStockThreshold $stockUnit',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  value: progressValue,
                                  minHeight: 8,
                                  backgroundColor: Colors.black12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            ),
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
