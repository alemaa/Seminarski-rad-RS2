import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_item_provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TopProductsReportScreen extends StatefulWidget {
  const TopProductsReportScreen({super.key});

  @override
  State<TopProductsReportScreen> createState() =>
      _TopProductsReportScreenState();
}

class _TopProductsReportScreenState extends State<TopProductsReportScreen> {
  bool _isLoading = true;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _top5Only = false;

  final Map<String, int> _salesByProduct = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day.$month.$year';
  }

  Future<void> _pickDateFrom() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (!mounted) return;

    if (date != null) {
      if (_dateTo != null && date.isAfter(_dateTo!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Date from cannot be after date to')),
        );
        return;
      }

      setState(() => _dateFrom = date);
      await _loadData();
    }
  }

  Future<void> _pickDateTo() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (!mounted) return;

    if (date != null) {
      if (_dateFrom != null && date.isBefore(_dateFrom!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Date to cannot be before date from')),
        );
        return;
      }

      setState(() => _dateTo = date);
      await _loadData();
    }
  }

  Future<void> _loadData() async {
    final orderProvider = context.read<OrderProvider>();
    final orderItemProvider = context.read<OrderItemProvider>();

    setState(() {
      _isLoading = true;
      _salesByProduct.clear();
    });

    try {
      final ordersResult = await orderProvider.get();
      List<Order> filteredOrders = List<Order>.from(ordersResult.result);

      if (_dateFrom != null) {
        final from = DateTime(
          _dateFrom!.year,
          _dateFrom!.month,
          _dateFrom!.day,
        );

        filteredOrders = filteredOrders.where((o) {
          if (o.orderDate == null) return false;
          return !o.orderDate!.isBefore(from);
        }).toList();
      }

      if (_dateTo != null) {
        final to = DateTime(
          _dateTo!.year,
          _dateTo!.month,
          _dateTo!.day,
          23,
          59,
          59,
        );

        filteredOrders = filteredOrders.where((o) {
          if (o.orderDate == null) return false;
          return !o.orderDate!.isAfter(to);
        }).toList();
      }

      final allowedOrderIds = filteredOrders.map((o) => o.id).toSet();

      final itemsResult = await orderItemProvider.get(
        filter: {"paidOnly": true},
      );

      final filteredItems = itemsResult.result.where((item) {
        return item.orderId != null && allowedOrderIds.contains(item.orderId);
      }).toList();

      for (var item in filteredItems) {
        final name = item.productName ?? 'Unknown';
        final qty = item.quantity ?? 0;
        _salesByProduct[name] = (_salesByProduct[name] ?? 0) + qty;
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportPdf() async {
    final pdf = pw.Document();

    final sortedProducts = _salesByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final displayedProducts = _top5Only
        ? sortedProducts.take(5).toList()
        : sortedProducts;

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
              pw.SizedBox(height: 8),
              pw.Text(
                'Range: '
                '${_dateFrom != null ? _formatDate(_dateFrom) : 'Beginning'}'
                ' - '
                '${_dateTo != null ? _formatDate(_dateTo) : 'Today'}',
              ),
              pw.Text('Mode: ${_top5Only ? 'Top 5' : 'All'}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Rank', 'Product', 'Quantity sold'],
                data: displayedProducts.asMap().entries.map((entry) {
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
  Widget build(BuildContext context) {
    final sortedProducts = _salesByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final displayedProducts = _top5Only
        ? sortedProducts.take(5).toList()
        : sortedProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      floatingActionButton: Tooltip(
        message: displayedProducts.isEmpty ? 'No data to export' : 'Export PDF',
        child: FloatingActionButton.extended(
          backgroundColor: displayedProducts.isEmpty
              ? Colors.grey
              : const Color(0xFF8B5A3C),
          icon: Icon(
            Icons.picture_as_pdf,
            color: displayedProducts.isEmpty ? Colors.white70 : Colors.white,
          ),
          label: Text(
            'Print PDF',
            style: TextStyle(
              color: displayedProducts.isEmpty ? Colors.white70 : Colors.white,
            ),
          ),
          onPressed: displayedProducts.isEmpty ? null : _exportPdf,
        ),
      ),
      appBar: AppBar(
        title: const Text('Top products'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _pickDateFrom,
                          child: Text(
                            _dateFrom == null
                                ? 'Date from'
                                : _formatDate(_dateFrom),
                          ),
                        ),
                      ),
                      if (_dateFrom != null)
                        IconButton(
                          tooltip: 'Clear date from',
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            setState(() => _dateFrom = null);
                            await _loadData();
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _pickDateTo,
                          child: Text(
                            _dateTo == null ? 'Date to' : _formatDate(_dateTo),
                          ),
                        ),
                      ),
                      if (_dateTo != null)
                        IconButton(
                          tooltip: 'Clear date to',
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            setState(() => _dateTo = null);
                            await _loadData();
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Show:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('All'),
                  selected: !_top5Only,
                  onSelected: (_) {
                    setState(() => _top5Only = false);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Top 5'),
                  selected: _top5Only,
                  onSelected: (_) {
                    setState(() => _top5Only = true);
                  },
                ),
                const Spacer(),
                if (_dateFrom != null || _dateTo != null)
                  TextButton.icon(
                    onPressed: () async {
                      setState(() {
                        _dateFrom = null;
                        _dateTo = null;
                      });
                      await _loadData();
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Reset'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : displayedProducts.isEmpty
                  ? const Center(child: Text('No data found'))
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 90),
                      itemCount: displayedProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final p = displayedProducts[index];

                        return Card(
                          color: const Color(0xFFD2B48C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Text(
                              '#${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            title: Text(p.key),
                            trailing: Text(
                              '${p.value} sold',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
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
