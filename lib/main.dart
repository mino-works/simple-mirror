import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/mirror_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '占いミラー',
      theme: ThemeData(
        fontFamily: 'Hiragino Sans',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MirrorScreen(),
    );
  }
}
