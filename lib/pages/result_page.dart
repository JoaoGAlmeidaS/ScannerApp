// Página não utilizada

import 'package:flutter/material.dart';
import '../app_state.dart';
import '../db_service.dart';

class ResultPage extends StatefulWidget {
  final String codigoLido;
  

  const ResultPage({super.key, required this.codigoLido});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {

  String? descricao;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarDescricao();
  }

  Future<void> carregarDescricao() async {
    final desc = await DbService.getDescricaoProduto(widget.codigoLido);

    if (!mounted) return;

    setState(() {
      descricao = desc;
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Código lido:'),
            const SizedBox(height: 20),
            Text(
              "Código: ${widget.codigoLido}",
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 10),

            carregando
                ? const CircularProgressIndicator()
                : Text(
                    "Descrição: ${descricao ?? 'Não cadastrado'}",
                    style: const TextStyle(fontSize: 18),
                  ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white)
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);

                    await DbService.salvarLeitura(
                      codigo: widget.codigoLido,
                      loja: AppState.loja,
                      secao: AppState.secao,
                      coletor: AppState.nome,
                      );

                    if (!mounted) return;

                    navigator.pop(); // volta pra câmera
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, 
                  ),
                  child: const Text('OK',
                    style: TextStyle(color: Colors.white)
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
