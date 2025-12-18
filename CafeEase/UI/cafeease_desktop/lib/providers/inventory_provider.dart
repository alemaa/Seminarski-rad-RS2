import '../models/inventory.dart';
import 'base_provider.dart';

class InventoryProvider extends BaseProvider<Inventory> {
  InventoryProvider() : super('api/Inventory');

  @override
  Inventory fromJson(data) {
    return Inventory.fromJson(data);
  }
}
