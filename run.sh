#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# GadoLeite ERP — Script de instalação e execução
# Desenvolvido por IAmina
# ─────────────────────────────────────────────────────────────────────

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

echo -e "${GREEN}"
echo "  ██████╗  █████╗ ██████╗  ██████╗     ██╗     ███████╗██╗████████╗███████╗"
echo "  ██╔════╝ ██╔══██╗██╔══██╗██╔═══██╗    ██║     ██╔════╝██║╚══██╔══╝██╔════╝"
echo "  ██║  ███╗███████║██║  ██║██║   ██║    ██║     █████╗  ██║   ██║   █████╗  "
echo "  ██║   ██║██╔══██║██║  ██║██║   ██║    ██║     ██╔══╝  ██║   ██║   ██╔══╝  "
echo "  ╚██████╔╝██║  ██║██████╔╝╚██████╔╝    ███████╗███████╗██║   ██║   ███████╗"
echo "   ╚═════╝ ╚═╝  ╚═╝╚═════╝  ╚═════╝    ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝"
echo -e "${NC}"
echo -e "${BLUE}  ERP Gado Leiteiro — Enterprise SaaS | Desenvolvido por IAmina${NC}"
echo ""

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter não encontrado!${NC}"
    echo ""
    echo "Instale o Flutter SDK:"
    echo "  https://docs.flutter.dev/get-started/install"
    echo ""
    echo "Versão mínima requerida: Flutter 3.19.0"
    exit 1
fi

FLUTTER_VERSION=$(flutter --version 2>/dev/null | head -1)
echo -e "${GREEN}✅ Flutter encontrado: $FLUTTER_VERSION${NC}"

# Menu
echo ""
echo -e "${YELLOW}Selecione a plataforma:${NC}"
echo "  1) 🌐  Web (navegador)"
echo "  2) 🖥️  Windows (desktop)"
echo "  3) 📱  Android (dispositivo/emulador)"
echo "  4) 🔧  Gerar código (build_runner)"
echo "  5) 📦  Build APK (Android Release)"
echo "  6) 📦  Build Web (produção)"
echo "  7) 📦  Build Windows EXE"
echo "  0) Sair"
echo ""

read -p "Opção: " opt

case $opt in
  1)
    echo -e "${GREEN}🌐 Iniciando no Web...${NC}"
    flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs 2>/dev/null || true
    flutter run -d chrome --web-renderer html
    ;;
  2)
    echo -e "${GREEN}🖥️  Iniciando no Windows...${NC}"
    flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs 2>/dev/null || true
    flutter run -d windows
    ;;
  3)
    echo -e "${GREEN}📱 Iniciando no Android...${NC}"
    flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs 2>/dev/null || true
    flutter run -d android
    ;;
  4)
    echo -e "${GREEN}🔧 Gerando código Drift...${NC}"
    flutter pub get
    flutter pub run build_runner build --delete-conflicting-outputs
    echo -e "${GREEN}✅ Código gerado com sucesso!${NC}"
    ;;
  5)
    echo -e "${GREEN}📦 Gerando APK Android...${NC}"
    flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs 2>/dev/null || true
    flutter build apk --release
    echo -e "${GREEN}✅ APK gerado em: build/app/outputs/flutter-apk/app-release.apk${NC}"
    ;;
  6)
    echo -e "${GREEN}📦 Gerando build Web...${NC}"
    flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs 2>/dev/null || true
    flutter build web --release
    echo -e "${GREEN}✅ Web gerado em: build/web/${NC}"
    ;;
  7)
    echo -e "${GREEN}📦 Gerando EXE Windows...${NC}"
    flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs 2>/dev/null || true
    flutter build windows --release
    echo -e "${GREEN}✅ EXE gerado em: build/windows/x64/runner/Release/${NC}"
    ;;
  0) echo "Saindo..."; exit 0 ;;
  *) echo -e "${RED}Opção inválida${NC}" ;;
esac
