# 📱 Scanner App

Um aplicativo Flutter para gerenciamento de inventário com leitura de códigos de barras em tempo real.

## 📋 Sobre o Projeto

O **Scanner App** é uma solução móvel para facilitar a leitura e gerenciamento de produtos em inventário. Com integração de câmera para captura de código de barras e armazenamento local em banco de dados SQLite, o app oferece uma experiência fluida e eficiente para operações de estoque.

## ✨ Funcionalidades

- ✅ **Autenticação por Usuário** - Sistema de login e configurações de usuário
- 📸 **Leitura de Código de Barras** - Captura de códigos via câmera em tempo real
- 🏪 **Gestão de Lojas e Seções** - Organização de produtos por loja e seção
- 💾 **Armazenamento Local** - Banco de dados SQLite integrado
- 📤 **Compartilhamento** - Exportar e compartilhar dados de inventário
- ⚙️ **Configurações Personalizáveis** - Permite códigos não cadastrados e outras opções
- 🎯 **Interface Intuitiva** - Design limpo e fácil de usar

## 🛠️ Tecnologias

- **Flutter** 3.11.3+
- **Dart** 3.11.3+
- **SQLite** (via `sqflite` 2.4.2)
- **Mobile Scanner** 3.5.5 - Leitura de código de barras
- **Shared Preferences** 2.3.2 - Armazenamento de preferências
- **UUID** 4.5.3 - Geração de IDs únicos
- **Share Plus** 12.0.1 - Compartilhamento de arquivos

## 📦 Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  mobile_scanner: ^3.5.5
  sqflite: ^2.4.2
  path_provider: ^2.1.5
  uuid: ^4.5.3
  share_plus: ^12.0.1
  shared_preferences: ^2.3.2
```

## 🚀 Como Começar

### Pré-requisitos

- **Flutter SDK** 3.11.3 ou superior
- **Dart SDK** 3.11.3 ou superior
- **Android SDK** com API Level 21+
- **Android Studio** ou emulador/dispositivo Android
- **Git** para clonar o repositório

### Configuração do Android Studio

Após instalar o Android Studio, você precisará instalar alguns componentes adicionais:

**1. Abra o Android Studio**

**2. Vá em: `File` → `Settings` → `Languages & Frameworks` → `Android SDK`**

**3. Na aba "SDK Platforms", baixe:**
- ✅ Android 16.0

**4. Na aba "SDK Tools", certifique-se de ter instalado:**
- ✅ Android SDK Build-Tools
- ✅ Android Emulator
- ✅ Android SDK Platform-Tools
- ✅ Android SDK Command-line Tools
- ✅ NDK (Side by side)
- ✅ CMake

**5. Instale os plugins do Flutter:**
- Vá em `File` → `Settings` → `Plugins`
- Busque por "Flutter" e instale o plugin oficial
- O plugin do Dart será instalado automaticamente

**6. Configure variáveis de ambiente (Windows):**
```bash
# Adicione ao seu PATH as pastas:
C:\Users\SeuUsuário\AppData\Local\Android\sdk\platform-tools
C:\Users\SeuUsuário\AppData\Local\Android\sdk\tools
```

### Instalação Passo a Passo

**1. Clone o repositório**
```bash
git clone https://github.com/JoaoGAlmeidaS/ScannerApp.git
cd scanner_app
```

**2. Instale as dependências do Flutter**
```bash
flutter pub get
```

**3. Verifique se tudo está configurado corretamente**
```bash
flutter doctor
```
Certifique-se de que Android e Flutter estão com ✓.

**4. Conecte um dispositivo Android ou abra um emulador**

Para listar dispositivos disponíveis:
```bash
flutter devices
```

**5. Execute o aplicativo**
```bash
flutter run
```

Ou especifique um dispositivo:
```bash
flutter run -d <device_id>
```

### Build para Produção (APK Release)

Gere um APK otimizado para distribuição:
```bash
flutter build apk --release
```

O arquivo APK será criado em:
```
build/app/outputs/flutter-apk/app-release.apk
```

Para instalar em um dispositivo:
```bash
flutter install --release
```

## 📱 Estrutura do Projeto

```
lib/
├── main.dart              # Ponto de entrada do aplicativo
├── app_state.dart         # Gerenciamento de estado global
├── database_helper.dart   # Helper para operações com banco de dados
├── db_service.dart        # Serviço de banco de dados
└── pages/
    ├── login_page.dart         # Tela de login
    ├── config_page.dart        # Tela de configurações
    ├── menu_page.dart          # Menu principal
    ├── scanner_page.dart       # Tela do scanner
    ├── leitura_page.dart       # Tela de leitura
    ├── inventario_page.dart    # Tela de inventário
    ├── loja_page.dart          # Seleção de loja
    ├── secao_page.dart         # Seleção de seção
    └── result_page.dart        # Tela de resultados

assets/
└── database/
    └── DBdados.db3        # Banco de dados (criado em runtime)
```

## 💻 Fluxo de Uso

1. **Iniciação** - Usuário realiza login com seu nome/ID
2. **Configuração** - Seleciona a loja e seção de trabalho
3. **Menu Principal** - Acessa funcionalidades principais
4. **Scanner** - Abre câmera para ler códigos de barras
5. **Leitura** - Registra produtos lidos no banco de dados
6. **Inventário** - Visualiza todos os itens capturados
7. **Compartilhamento** - Exporta dados quando necessário

## 🔐 Permissões Necessárias

O aplicativo requer as seguintes permissões do Android:

- **CAMERA** - Para leitura de código de barras
- **READ_EXTERNAL_STORAGE** - Para acessar arquivos do dispositivo
- **WRITE_EXTERNAL_STORAGE** - Para salvar dados exportados

Essas permissões são automaticamente solicitadas ao usuário na primeira execução.


## 📝 Uso

### Adicionar um Novo Produto
O scanner captura automaticamente códigos de barras e registra no banco de dados.

### Consultar Inventário
Navegue para a aba "Inventário" para ver todos os produtos capturados.

### Exportar Dados
Use a opção "Compartilhar" para exportar os dados em formato compatível.

## 🐛 Resolvendo Problemas

### Câmera não funciona
- Verifique se as permissões de câmera foram concedidas
- Reinicie o app
- Verifique se o dispositivo possui câmera

### App travando
- Limpe o cache: `flutter clean`
- Reinstale as dependências: `flutter pub get`
- Reconstrua o projeto: `flutter run`

### Banco de dados não encontrado
- Verifique se o arquivo `DBdados.db3` está na pasta `assets/database/`
- Execute `flutter pub get` para recarregar os assets

## 📊 Configurações AppState

O app mantém as seguintes configurações em memória:
- `nome` - Nome do usuário logado
- `loja` - Loja selecionada
- `secao` - Seção selecionada
- `permitirCodigosNaoCadastrados` - Permite leitura de códigos não cadastrados


**Versão:** 0.1.2  
**Data de Atualização:** Maio de 2026
