import 'package:cafeease_desktop/models/order_item.dart';
import 'package:cafeease_desktop/providers/inventory_provider.dart';
import 'package:cafeease_desktop/providers/order_item_provider.dart';
import 'package:cafeease_desktop/providers/order_provider.dart';
import 'package:cafeease_desktop/providers/reservation_provider.dart';
import 'package:cafeease_desktop/providers/table_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'screens/login_screen.dart';
import 'providers/category_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => TableProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => OrderItemProvider()),
      ],
      child: const CafeEaseApp(),
    ),
  );
}

class CafeEaseApp extends StatelessWidget {
  const CafeEaseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CafeEase Admin',
      home: const LoginScreen(),
    );
  }
}
