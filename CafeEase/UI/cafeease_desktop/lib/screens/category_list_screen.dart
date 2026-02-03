import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/category_provider.dart';
import 'category_detail_screen.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List<Category> _categories = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final provider = context.read<CategoryProvider>();

    try {
      final filter = <String, dynamic>{};

      if (_searchText.trim().isNotEmpty) {
        filter['name'] = _searchText.trim();
      }

      final result = await provider.get(filter: filter);

      setState(() {
        _categories = result.result;
        _loading = false;
      });

    } catch (e) {
      _loading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load categories')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Color(0xFF8B5A3C),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryDetailScreen()),
              );

              if (result == 'refresh') {
                _loadCategories();
              }
            },
          ),
        ],
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
                      hintText: 'Search categories...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchText = '');
                                _loadCategories();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      _searchText = value;
                      _loadCategories();
                    },
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (_, index) {
                        final category = _categories[index];

                        return Card(
                          color: const Color(0xFFD2B48C),
                          child: ListTile(
                            title: Text(category.name ?? ''),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CategoryDetailScreen(category: category),
                                ),
                              );

                              if (result == 'refresh') {
                                _loadCategories();
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
    );
  }
}
