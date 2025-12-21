import '../models/review.dart';
import 'base_provider.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() :  super('api/Reviews');

  @override
  Review fromJson(data) => Review.fromJson(data);
}
