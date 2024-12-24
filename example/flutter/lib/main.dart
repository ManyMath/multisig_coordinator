import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const MultisigApp());
}

class MultisigApp extends StatelessWidget {
  const MultisigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multisig Coordinator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
