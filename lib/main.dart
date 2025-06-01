import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:probably_a_scam/scam_analyzer_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Probably A Scam',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const ScamAnalyzerScreen(),
    );
  }
}
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp(Set<dynamic> set, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Probably A Scam',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const ScamAnalyzerScreen(),
    );
  }
}