import 'package:flutter/material.dart';
import '../utils/authorization.dart';
import 'login_screen.dart';
import 'product_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 208, 182, 160),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 160, 122, 104),
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
          )
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
                childAspectRatio: 1.8,
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
                      // TODO: Navigator → CategoryScreen
                    },
                  ),
                  _buildCard(
                    icon: Icons.event_seat,
                    title: 'Reservations',
                    onTap: () {
                      // TODO: Navigator → ReservationScreen
                    },
                  ),
                  _buildCard(
                    icon: Icons.star_rate,
                    title: 'Reviews',
                    onTap: () {
                      // TODO: Navigator → ReviewScreen
                    },
                  ),
                  _buildCard(
                    icon: Icons.receipt_long,
                    title: 'Orders',
                    onTap: () {
                      // TODO: Navigator → OrdersScreen
                    },
                  ),
                  _buildCard(
                    icon: Icons.bar_chart,
                    title: 'Reports',
                    onTap: () {
                      // TODO: Navigator → ReportsScreen
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
        color: const Color.fromARGB(255, 160, 122, 104),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
