import 'package:flutter/material.dart';
import 'onboarding/disclaimer_page.dart';

void main() {
  runApp(const ClearPathRecoveryApp());
}

class ClearPathRecoveryApp extends StatelessWidget {
  const ClearPathRecoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClearPath Recovery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
        ),
        useMaterial3: true,
      ),
      home: const DisclaimerPage(),
    );
  }
}