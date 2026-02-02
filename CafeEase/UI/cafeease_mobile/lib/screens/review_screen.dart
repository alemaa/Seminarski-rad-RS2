import 'package:cafeease_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../models/review_insert_request.dart';
import '../providers/review_provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class ReviewsScreen extends StatefulWidget {
  final int? initialProductId;

  const ReviewsScreen({super.key, this.initialProductId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _loading = true;
  String? _error;

  List<Review> _myReviews = [];

  final _formKey = GlobalKey<FormState>();
  int? _productId;
  int? _rating;
  final _commentCtrl = TextEditingController();

  bool _productsLoading = true;
  List<Product> _products = [];

  int? _filterProductId;
  int? _filterRating;

  @override
  void initState() {
    super.initState();
    _productId = widget.initialProductId;
    _filterProductId = widget.initialProductId;

    _rating = null;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadProducts();
      await _loadMyReviews();
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() => _productsLoading = true);
      final productProvider = context.read<ProductProvider>();
      final res = await productProvider.get();
      setState(() {
        _products = res.result;
        _productsLoading = false;
      });
    } catch (e) {
      setState(() {
        _productsLoading = false;
      });
    }
  }

  Future<void> _loadMyReviews() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final reviewProvider = context.read<ReviewProvider>();

      final filter = <String, dynamic>{
        "userId": Authorization.userId,
      };

      if (_filterProductId != null) {
        filter["productId"] = _filterProductId;
      }
      if (_filterRating != null) {
        filter["rating"] = _filterRating;
      }

      final res = await reviewProvider.get(filter: filter);

      setState(() {
        _myReviews = res.result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _filterProductId = null;
      _filterRating = null;
    });
    _loadMyReviews();
  }

  Color _ratingColor(int r) {
    if (r >= 4) return Colors.green;
    if (r == 3) return Colors.orange;
    return Colors.red;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      final reviewProvider = context.read<ReviewProvider>();

      final req = ReviewInsertRequest(
        productId: _productId!,
        rating: _rating!,
        comment: _commentCtrl.text.trim(),
      );

      await reviewProvider.insert(req.toJson());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review saved")),
      );

      _commentCtrl.clear();
      _formKey.currentState?.reset();
      setState(() {
        _productId = null;
        _rating = null;
      });

      await _loadMyReviews();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFE1D1),
        appBar: AppBar(
          backgroundColor: const Color(0xFF8B5A3C),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text("Reviews", style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "My Reviews"),
              Tab(text: "Add Review"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMyReviewsTab(),
            _buildAddReviewTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      color: Colors.brown.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filters",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            _productsLoading
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<int?>(
                    value: _filterProductId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Product",
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text("All products"),
                      ),
                      ..._products.map(
                        (p) => DropdownMenuItem<int?>(
                          value: p.id,
                          child: Text(p.name ?? "Product #${p.id}"),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() => _filterProductId = v);
                      _loadMyReviews();
                    },
                  ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int?>(
              value: _filterRating,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Rating",
              ),
              items: const [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text("All ratings"),
                ),
                DropdownMenuItem<int?>(value: 5, child: Text("5 / 5")),
                DropdownMenuItem<int?>(value: 4, child: Text("4 / 5")),
                DropdownMenuItem<int?>(value: 3, child: Text("3 / 5")),
                DropdownMenuItem<int?>(value: 2, child: Text("2 / 5")),
                DropdownMenuItem<int?>(value: 1, child: Text("1 / 5")),
              ],
              onChanged: (v) {
                setState(() => _filterRating = v);
                _loadMyReviews();
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear),
                    label: const Text("Clear"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 196, 145, 108),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _loadMyReviews,
                    icon: const Icon(Icons.search, color: Colors.white),
                    label: const Text(
                      "Apply",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMyReviewsTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Failed to load reviews"),
              const SizedBox(height: 8),
              Text(_error!, maxLines: 6, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadMyReviews,
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyReviews,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _myReviews.isEmpty ? 2 : (_myReviews.length + 1),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          if (i == 0) return _buildFilters();

          if (_myReviews.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text("No reviews for selected filter.")),
            );
          }

          final r = _myReviews[i - 1];
          final rating = r.rating ?? 0;

          return Card(
            color: Colors.brown.shade50,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: Text(r.productName ?? "Product #${r.productId ?? ''}"),
              subtitle: Text(r.comment ?? ""),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _ratingColor(rating).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$rating/5",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _ratingColor(rating),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddReviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.brown.shade50,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Product",
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  _productsLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: LinearProgressIndicator(),
                        )
                      : DropdownButtonFormField<int?>(
                          value: _productId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Select product",
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text("Select product"),
                            ),
                            ..._products.map(
                              (p) => DropdownMenuItem<int?>(
                                value: p.id,
                                child: Text(p.name ?? "Product #${p.id}"),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _productId = v),
                          validator: (v) =>
                              v == null ? "Select a product" : null,
                        ),
                  const SizedBox(height: 14),
                  const Text("Rating",
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int?>(
                    value: _rating,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text("Select rating"),
                      ),
                      DropdownMenuItem<int?>(value: 1, child: Text("1 / 5")),
                      DropdownMenuItem<int?>(value: 2, child: Text("2 / 5")),
                      DropdownMenuItem<int?>(value: 3, child: Text("3 / 5")),
                      DropdownMenuItem<int?>(value: 4, child: Text("4 / 5")),
                      DropdownMenuItem<int?>(value: 5, child: Text("5 / 5")),
                    ],
                    onChanged: (v) => setState(() => _rating = v),
                    validator: (v) => v == null ? "Select a rating" : null,
                  ),
                  const SizedBox(height: 14),
                  const Text("Comment",
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _commentCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Write your comment...",
                    ),
                    validator: (v) {
                      final t = (v ?? "").trim();
                      if (t.isEmpty) return "Comment is required";
                      if (t.length < 3) return "Too short";
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 196, 145, 108),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _submit,
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
