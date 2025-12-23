import 'package:cafeease_desktop/screens/category_list_screen.dart';
import 'package:cafeease_desktop/screens/promotion_list_screen.dart';
import 'package:cafeease_desktop/screens/review_list_screen.dart';
import 'package:cafeease_desktop/screens/table_list_screen.dart';
import 'package:cafeease_desktop/screens/user_list_screen.dart';
import 'package:flutter/material.dart';
import '../utils/authorization.dart';
import 'login_screen.dart';
import 'product_list_screen.dart';
import 'reservation_list_screen.dart';
import 'order_list_screen.dart';
import 'reports_menu_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5A3C),
        title: const Text(
          'CafeEase – Admin Panel',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Authorization.username = null;
              Authorization.password = null;

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to CafeEase',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose an option below to manage the cafe.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),

            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 2,
                padding: const EdgeInsets.all(24),
                children: [
                  _buildCard(
                    icon: Icons.local_cafe,
                    title: 'Products',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProductListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.category,
                    title: 'Categories',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CategoryListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.event_seat,
                    title: 'Tables',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TableListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.event_seat,
                    title: 'Reservations',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReservationListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.star_rate,
                    title: 'Reviews',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReviewListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.receipt_long,
                    title: 'Orders',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OrderListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.bar_chart,
                    title: 'Reports',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReportsMenuScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.manage_accounts,
                    title: 'User management',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UserListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.discount,
                    title: 'Promotion',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PromotionListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        color: const Color(0xFFC7A48B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: const Color(0xFF4E342E)),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3E2723),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
