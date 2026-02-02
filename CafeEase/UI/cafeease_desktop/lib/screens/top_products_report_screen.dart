import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_item_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TopProductsReportScreen extends StatefulWidget {
  const TopProductsReportScreen({Key? key}) : super(key: key);

  @override
  State<TopProductsReportScreen> createState() =>
      _TopProductsReportScreenState();
}

class _TopProductsReportScreenState extends State<TopProductsReportScreen> {
  bool _isLoading = true;
  final Map<String, int> _salesByProduct = {};

  Future<void> _exportPdf() async {
    final pdf = pw.Document();

    final sortedProducts = _salesByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Top Products Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),

              pw.Text('Total products sold: ${sortedProducts.length}'),
              pw.SizedBox(height: 20),

              pw.Table.fromTextArray(
                headers: ['Rank', 'Product', 'Quantity sold'],
                data: sortedProducts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return ['#${index + 1}', item.key, item.value.toString()];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<OrderItemProvider>();

    try {
      final result = await provider.get(filter: {"paidOnly": true});

      for (var item in result.result) {
        final name = item.productName ?? 'Unknown';
        final qty = item.quantity ?? 0;

        _salesByProduct[name] = (_salesByProduct[name] ?? 0) + qty;
      }

      setState(() => _isLoading = false);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedProducts = _salesByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B5A3C),
        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
        label: const Text('Print PDF', style: TextStyle(color: Colors.white)),
        onPressed: _exportPdf,
      ),

      appBar: AppBar(
        title: const Text('Top products'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sortedProducts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final p = sortedProducts[index];

                return Card(
                  color: const Color(0xFFD2B48C),
                  child: ListTile(
                    leading: Text(
                      '#${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: Text(p.key),
                    trailing: Text(
                      '${p.value} sold',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
