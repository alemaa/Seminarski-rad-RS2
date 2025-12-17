import '../models/category.dart';
import 'base_provider.dart';

class CategoryProvider extends BaseProvider<Category> {
  CategoryProvider() : super('api/Categories');

  @override
  Category fromJson(data) {
    return Category.fromJson(data);
  }
}
