import 'package:flutter/material.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class OrdersReportScreen extends StatefulWidget {
  const OrdersReportScreen({super.key});
  

  @override
  State<OrdersReportScreen> createState() => _OrdersReportScreenState();
}

class _OrdersReportScreenState extends State<OrdersReportScreen> {
  List<Order> _orders = [];
  bool _isLoading = false;

  DateTime? _dateFrom;
  DateTime? _dateTo;

  double _totalAmount() {
    double sum = 0;
    for (var o in _orders) {
      sum += o.totalAmount ?? 0;
    }
    return sum;
  }

  Future<void> _pickDateFrom() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _dateFrom = date);
      _loadOrders();
    }
  }

  Future<void> _pickDateTo() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _dateTo = date);
      _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    final provider = context.read<OrderProvider>();

    setState(() => _isLoading = true);

    try {
      final result = await provider.get();

      List<Order> filtered = result.result;

      if (_dateFrom != null) {
        filtered = filtered
            .where(
              (o) =>
                  o.orderDate != null &&
                  o.orderDate!.isAfter(
                    DateTime(_dateFrom!.year, _dateFrom!.month, _dateFrom!.day),
                  ),
            )
            .toList();
      }

      if (_dateTo != null) {
        filtered = filtered
            .where(
              (o) =>
                  o.orderDate != null &&
                  o.orderDate!.isBefore(
                    DateTime(
                      _dateTo!.year,
                      _dateTo!.month,
                      _dateTo!.day,
                      23,
                      59,
                      59,
                    ),
                  ),
            )
            .toList();
      }

      setState(() {
        _orders = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportOrdersPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Orders Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),

              pw.Text('Total orders: ${_orders.length}'),
              pw.Text(
                'Total amount: ${_orders.fold<double>(0, (sum, o) => sum + (o.totalAmount ?? 0)).toStringAsFixed(2)} KM',
              ),

              pw.SizedBox(height: 20),

              pw.TableHelper.fromTextArray(
                headers: ['ID', 'Date', 'Status', 'Total'],
                data: _orders.map((o) {
                  return [
                    o.id.toString(),
                    o.orderDate != null
                        ? o.orderDate!.toString().substring(0, 16)
                        : '',
                    o.status ?? '',
                    o.totalAmount?.toStringAsFixed(2) ?? '0',
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

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B5A3C),
        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
        label: const Text('Print PDF', style: TextStyle(color: Colors.white)),
        onPressed: _exportOrdersPdf,
      ),

      appBar: AppBar(
        title: const Text('Reports – Orders'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickDateFrom,
                    child: Text(
                      _dateFrom == null
                          ? 'Date from'
                          : DateFormat('dd.MM.yyyy').format(_dateFrom!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickDateTo,
                    child: Text(
                      _dateTo == null
                          ? 'Date to'
                          : DateFormat('dd.MM.yyyy').format(_dateTo!),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFD2B48C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total orders: ${_orders.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total amount: ${_totalAmount().toStringAsFixed(2)} KM',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = _orders[index];

                        return Card(
                          color: const Color(0xFFD2B48C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              'Order #${order.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: ${DateFormat('dd.MM.yyyy HH:mm').format(order.orderDate!)}',
                                ),
                                Text(
                                  'Total: ${order.totalAmount?.toStringAsFixed(2)} KM',
                                ),
                                Text('Status: ${order.status}'),
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
