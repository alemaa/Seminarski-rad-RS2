import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'screens/login_screen.dart';
import 'providers/category_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider()
        ),
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
