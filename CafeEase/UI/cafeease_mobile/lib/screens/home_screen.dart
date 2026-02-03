import 'package:cafeease_mobile/screens/product_detail_screen.dart';
import 'package:cafeease_mobile/screens/reservation_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/util.dart';
import '../models/product.dart';
import '../providers/recommendation_provider.dart';
import '../providers/order_item_provider.dart';
import '../providers/order_provider.dart';
import 'login_screen.dart';
import 'product_list_screen.dart';
import 'cart_screen.dart';
import 'order_screen.dart';
import 'review_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _recLoading = false;
  String? _recError;
  List<Product> _recommended = [];

  final ScrollController _recScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecommendations());
  }

  @override
  void dispose() {
    _recScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _recLoading = true;
      _recError = null;
    });

    try {
      final orderProvider = context.read<OrderProvider>();
      final orderItemProvider = context.read<OrderItemProvider>();
      final recProvider = context.read<RecommendationProvider>();

      final ordersRes =
          await orderProvider.get(filter: {"userId": Authorization.userId});
      final orders = ordersRes.result;

      if (orders.isEmpty || orders.first.id == null) {
        setState(() {
          _recommended = [];
          _recLoading = false;
        });
        return;
      }

      orders.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      final lastOrderId = orders.first.id!;

      final itemsRes =
          await orderItemProvider.get(filter: {"orderId": lastOrderId});
      final items = itemsRes.result;

      if (items.isEmpty || items.first.productId == null) {
        setState(() {
          _recommended = [];
          _recLoading = false;
        });
        return;
      }

      final seedProductId = items.first.productId!;
      final recs = await recProvider.getRecommended(seedProductId);

      setState(() {
        _recommended = recs;
        _recLoading = false;
      });
    } catch (e) {
      setState(() {
        _recError = e.toString();
        _recLoading = false;
      });
    }
  }

  void _logout(BuildContext context) {
    Authorization.username = null;
    Authorization.password = null;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F4E37),
        title: const Text(
          'CafeEase',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh recommendations',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadRecommendations,
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome 👋',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose an option below.',
              style: TextStyle(fontSize: 14, color: Color(0xFF5D4037)),
            ),
            const SizedBox(height: 6),
            const Text(
              "Earn points with every order and unlock special offers!",
              style: TextStyle(fontSize: 11, color: Color(0xFF5D4037)),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: Color(0xFFE0D6CC),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: _buildRecommendationsSection(context),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _buildCard(
                    icon: Icons.local_cafe,
                    title: 'Menu',
                    subtitle: 'Browse menu',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProductListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.event_seat,
                    title: 'Reservation',
                    subtitle: 'Book a table',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReservationListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.shopping_cart,
                    title: 'Cart',
                    subtitle: 'Your items',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.receipt_long,
                    title: 'My Orders',
                    subtitle: 'Order history',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OrdersScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.star_rate,
                    title: 'Add Review',
                    subtitle: 'Rate products',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReviewsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    icon: Icons.person,
                    title: 'Profile',
                    subtitle: 'Account info',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
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

  Widget _buildRecommendationsSection(BuildContext context) {
    Widget header = Row(
      children: [
        const Text(
          "Recommended for you",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF3E2723),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProductListScreen()),
            );
          },
          child: const Text("See all"),
        ),
      ],
    );

    if (_recLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 6),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_recError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 6),
          Text(
            "Failed to load recommendations: $_recError",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      );
    }

    if (_recommended.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 6),
          const Text(
            "No recommendations yet.",
            style: TextStyle(color: Color(0xFF6D4C41)),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 6),
        SizedBox(
          height: 150,
          child: Stack(
            children: [
              ListView.separated(
                controller: _recScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _recommended.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final p = _recommended[i];

                  return SizedBox(
                    width: 150,
                    child: Card(
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: p),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1E3D6),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.recommend,
                                  color: Color(0xFF6F4E37),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                p.name ?? "Unnamed",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF3E2723),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${(p.price ?? 0).toStringAsFixed(2)} KM",
                                style: const TextStyle(
                                  color: Color(0xFF6D4C41),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: _arrowButton(
                  icon: Icons.chevron_left,
                  onTap: () {
                    _recScrollController.animateTo(
                      (_recScrollController.offset - 180).clamp(
                        0.0,
                        _recScrollController.position.maxScrollExtent,
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: _arrowButton(
                  icon: Icons.chevron_right,
                  onTap: () {
                    _recScrollController.animateTo(
                      (_recScrollController.offset + 180).clamp(
                        0.0,
                        _recScrollController.position.maxScrollExtent,
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _arrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Material(
        color: Colors.white.withOpacity(0.9),
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              size: 26,
              color: const Color(0xFF6F4E37),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E3D6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 26, color: const Color(0xFF6F4E37)),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6D4C41),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
