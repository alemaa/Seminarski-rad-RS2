import '../models/table.dart';
import 'base_provider.dart';

class TableProvider extends BaseProvider<Table> {
  TableProvider() : super('api/Tables');

  @override
  Table fromJson(data) {
    return Table.fromJson(data);
  }
}
