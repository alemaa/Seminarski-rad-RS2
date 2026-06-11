import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/city.dart';
import '../providers/city_provider.dart';
import 'city_detail_screen.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  List<City> _cities = [];
  bool _loading = true;

  final _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    final provider = context.read<CityProvider>();

    try {
      final result = await provider.get();

      if (!mounted) return;
      setState(() {
        _cities = result.result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load cities')));
    }
  }

  List<City> get _filteredCities {
    final query = _searchText.trim().toLowerCase();

    if (query.isEmpty) return _cities;

    return _cities.where((city) {
      return (city.name ?? '').toLowerCase().contains(query);
    }).toList();
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
        title: const Text('Cities'),
        backgroundColor: const Color(0xFF8B5A3C),
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
                      hintText: 'Search by name...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchText = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchText = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filteredCities.isEmpty
                        ? const Center(child: Text('No cities found'))
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 90),
                            itemCount: _filteredCities.length,
                            itemBuilder: (_, index) {
                              final city = _filteredCities[index];

                              return Card(
                                color: const Color(0xFFD2B48C),
                                child: ListTile(
                                  title: Text(city.name ?? ''),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CityDetailScreen(city: city),
                                      ),
                                    );

                                    if (result == 'refresh') {
                                      _loadCities();
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B5A3C),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CityDetailScreen()),
          );

          if (result == 'refresh') {
            _loadCities();
          }
        },
      ),
    );
  }
}
