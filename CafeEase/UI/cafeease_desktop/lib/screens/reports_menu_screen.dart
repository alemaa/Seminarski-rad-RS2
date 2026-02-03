import 'package:cafeease_desktop/screens/sales_summary_report_screen.dart';
import 'package:cafeease_desktop/screens/top_products_report_screen.dart';
import 'package:flutter/material.dart';
import 'orders_report_screen.dart';
import 'inventory_report_screen.dart';

class ReportsMenuScreen extends StatelessWidget {
  const ReportsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'View and analyze key business data such as orders, inventory and top products.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 32),

            Expanded(
              child: Center(
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _ReportCard(
                      title: 'Orders report',
                      icon: Icons.receipt_long,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OrdersReportScreen(),
                          ),
                        );
                      },
                    ),
                    _ReportCard(
                      title: 'Inventory report',
                      icon: Icons.inventory,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const InventoryReportScreen(),
                          ),
                        );
                      },
                    ),
                    _ReportCard(
                      title: 'Top products report',
                      icon: Icons.emoji_events,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TopProductsReportScreen(),
                          ),
                        );
                      },
                    ),
                     _ReportCard(
                      title: 'Sales summary report',
                      icon: Icons.emoji_events,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SalesSummaryReportScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        color: const Color(0xFFD2B48C),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF3E2723)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3E2723),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
