import '../models/review.dart';
import '../models/review_request.dart';
import 'base_provider.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super("api/Reviews");

  @override
  Review fromJson(data) => Review.fromJson(data);

  Future<Review> createReview(ReviewRequest request) async {
    final response = await insert(request.toJson());
    return response;
  }
}
