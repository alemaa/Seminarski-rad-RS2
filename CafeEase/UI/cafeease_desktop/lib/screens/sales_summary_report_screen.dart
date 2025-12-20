import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/order.dart';
import '../providers/order_provider.dart';

class SalesSummaryReportScreen extends StatefulWidget {
  const SalesSummaryReportScreen({Key? key}) : super(key: key);

  @override
  State<SalesSummaryReportScreen> createState() =>
      _SalesSummaryReportScreenState();
}

class _SalesSummaryReportScreenState extends State<SalesSummaryReportScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final provider = context.read<OrderProvider>();

    try {
      final filter = <String, dynamic>{};

      if (_selectedDate != null) {
        filter['date'] = _selectedDate!.toIso8601String();
      }

      final result = await provider.get(filter: filter);

      setState(() {
        _orders = result.result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double get totalRevenue =>
      _orders.fold(0, (sum, o) => sum + (o.totalAmount ?? 0));

  int get totalOrders => _orders.length;

  double get averageOrderValue =>
      totalOrders == 0 ? 0 : totalRevenue / totalOrders;

  Future<void> _exportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Sales Summary Report',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              _selectedDate == null
                  ? 'All dates'
                  : 'Date: ${DateFormat('dd.MM.yyyy').format(_selectedDate!)}',
            ),
            pw.Divider(),
            pw.SizedBox(height: 10),

            pw.Text('Total revenue: ${totalRevenue.toStringAsFixed(2)} KM'),
            pw.Text('Total orders: $totalOrders'),
            pw.Text(
              'Average order value: ${averageOrderValue.toStringAsFixed(2)} KM',
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: const Text('Sales summary'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B5A3C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Print PDF'),
        onPressed: _exportPdf,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD2B48C),
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _selectedDate == null
                          ? 'Select date'
                          : DateFormat('dd.MM.yyyy')
                              .format(_selectedDate!),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                        initialDate: _selectedDate ?? DateTime.now(),
                      );

                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          _isLoading = true;
                        });
                        _loadOrders();
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  _buildSummaryCard(
                    'Total revenue',
                    '${totalRevenue.toStringAsFixed(2)} KM',
                  ),
                  _buildSummaryCard(
                    'Total orders',
                    '$totalOrders',
                  ),
                  _buildSummaryCard(
                    'Average order value',
                    '${averageOrderValue.toStringAsFixed(2)} KM',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Card(
      color: const Color(0xFFD2B48C),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
