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

  String _selectedStatus = 'All';

  final List<String> _statusOptions = [
    'All',
    'Pending',
    'Paid',
    'Confirmed',
    'Cancelled',
  ];

  double _totalAmount() {
    double sum = 0;
    for (var o in _orders) {
      sum += o.totalAmount ?? 0;
    }
    return sum;
  }

  String _normalizeStatus(String? status) {
    return (status ?? '').trim().toLowerCase();
  }

  Color _getStatusBadgeColor(String? status) {
    switch (_normalizeStatus(status)) {
      case 'all':
        return Colors.grey.shade500;
      case 'paid':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade700;
      case 'confirmed':
        return Colors.blue.shade600;
      case 'cancelled':
      case 'canceled':
        return Colors.red.shade600;
      default:
        return Colors.brown.shade400;
    }
  }

  String _formatStatusLabel(String? status) {
    switch (_normalizeStatus(status)) {
      case 'all':
        return 'All';
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
      case 'canceled':
        return 'Cancelled';
      default:
        return status?.trim().isNotEmpty == true ? status!.trim() : 'Unknown';
    }
  }

  Widget _buildStatusDropdownBadge(String? status) {
    final color = _getStatusBadgeColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _formatStatusLabel(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    final color = _getStatusBadgeColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _formatStatusLabel(status),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
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
      List<Order> filtered = List<Order>.from(result.result);

      if (_dateFrom != null) {
        final from = DateTime(
          _dateFrom!.year,
          _dateFrom!.month,
          _dateFrom!.day,
        );

        filtered = filtered.where((o) {
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

        filtered = filtered.where((o) {
          if (o.orderDate == null) return false;
          return !o.orderDate!.isAfter(to);
        }).toList();
      }

      if (_normalizeStatus(_selectedStatus) != 'all') {
        filtered = filtered.where((o) {
          return _normalizeStatus(o.status) ==
              _normalizeStatus(_selectedStatus);
        }).toList();
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
              pw.Text('Status filter: ${_formatStatusLabel(_selectedStatus)}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['ID', 'Date', 'Status', 'Total'],
                data: _orders.map((o) {
                  return [
                    o.id.toString(),
                    o.orderDate != null
                        ? DateFormat('dd.MM.yyyy HH:mm').format(o.orderDate!)
                        : '',
                    _formatStatusLabel(o.status),
                    o.totalAmount?.toStringAsFixed(2) ?? '0.00',
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
                  child: Row(
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
                      if (_dateFrom != null)
                        IconButton(
                          tooltip: 'Clear date from',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() => _dateFrom = null);
                            _loadOrders();
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
                            _dateTo == null
                                ? 'Date to'
                                : DateFormat('dd.MM.yyyy').format(_dateTo!),
                          ),
                        ),
                      ),
                      if (_dateTo != null)
                        IconButton(
                          tooltip: 'Clear date to',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() => _dateTo = null);
                            _loadOrders();
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
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      isDense: false,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF8B5A3C)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF8B5A3C),
                          width: 2,
                        ),
                      ),
                    ),
                    selectedItemBuilder: (context) {
                      return _statusOptions.map((status) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: _buildStatusDropdownBadge(status),
                          ),
                        );
                      }).toList();
                    },
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildStatusBadge(status),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedStatus = value;
                      });

                      _loadOrders();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB08968),
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Status filter: '),
                          _buildStatusBadge(_selectedStatus),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
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
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #${order.id}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Date: ${order.orderDate != null ? DateFormat('dd.MM.yyyy HH:mm').format(order.orderDate!) : '-'}',
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total: ${order.totalAmount?.toStringAsFixed(2) ?? '0.00'} KM',
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text(
                                      'Status: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    _buildStatusBadge(order.status),
                                  ],
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
