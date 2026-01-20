import 'package:cafeease_mobile/providers/city_provider.dart';
import 'package:cafeease_mobile/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'screens/login_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/order_item_provider.dart';
import 'providers/review_provider.dart';
import 'providers/user_provider.dart';
import 'providers/recommendation_provider.dart';
import 'providers/reservation_provider.dart';
import 'providers/table_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => OrderItemProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => TableProvider()),
        ChangeNotifierProvider(create: (_) => CityProvider()),
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
      title: 'CafeEase Mobile',
      home: const LoginScreen(),
    );
  }
}
