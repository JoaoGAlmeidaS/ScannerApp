# 📱 Scanner App

Aplicativo Flutter para gerenciamento de inventário com leitura de códigos de barras em tempo real.

## 📋 Sobre o Projeto

O **Scanner App** facilita a leitura e o gerenciamento de produtos em inventário. Ele usa a câmera do dispositivo para capturar códigos de barras e armazena os dados localmente em SQLite, oferecendo uma experiência rápida para operações de estoque.

## ✨ Funcionalidades

- ✅ **Identificação do usuário** – login simples e configurações por usuário
- 📸 **Leitura de código de barras** – captura via câmera em tempo real
- 🏪 **Lojas e seções** – organização dos produtos por loja e seção
- 💾 **Armazenamento local** – banco de dados SQLite no próprio dispositivo
- 📤 **Exportação** – compartilhamento dos dados do inventário
- ⚙️ **Configurações** – opção de aceitar códigos não cadastrados, entre outras

## 🛠️ Tecnologias

| Pacote | Uso |
|---|---|
| [Flutter](https://flutter.dev) (Dart 3.11.3+) | Framework |
| `mobile_scanner` | Leitura de código de barras |
| `sqflite` / `path_provider` | Banco de dados local |
| `shared_preferences` | Preferências do usuário |
| `uuid` | Geração de IDs únicos |
| `share_plus` | Compartilhamento de arquivos |

As versões exatas estão no [`pubspec.yaml`](pubspec.yaml).

## 🚀 Como Começar

### Pré-requisitos

- Flutter SDK (canal stable) com Dart 3.11.3 ou superior
- Android SDK (API 21+) e um dispositivo ou emulador Android
- Git

Para instalar e configurar o Flutter e o Android Studio, siga a [documentação oficial](https://docs.flutter.dev/get-started/install).

### Instalação

```bash
git clone https://github.com/JoaoGAlmeidaS/ScannerApp.git
cd ScannerApp
flutter pub get
flutter doctor        # confira se Flutter e Android estão OK
flutter devices       # lista os dispositivos disponíveis
flutter run           # ou: flutter run -d <device_id>
```

### Build de produção

```bash
flutter build apk --release
```

O APK será gerado em `build/app/outputs/flutter-apk/app-release.apk`.

## 📁 Estrutura do Projeto

```
lib/
├── main.dart              # Ponto de entrada
├── app_state.dart         # Estado global
├── database_helper.dart   # Acesso ao banco de dados
├── db_service.dart        # Serviço de banco de dados
└── pages/
    ├── login_page.dart
    ├── config_page.dart
    ├── menu_page.dart
    ├── scanner_page.dart
    ├── leitura_page.dart
    ├── inventario_page.dart
    ├── loja_page.dart
    ├── secao_page.dart
    └── result_page.dart
```

## 💻 Fluxo de Uso

1. **Login** – o usuário se identifica
2. **Configuração** – seleciona a loja e a seção de trabalho
3. **Scanner** – lê os códigos de barras pela câmera
4. **Inventário** – visualiza os itens registrados
5. **Exportação** – compartilha os dados quando necessário

## 🔐 Permissões

- **Câmera** – necessária para a leitura dos códigos de barras. A permissão é solicitada ao abrir o scanner.

## 🐛 Solução de Problemas

**Câmera não funciona**
- Verifique se a permissão de câmera foi concedida nas configurações do Android
- Reinicie o app

**Erros de build ou app travando**
```bash
flutter clean
flutter pub get
flutter run
```

---

**Versão:** 0.1.2
