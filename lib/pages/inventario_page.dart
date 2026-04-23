import 'package:flutter/material.dart';
import '../db_service.dart';
import '../app_state.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, List<Map<String, dynamic>>> itensPorSecao = {};
  int totalGeral = 0;
  String pesquisa = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados([String pesquisa = '']) async {
    final lista = await DbService.getItensPorLoja(pesquisa: pesquisa);

    final Map<String, List<Map<String, dynamic>>> agrupado = {};
    int somaTotal = 0;

    for (var item in lista) {
      final secao = item['secao'] ?? 'Sem seção';

      if (!agrupado.containsKey(secao)) {
        agrupado[secao] = [];
      }

      agrupado[secao]!.add(item);

      somaTotal += (item['quantidade'] as int);
    }

    setState(() {
      itensPorSecao = agrupado;
      totalGeral = somaTotal;
    });
  }

  Future<void> deletarItem(String codigo, String chave) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar exclusão"),
          content: Text("Remover 1 unidade do código $codigo?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Excluir", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await DbService.removerItemPorChave(chave);
      await carregarDados();
    }
  }

  Future<void> deletarSecao(String secao, List<Map<String, dynamic>> itens) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar exclusão da seção"),
          content: Text(
            "Deseja apagar todos os ${itens.length} itens da Seção $secao?\n\n"
            "Esta ação não pode ser desfeita.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Apagar Seção"),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      for (var item in itens) {
        await DbService.removerItemPorChave(item['chave']);
      }
      await carregarDados();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${AppState.nome} - Inventário")),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Pesquisar por código ou descrição',
                border: const OutlineInputBorder(),
                suffixIcon: pesquisa.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            pesquisa = '';
                            _searchController.clear();
                          });
                          carregarDados();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  pesquisa = value;
                });
                carregarDados(value);
              },
            ),
          ),
          const SizedBox(height: 10),
          Builder(
            builder: (context) {
              final itensFiltrados = itensPorSecao;
              final totalExibido = itensFiltrados.values.fold<int>(
                0,
                (soma, itens) =>
                    soma +
                    itens.fold<int>(
                      0,
                      (somaItem, item) =>
                          somaItem + (item['quantidade'] as int),
                    ),
              );

              return Text(
                pesquisa.isEmpty
                    ? "Total de itens: $totalGeral"
                    : "Itens encontrados: $totalExibido",
                style: const TextStyle(fontSize: 18),
              );
            },
          ),
          const SizedBox(height: 10),

          Expanded(
            child: Builder(
              builder: (context) {
                final itensFiltrados = itensPorSecao;
                if (itensFiltrados.isEmpty) {
                  return const Center(child: Text('Nenhum item encontrado.'));
                }

                return ListView(
                  children: itensFiltrados.entries.map((entry) {
                    final secao = entry.key;
                    final itens = entry.value;

                    final totalSecao = itens.fold<int>(
                      0,
                      (soma, item) => soma + (item['quantidade'] as int),
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER DA SEÇÃO
                        Container(
                          width: double.infinity,
                          color: Colors.grey[300],
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Seção $secao: $totalSecao itens",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_sweep,
                                  color: Colors.red,
                                ),
                                tooltip: 'Apagar seção inteira',
                                onPressed: () => deletarSecao(secao, itens),
                              ),
                            ],
                          ),
                        ),

                        // ITENS
                        ...itens.map((item) {
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  "${item['codigo']} - ${item['descr'] ?? 'Sem descrição'}",
                                ),
                                subtitle: Text(
                                  "Quantidade: ${item['quantidade']}",
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => deletarItem(item['codigo'], item['chave']),
                                ),
                              ),

                              // DIVISÓRIA ENTRE ITENS
                              const Divider(
                                height: 1,
                                thickness: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                            ],
                          );
                        }),

                        // DIVISÓRIA ENTRE SEÇÕES
                        const Divider(thickness: 3, height: 20),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
