import 'package:flutter/material.dart';
import 'pages/config_page.dart';
import 'pages/menu_page.dart';
import 'app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: (AppState.nome.isNotEmpty && AppState.loja.isNotEmpty)
          ? const MenuPage()
          : const ConfigPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}