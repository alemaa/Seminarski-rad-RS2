import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cafe.dart';
import '../providers/cafe_provider.dart';
import 'cafe_detail_screen.dart';

class CafeListScreen extends StatefulWidget {
  const CafeListScreen({super.key});

  @override
  State<CafeListScreen> createState() => _CafeListScreenState();
}

class _CafeListScreenState extends State<CafeListScreen> {
  List<Cafe> _cafes = [];
  bool _loading = true;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCafes();
  }

  Future<void> _loadCafes() async {
    try {
      final provider = context.read<CafeProvider>();
      final filter = <String, dynamic>{};

      if (_searchText.trim().isNotEmpty) {
        filter['name'] = _searchText.trim();
      }

      final result = await provider.get(filter: filter);

      if (!mounted) return;
      setState(() {
        _cafes = result.result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load cafes: $e')));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: const Text('Cafes'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B5A3C),
        elevation: 8,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CafeDetailScreen()),
          );
          if (result == 'refresh') _loadCafes();
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by cafe name',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF5EDE4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.brown.shade200),
                      ),
                    ),
                    onChanged: (value) {
                      _searchText = value;
                      _loadCafes();
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: _cafes.length,
                      itemBuilder: (_, index) {
                        final cafe = _cafes[index];
                        final isActive = cafe.isActive == true;

                        return Card(
                          elevation: 2,
                          color: const Color(0xFFD7BFA6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              cafe.name ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${cafe.address ?? ''}, ${cafe.cityName ?? ''}',
                            ),
                            trailing: Tooltip(
                              message: isActive
                                  ? 'Active cafe'
                                  : 'Inactive cafe',
                              child: Icon(
                                isActive ? Icons.check_circle : Icons.cancel,
                                color: isActive ? Colors.green : Colors.red,
                              ),
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CafeDetailScreen(cafe: cafe),
                                ),
                              );
                              if (result == 'refresh') _loadCafes();
                            },
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
