import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scanner_app/app_state.dart';
import 'package:scanner_app/db_service.dart';
import 'package:audioplayers/audioplayers.dart';

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
  late AudioPlayer audioPlayer;
  bool _mostrarErroCodigoNaoCadastrado = false;
  bool _habilitarQuantidadeLocal = true;
  int total = 0;
  
  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();

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
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> enviarCodigo({bool viaEnter = false}) async {
    final codigoLido = controller.text.trim();

    if (codigoLido.isEmpty) return;

    // Se quantidade está habilitada mas não foi preenchida, foca no campo de quantidade
    if (AppState.permitirQuantidade && _habilitarQuantidadeLocal && quantidadeController.text.trim().isEmpty) {
      focusNodeQuantidade.requestFocus();
      return;
    }

    // Obter quantidade
    int qtd = 1;
    if (AppState.permitirQuantidade && _habilitarQuantidadeLocal) {
      final quantidadeTexto = quantidadeController.text.trim();
      qtd = int.tryParse(quantidadeTexto) ?? 1;
      if (qtd < 1) qtd = 1;
    }

    if (!AppState.permitirCodigosNaoCadastrados) {
      final desc = await DbService.getDescricaoProduto(codigoLido);
      if (desc == null) {
        // Vibração de erro - 3 pulsos moderados
        try {
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 150));
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 150));
          await HapticFeedback.mediumImpact();
        } catch (e) {
          // Ignorar se vibração não funcionar
        }

        // Play error beep
        try {
          await audioPlayer.play(AssetSource('sounds/error_beep.wav'));
        } catch (e) {
          // Ignorar se arquivo de áudio não existir
        }

        // Select the text
        controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);

        // Show error message
        setState(() => _mostrarErroCodigoNaoCadastrado = true);

        // Keep focus on the field
        focusNode.requestFocus();
        return;
      }
    }

    try {
      // Inserir um registro com a quantidade
      // LIDO: 0 = via ENTER do teclado, 1 = via botão OK
      await DbService.salvarLeitura(
        codigo: codigoLido,
        loja: AppState.loja,
        secao: AppState.secao,
        coletor: AppState.nome,
        lido: viaEnter ? 0 : 1,
        quantidade: qtd,
      );

      controller.clear();
      quantidadeController.clear();

      // Clear error message on successful save
      setState(() => _mostrarErroCodigoNaoCadastrado = false);

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
              // Toggle para habilitar/desabilitar quantidade (só aparece se permitirQuantidade estiver ativo)
              if (AppState.permitirQuantidade) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Habilitar Quantidade'),
                  value: _habilitarQuantidadeLocal,
                  onChanged: (value) {
                    setState(() {
                      _habilitarQuantidadeLocal = value;
                      if (!value) {
                        quantidadeController.clear();
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Digite ou escaneie o código',
                      ),
                      onSubmitted: (_) => enviarCodigo(viaEnter: true),
                    ),
                  ),
                  if (!AppState.permitirQuantidade || !_habilitarQuantidadeLocal) ...[
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => enviarCodigo(viaEnter: false),
                      child: const Text("OK"),
                    ),
                  ],
                ],
              ),
              if (AppState.permitirQuantidade && _habilitarQuantidadeLocal) ...[
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
                        onSubmitted: (_) => enviarCodigo(viaEnter: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => enviarCodigo(viaEnter: false),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),        if (_mostrarErroCodigoNaoCadastrado)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.red.shade100,
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Código não cadastrado no banco de produtos',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),        const Divider(),

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
                  "${item['codigo']} - ${item['descr'] ?? 'Sem descrição'} (Qtde: ${item['qtde'] ?? 1})",
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
      // Verificar se é formato ISO (datahora)
      if (dataHora.contains('T') || dataHora.contains('-')) {
        final dt = DateTime.parse(dataHora);
        return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year.toString().substring(2)} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      
      // Se não, é o novo formato (DDMMYY HHMMSS)
      final partes = dataHora.split(' ');
      if (partes.length == 2) {
        final dia = partes[0];
        final hora = partes[1];
        
        // Extrair componentes
        final diaStr = dia.substring(0, 2);  // DD
        final mesStr = dia.substring(2, 4);  // MM
        final anoStr = dia.substring(4, 6);  // YY
        
        final horaStr = hora.substring(0, 2);  // HH
        final minStr = hora.substring(2, 4);   // MM
        
        return '$diaStr/$mesStr/$anoStr $horaStr:$minStr';
      }
      
      return dataHora;
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
        content: Text("Deseja remover 1 unidade do código $codigo?"),
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