import 'package:flutter/material.dart';
import '../app_state.dart';
import 'config_page.dart';
import 'secao_page.dart';
import 'inventario_page.dart';
import 'leitura_page.dart';
import '../db_service.dart';

class MenuPage extends StatefulWidget  {
  const MenuPage({super.key});

  
  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Menu - V0.1.2'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuração',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ConfigPage(requirePassword: true),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha((0.12 * 255).round()),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, ${AppState.nome.isEmpty ? 'Usuário' : AppState.nome}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.store, size: 18),
                        label: Text(AppState.loja.isEmpty ? 'Loja não definida' : AppState.loja),
                      ),
                      Chip(
                        avatar: const Icon(Icons.location_on, size: 18),
                        label: Text(AppState.secao.isEmpty ? 'Seção não definida' : 'Seção ${AppState.secao}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Selecione uma ação para continuar.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuCard(
                    context,
                    icon: Icons.explore,
                    title: 'Seção',
                    subtitle: 'Selecione ou altere sua seção atual',
                    color: Colors.blue,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SecaoPage()),
                      );
                      setState(() {});
                    },
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.qr_code_2,
                    title: 'Ler Código',
                    subtitle: 'Leia códigos e registre a leitura',
                    color: Colors.deepPurple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LeituraPage()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.inventory_2,
                    title: 'Inventário',
                    subtitle: 'Visualize e pesquise seu estoque',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InventarioPage()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.upload_file,
                    title: 'Exportar',
                    subtitle: 'Exportar o banco de dados local',
                    color: Colors.orange,
                    onTap: () async {
                      await DbService.exportarBanco();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withAlpha((0.16 * 255).round()),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      ),
    );
  }
}
