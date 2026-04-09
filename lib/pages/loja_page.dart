import 'package:flutter/material.dart';
import '../app_state.dart';
import '../db_service.dart';

class LojaPage extends StatefulWidget {
  const LojaPage({super.key});

  @override
  State<LojaPage> createState() => _LojaPageState();
}


class _LojaPageState extends State<LojaPage> {
  late Future<List<Map<String, dynamic>>> lojasFuture;

  @override
  void initState() {
    super.initState();
    lojasFuture = DbService.getLojas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar Loja')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: lojasFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lojas = snapshot.data!;

          return ListView.builder(
            itemCount: lojas.length,
            itemBuilder: (context, index) {
              final loja = lojas[index];

              return ListTile(
                title: Text(loja['nome'] ?? ''),
                subtitle: Text('Código: ${loja['loja']}'),
                onTap: () async {
                  // salva no estado global
                  AppState.loja = loja['loja'];
                  await AppState.save();
                  if (!mounted) return;

                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}