import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  static String nome = '';
  static String loja = '';
  static String secao = '';
  static bool permitirCodigosNaoCadastrados = false;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    nome = prefs.getString('nome') ?? '';
    loja = prefs.getString('loja') ?? '';
    secao = prefs.getString('secao') ?? '';
    permitirCodigosNaoCadastrados = prefs.getBool('permitirCodigosNaoCadastrados') ?? false;
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome', nome);
    await prefs.setString('loja', loja);
    await prefs.setString('secao', secao);
    await prefs.setBool('permitirCodigosNaoCadastrados', permitirCodigosNaoCadastrados);
  }

  final agora = DateTime.now().toIso8601String();
  final uuid = const Uuid().v4();
}