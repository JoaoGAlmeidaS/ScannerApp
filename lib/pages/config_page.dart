import 'package:flutter/material.dart';
import '../app_state.dart';
import '../db_service.dart';
import 'login_page.dart';
import 'loja_page.dart';
import 'menu_page.dart';

class ConfigPage extends StatefulWidget {
  final bool requirePassword;

  const ConfigPage({super.key, this.requirePassword = false});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  bool _unlocking = false;
  String? _senhaAtual;

  @override
  void initState() {
    super.initState();
    _loadSenha();
    if (widget.requirePassword) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verificarSenha();
      });
    }
  }

  Future<void> _loadSenha() async {
    final senha = await DbService.getConfigSenha();
    setState(() {
      _senhaAtual = senha;
    });
  }
  void _atualizarEstado() {
    setState(() {});
  }

  bool get _podeContinuar =>
      AppState.nome.isNotEmpty && AppState.loja.isNotEmpty;

  Future<void> _verificarSenha() async {
    if (_unlocking) return;
    _unlocking = true;
    final localContext = context;

    final senha = await DbService.getConfigSenha();
    if (senha == null) {
      _unlocking = false;
      return;
    }

    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      // ignore: use_build_context_synchronously
      context: localContext,
      builder: (context) {
        return AlertDialog(
          title: const Text('Acesso a Configuração'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Informe a senha para acessar as configurações.'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      _unlocking = false;
      return;
    }

    if (ok != true || controller.text != senha) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Acesso negado'),
              content: const Text('Senha incorreta.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        if (mounted) Navigator.pop(context);
      }
    }

    _unlocking = false;
  }

  Future<void> _alterarSenha() async {
    final controllerAtual = TextEditingController();
    final controllerNova = TextEditingController();
    final controllerConfirm = TextEditingController();

    final temSenha = _senhaAtual != null;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(temSenha ? 'Alterar senha' : 'Criar senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (temSenha) ...[
                TextField(
                  controller: controllerAtual,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha atual',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: controllerNova,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nova senha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controllerConfirm,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar senha',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      if (controllerNova.text.isEmpty || controllerConfirm.text.isEmpty) {
        await _showMensagem('Preencha a nova senha e a confirmação.');
        return;
      }
      if (controllerNova.text != controllerConfirm.text) {
        await _showMensagem('As senhas não conferem.');
        return;
      }
      if (temSenha && controllerAtual.text != _senhaAtual) {
        await _showMensagem('Senha atual incorreta.');
        return;
      }

      await DbService.salvarConfigSenha(controllerNova.text);
      await _loadSenha();
      await _showMensagem('Senha salva com sucesso.');
    }
  }

  Future<void> _showMensagem(String mensagem) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Defina seu usuário e loja para continuar.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Nome do usuário'),
              subtitle: Text(AppState.nome.isNotEmpty
                  ? AppState.nome
                  : 'Ainda não definido'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
                _atualizarEstado();
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Loja'),
              subtitle: Text(AppState.loja.isNotEmpty
                  ? AppState.loja
                  : 'Ainda não definida'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LojaPage()),
                );
                _atualizarEstado();
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Senha de configuração'),
              subtitle: Text(_senhaAtual != null
                  ? 'Definida'
                  : 'Ainda não definida'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _alterarSenha,
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Permitir códigos não cadastrados'),
              subtitle: const Text('Permite ler códigos que não estão no banco de produtos'),
              value: AppState.permitirCodigosNaoCadastrados,
              onChanged: (value) async {
                AppState.permitirCodigosNaoCadastrados = value;
                await AppState.save();
                _atualizarEstado();
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _podeContinuar
                  ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MenuPage()),
                      );
                    }
                  : null,
              child: const Text('Continuar para Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
