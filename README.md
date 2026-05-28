# 🐄 GadoLeite ERP
### Sistema Enterprise de Gestão Pecuária para Gado Leiteiro
**Desenvolvido por IAmina**

---

## 📦 Um único programa — Três plataformas

| Plataforma | Comando | Saída |
|-----------|---------|-------|
| 🌐 Web | `flutter run -d chrome` | Roda no navegador |
| 🖥️ Windows | `flutter run -d windows` | App desktop nativo |
| 📱 Android | `flutter run -d android` | App no celular |
| 📦 APK | `flutter build apk --release` | `app-release.apk` |
| 📦 EXE | `flutter build windows --release` | `.exe` instalável |
| 📦 Web | `flutter build web --release` | Pasta `build/web/` |

---

## 🚀 Como rodar (passo a passo)

### 1. Instalar o Flutter SDK
```bash
# Acesse: https://docs.flutter.dev/get-started/install
# Versão mínima: Flutter 3.19.0
flutter --version
```

### 2. Clonar e instalar dependências
```bash
cd gadoleite
flutter pub get
```

### 3. Gerar o código do banco de dados (obrigatório uma vez)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Rodar em qualquer plataforma
```bash
# Web
flutter run -d chrome

# Windows Desktop
flutter run -d windows

# Android (conecte o celular ou abra emulador)
flutter run -d android

# Ou use o script interativo:
bash run.sh
```

---

## 🗃️ Banco de Dados

- **SQLite local** via Drift ORM
- **Sem internet necessária** para rodar
- Dados persistem entre sessões
- Schema criado automaticamente na primeira execução
- Dados de demonstração inseridos automaticamente

---

## 🏗️ Arquitetura do projeto

```
gadoleite/
├── lib/
│   ├── main.dart                    # Entrada do app
│   ├── core/
│   │   ├── theme.dart               # Design system (cores, tipografia)
│   │   └── router.dart              # Navegação go_router
│   ├── database/
│   │   ├── database.dart            # Schema Drift + queries
│   │   └── database.g.dart          # Gerado pelo build_runner
│   ├── features/
│   │   ├── dashboard/               # Dashboard principal
│   │   ├── animals/                 # Lista, ficha, formulário
│   │   ├── milk/                    # Produção leiteira
│   │   ├── reproduction/            # Reprodução
│   │   ├── health/                  # Sanidade e vacinas
│   │   ├── finance/                 # Financeiro
│   │   └── settings/                # Configurações
│   └── shared/
│       └── widgets/
│           ├── main_shell.dart      # Sidebar + navegação
│           └── widgets.dart         # Componentes reutilizáveis
├── android/                         # Configuração Android
├── windows/                         # Configuração Windows
├── web/                             # Configuração Web
├── pubspec.yaml                     # Dependências
└── run.sh                           # Script interativo
```

---

## 🧩 Módulos implementados

| Módulo | Status | Funcionalidades |
|--------|--------|----------------|
| 🐄 Animais | ✅ Completo | Cadastro, busca, filtros, ficha completa com abas |
| 🥛 Produção Leiteira | ✅ Completo | Registro de ordenha, gráfico 7 dias, totais |
| 💚 Reprodução | ✅ Completo | IA, IATF, monta natural, diagnósticos |
| 🏥 Sanidade | ✅ Completo | Eventos de saúde, vacinas, alertas de vencimento |
| 💰 Financeiro | ✅ Completo | Receitas, despesas, lucro mensal |
| ⚙️ Configurações | ✅ Completo | Fazenda, assinatura, planos, upgrade |
| 📊 Dashboard | ✅ Completo | KPIs, gráficos, alertas inteligentes |
| 🔔 Alertas | ✅ Completo | Vacinas vencidas, animais doentes, partos próximos |

---

## 📱 Características

- ✅ **Offline total** — funciona sem internet
- ✅ **SQLite local** — dados salvos no dispositivo
- ✅ **Dark/Light mode** — suporte nativo
- ✅ **Responsivo** — adapta para mobile e desktop
- ✅ **Sidebar recolhível** — mais espaço no desktop
- ✅ **Dados demo** — inseridos automaticamente na primeira execução
- ✅ **Bottom navigation** — navegação mobile intuitiva
- ✅ **Formulários validados** — campos obrigatórios e tipos corretos
- ✅ **Bottom sheets** — registro rápido sem sair da tela
- ✅ **Stream-based** — dados atualizados em tempo real na tela
- ✅ **Trial system** — aviso visual de trial ativo

---

## 🔧 Dependências principais

| Pacote | Uso |
|--------|-----|
| `drift` + `drift_flutter` | ORM SQLite local |
| `flutter_riverpod` | Gerenciamento de estado |
| `go_router` | Navegação declarativa |
| `fl_chart` | Gráficos interativos |
| `google_fonts` (Inter) | Tipografia premium |
| `intl` | Formatação de datas e moeda |

---

## 🐛 Solução de problemas

**Erro: `database.g.dart not found`**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Erro: `flutter command not found`**
```bash
export PATH="$PATH:/home/seu-usuario/flutter/bin"
```

**Android: dispositivo não detectado**
```bash
flutter devices      # lista dispositivos
adb devices          # verifica ADB
```

**Windows: permissão negada**
```bash
# Execute PowerShell como Administrador
flutter run -d windows
```

---

## 📄 Licença

Uso comercial e pessoal. Desenvolvido por **IAmina**.

---

*GadoLeite ERP v1.0 — O sistema que sua fazenda merece* 🐄
