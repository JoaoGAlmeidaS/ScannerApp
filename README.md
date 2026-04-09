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

- Flutter SDK 3.11.3 ou superior
- Dart SDK 3.11.3 ou superior
- Android SDK (para desenvolvimento Android)

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/scanner_app.git
cd scanner_app
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Execute o app**
```bash
flutter run
```

### Build para Produção

**Android:**
```bash
flutter build apk --release
```

**Windows:**
```bash
flutter build windows --release
```

**Linux:**
```bash
flutter build linux --release
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
    └── DBdados.db3        # Banco de dados SQLite
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

### Android
- Câmera (`android.permission.CAMERA`)
- Acesso ao armazenamento


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


**Versão:** 1.0.0  
**Data de Atualização:** Abril de 2026
