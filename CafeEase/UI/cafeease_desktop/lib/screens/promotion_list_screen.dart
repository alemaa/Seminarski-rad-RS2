import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/promotion.dart';
import '../providers/promotion_provider.dart';
import 'promotion_edit_screen.dart';

class PromotionListScreen extends StatefulWidget {
  const PromotionListScreen({super.key});

  @override
  State<PromotionListScreen> createState() => _PromotionListScreenState();
}

class _PromotionListScreenState extends State<PromotionListScreen> {
  bool _isLoading = true;
  bool _activeOnly = false;
  List<Promotion> _promotions = [];

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    final provider = context.read<PromotionProvider>();

    setState(() => _isLoading = true);

    final filter = <String, dynamic>{};
    if (_activeOnly) {
      filter['activeOnly'] = true;
    }

    try {
      final result = await provider.get(filter: filter);
      setState(() {
        _promotions = result.result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load promotions: $e')));
    }
  }

  Future<void> _deletePromotion(int id) async {
    final provider = context.read<PromotionProvider>();
    await provider.delete(id);
    _loadPromotions();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Promotion successfully deleted'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _confirmDelete(Promotion p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete promotion'),
        content: Text('Are you sure you want to delete promotion "${p.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deletePromotion(p.id);
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    return '${d.day}.${d.month}.${d.year}';
  }

  bool _isActive(Promotion p) {
    final now = DateTime.now();
    return p.startDate.isBefore(now) && p.endDate.isAfter(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: const Text('Promotions'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B5A3C),
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PromotionEditScreen()),
          );
          if (result == 'refresh') _loadPromotions();
        },
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Active promotions only'),
            value: _activeOnly,
            onChanged: (value) {
              setState(() => _activeOnly = value);
              _loadPromotions();
            },
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _promotions.isEmpty
                ? const Center(child: Text('No promotions found'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _promotions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final p = _promotions[index];
                      final active = _isActive(p);

                      return Card(
                        color: active
                            ? const Color(0xFFD2B48C)
                            : Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            p.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (p.description != null &&
                                  p.description!.trim().isNotEmpty)
                                Text('Description: ${p.description}'),
                              Text(
                                'Discount: ${p.discountPercent.toStringAsFixed(0)}%',
                              ),
                              Text('Segment: ${p.targetSegment ?? "ALL"}'),

                              Text(
                                p.categories.isEmpty
                                    ? 'Categories: -'
                                    : 'Categories: ${p.categories.map((c) => c.name).join(', ')}',
                              ),

                              Text(
                                '${_formatDate(p.startDate)} → ${_formatDate(p.endDate)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                active ? 'ACTIVE' : 'EXPIRED',
                                style: TextStyle(
                                  color: active ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(p),
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PromotionEditScreen(promotion: p),
                              ),
                            );
                            if (result == 'refresh') _loadPromotions();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
