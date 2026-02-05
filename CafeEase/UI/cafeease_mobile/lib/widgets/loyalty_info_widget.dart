import 'package:flutter/material.dart';
import '../utils/util.dart';
import '../providers/loyalty_points_provider.dart';
import 'package:provider/provider.dart';

class LoyaltyInfoWidget extends StatefulWidget {
  const LoyaltyInfoWidget({super.key});

  @override
  State<LoyaltyInfoWidget> createState() => _LoyaltyInfoWidgetState();
}

class _LoyaltyInfoWidgetState extends State<LoyaltyInfoWidget> {
  int _points = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final provider = context.read<LoyaltyPointsProvider>();
      final res = await provider.get(
        filter: {"userId": Authorization.userId},
      );

      setState(() {
        _points = res.result.isNotEmpty ? res.result.first.points : 0;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.brown.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.stars, color: Color(0xFF8B5A3C)),
            const SizedBox(width: 8),
            _loading
                ? const Text("Loading loyalty points...")
                : Text(
                    "Loyalty points: $_points",
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
          ],
        ),
      ),
    );
  }
}
