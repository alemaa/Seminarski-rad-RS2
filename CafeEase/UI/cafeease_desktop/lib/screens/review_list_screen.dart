import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/review.dart';
import '../../providers/review_provider.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({Key? key}) : super(key: key);

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  bool _isLoading = true;
  List<Review> _reviews = [];

  int? _selectedRating;

  @override
  void initState() {
    super.initState();
    _selectedRating = null;
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final provider = context.read<ReviewProvider>();
    try {
      final filter = <String, dynamic>{};

      if (_selectedRating != null) {
        filter['rating'] = _selectedRating;
      }

      final result = await provider.get(filter: filter);

      setState(() {
        _reviews = result.result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteReview(int id) async {
    final provider = context.read<ReviewProvider>();
    await provider.delete(id);
    _loadReviews();
  }

  String _formatDate(DateTime dt) => DateFormat('dd.MM.yyyy HH:mm').format(dt);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE1D1),
      appBar: AppBar(
        title: const Text('Reviews'),
        backgroundColor: const Color(0xFF8B5A3C),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<int?>(
              value: _selectedRating,
              decoration: InputDecoration(
                labelText: 'Rating',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('All')),
                ...List.generate(5, (index) {
                  final rating = index + 1;
                  return DropdownMenuItem<int?>(
                    value: rating,
                    child: Text('$rating ⭐'),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRating = value;
                });
                _loadReviews();
              },
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reviews.isEmpty
                ? const Center(child: Text('No reviews found'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final r = _reviews[index];

                      return Card(
                        color: const Color(0xFFD2B48C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            r.productName ?? 'Unknown product',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('User: ${r.userFullName ?? 'Unknown'}'),
                              Text('Rating: ${r.rating} ⭐'),
                              if (r.comment != null && r.comment!.isNotEmpty)
                                Text('Comment: ${r.comment}'),
                              Text(
                                'Date: ${_formatDate(r.dateCreated)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteReview(r.id),
                          ),
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
