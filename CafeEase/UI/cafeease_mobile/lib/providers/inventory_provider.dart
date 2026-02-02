import '../models/inventory.dart';
import 'base_provider.dart';

class InventoryProvider extends BaseProvider<Inventory> {
  InventoryProvider() : super("api/Inventory");

  @override
  Inventory fromJson(data) => Inventory.fromJson(data);

  Future<int> getStockForProduct(int productId) async {
    final res = await get(filter: {"productId": productId});
    if (res.result.isEmpty) return 0;
    return res.result.first.quantity ?? 0;
  }
}
