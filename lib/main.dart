import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/adapter.dart';

void main() {
  runApp(const LecturaFacilApp());
}

class LecturaFacilApp extends StatelessWidget {
  const LecturaFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TextAdapter>(create: (_) => TextAdapter()),
      ],
      child: MaterialApp(
        title: 'Lectura Fácil',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
