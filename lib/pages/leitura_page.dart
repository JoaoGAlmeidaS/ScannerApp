import 'package:flutter/material.dart';
import 'package:scanner_app/app_state.dart';
import 'package:scanner_app/db_service.dart';

class LeituraPage extends StatefulWidget {
  const LeituraPage({super.key});

  @override
  State<LeituraPage> createState() => _LeituraPageState();
}

class _LeituraPageState extends State<LeituraPage> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController quantidadeController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final FocusNode focusNodeQuantidade = FocusNode();
  int total = 0;
  
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      focusNode.requestFocus();
    });

    carregarLeituras();
  }

  @override
  void dispose() {
    controller.dispose();
    quantidadeController.dispose();
    focusNode.dispose();
    focusNodeQuantidade.dispose();
    super.dispose();
  }

  Future<void> enviarCodigo() async {
    final codigoLido = controller.text.trim();

    if (codigoLido.isEmpty) return;

    // Se quantidade está habilitada mas não foi preenchida, foca no campo de quantidade
    if (AppState.permitirQuantidade && quantidadeController.text.trim().isEmpty) {
      focusNodeQuantidade.requestFocus();
      return;
    }

    // Obter quantidade
    int qtd = 1;
    if (AppState.permitirQuantidade) {
      final quantidadeTexto = quantidadeController.text.trim();
      qtd = int.tryParse(quantidadeTexto) ?? 1;
      if (qtd < 1) qtd = 1;
    }

    if (!AppState.permitirCodigosNaoCadastrados) {
      final desc = await DbService.getDescricaoProduto(codigoLido);
      if (desc == null) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Código não cadastrado'),
            content: const Text(
              'Este código não está cadastrado no banco de produtos. Ative a opção "Permitir códigos não cadastrados" nas configurações para continuar.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

    try {
      // Inserir múltiplos registros conforme a quantidade
      for (int i = 0; i < qtd; i++) {
        await DbService.salvarLeitura(
          codigo: codigoLido,
          loja: AppState.loja,
          secao: AppState.secao,
          coletor: AppState.nome,
          lido: AppState.permitirCodigosNaoCadastrados ? 1 : 0,
        );
      }

      controller.clear();
      quantidadeController.clear();

      await carregarLeituras();

      focusNode.requestFocus();
    } catch (e) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erro ao salvar'),
          content: Text('Não foi possível salvar a leitura: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Leitura de Código"),
      ),
      body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Digite ou escaneie o código',
                      ),
                      onSubmitted: (_) => enviarCodigo(),
                    ),
                  ),
                  if (!AppState.permitirQuantidade) ...[
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: enviarCodigo,
                      child: const Text("OK"),
                    ),
                  ],
                ],
              ),
              if (AppState.permitirQuantidade) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantidadeController,
                        focusNode: focusNodeQuantidade,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Quantidade',
                        ),
                        onSubmitted: (_) => enviarCodigo(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: enviarCodigo,
                      child: const Text("OK"),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const Divider(),

        Text(
          "Últimas leituras: $total",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: ListView.separated(
            itemCount: leituras.length,
            separatorBuilder: (context, index) => const Divider(
              thickness: 2,
              color: Colors.grey,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final item = leituras[index];

              return ListTile(
                title: Text(
                  "${item['codigo']} - ${item['descr'] ?? 'Sem descrição'}",
                ),
                subtitle: Text(
                  item['datahora'] != null
                      ? _formatDataHora(item['datahora'])
                      : '',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deletarLeitura(item['codigo']),
                ),
              );
            },
          ),
        ),
      ],
    ),
    );
  }

  List<Map<String, dynamic>> leituras = [];

  Future<void> carregarLeituras() async {
  final lista = await DbService.getItensPorSecao();
  final qtd = await DbService.getTotalItens();

  setState(() {
    leituras = lista;
    total = qtd;
  });
  }

  String _formatDataHora(String dataHora) {
    try {
      return DateTime.parse(dataHora).toString();
    } catch (_) {
      return dataHora;
    }
  }

  Future<void> deletarLeitura(String codigo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar exclusão"),
          content: Text("Deseja remover 1 leitura do código $codigo?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Excluir",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await DbService.removerUmItem(codigo);
      await carregarLeituras();
    }
  }

}