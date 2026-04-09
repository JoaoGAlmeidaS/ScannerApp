import 'package:flutter/material.dart';
import '../app_state.dart';

class SecaoPage extends StatefulWidget {
  const SecaoPage({super.key});

  @override
  State<SecaoPage> createState() => _SecaoPageState();
}

class _SecaoPageState extends State<SecaoPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = AppState.secao;
  }

  void _salvar() {
    if (_controller.text.isNotEmpty) {
      AppState.secao = _controller.text;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Definir Seção')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Digite a seção:'),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvar,
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}