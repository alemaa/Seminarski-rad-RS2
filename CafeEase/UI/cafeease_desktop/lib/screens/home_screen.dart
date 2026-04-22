import 'package:flutter/material.dart';
import 'package:cafeease_desktop/screens/category_list_screen.dart';
import 'package:cafeease_desktop/screens/promotion_list_screen.dart';
import 'package:cafeease_desktop/screens/review_list_screen.dart';
import 'package:cafeease_desktop/screens/table_list_screen.dart';
import 'package:cafeease_desktop/screens/user_list_screen.dart';
import '../utils/authorization.dart';
import 'cafe_list_screen.dart';
import 'login_screen.dart';
import 'notification_screen.dart';
import 'order_list_screen.dart';
import 'product_list_screen.dart';
import 'reports_menu_screen.dart';
import 'reservation_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) {
    Authorization.username = null;
    Authorization.password = null;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5A3C),
        elevation: 0,
        title: const Text(
          'CafeEase – Admin Panel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          const Row(
            children: [
              Icon(Icons.person, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to CafeEase',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose an option below to manage the cafe.',
              style: TextStyle(fontSize: 16, color: Colors.brown.shade700),
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                _StatCard(
                  title: 'Modules',
                  value: '11',
                  icon: Icons.dashboard_customize,
                ),
                SizedBox(width: 16),
                _StatCard(
                  title: 'Admin access',
                  value: 'Active',
                  icon: Icons.verified_user,
                ),
                SizedBox(width: 16),
                _StatCard(
                  title: 'System',
                  value: 'Ready',
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
            const SizedBox(height: 28),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 2.1,
                padding: EdgeInsets.zero,
                children: [
                  _HoverCard(
                    icon: Icons.local_cafe,
                    title: 'Products',
                    onTap: () =>
                        _openScreen(context, const ProductListScreen()),
                  ),
                  _HoverCard(
                    icon: Icons.category,
                    title: 'Categories',
                    onTap: () =>
                        _openScreen(context, const CategoryListScreen()),
                  ),
                  _HoverCard(
                    icon: Icons.event_seat,
                    title: 'Tables',
                    onTap: () => _openScreen(context, const TableListScreen()),
                  ),
                  _HoverCard(
                    icon: Icons.book_online,
                    title: 'Reservations',
                    onTap: () =>
                        _openScreen(context, const ReservationListScreen()),
                  ),
                  _HoverCard(
                    icon: Icons.star_rate,
                    title: 'Reviews',
                    onTap: () => _openScreen(context, const ReviewListScreen()),
                  ),
                  _HoverCard(
                    icon: Icons.receipt_long,
                    title: 'Orders',
                    onTap: () => _openScreen(context, const OrderListScreen()),
                  ),
                  _HoverCard(
                    icon: Icons.bar_chart,
                    title: 'Reports',
                    onTap: () =>
                        _openScreen(context, const ReportsMenuScreen()),
                  ),
                  _HoverCard(
                    icon: Icons.manage_accounts,
                    title: 'User management',
                    onTap: () => _openScreen(context, const UserListScreen()),
                  ),
                  _HoverCard(
                    icon: Icons.discount,
                    title: 'Promotions',
                    onTap: () =>
                        _openScreen(context, const PromotionListScreen()),
                  ),
                  _HoverCard(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () =>
                        _openScreen(context, const NotificationsScreen()),
                  ),
                  _HoverCard(
                    icon: Icons.location_on,
                    title: 'Cafes',
                    onTap: () => _openScreen(context, const CafeListScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.brown.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5A3C).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF6B432D)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.brown.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _HoverCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFFB88A6D) : const Color(0xFFC7A48B),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _hover ? Colors.black26 : Colors.black12,
                blurRadius: _hover ? 14 : 8,
                offset: Offset(0, _hover ? 6 : 3),
              ),
            ],
            border: Border.all(
              color: _hover ? const Color(0xFF9C6C4A) : Colors.brown.shade200,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 46, color: const Color(0xFF4E342E)),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
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
      ),
    );
  }
}
