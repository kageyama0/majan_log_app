import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majan_log_app/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: MajanLogApp()));
}

class MajanLogApp extends StatelessWidget {
  const MajanLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '麻雀ログ',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
