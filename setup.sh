#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# GadoLeite ERP — Instalação e execução rápida
# ═══════════════════════════════════════════════════════════════
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${GREEN}🐄 GadoLeite ERP — Setup${NC}"
echo ""

command -v flutter &>/dev/null || { echo -e "${RED}❌ Instale o Flutter SDK primeiro: https://flutter.dev/docs/get-started/install${NC}"; exit 1; }

echo -e "${YELLOW}1/3 Instalando dependências...${NC}"
flutter pub get

echo -e "${YELLOW}2/3 Configurando ambiente...${NC}"
# Remove any old drift generated files if they exist
find . -name "*.g.dart" -delete 2>/dev/null || true
find . -name "*.freezed.dart" -delete 2>/dev/null || true

echo -e "${YELLOW}3/3 Pronto! Escolha a plataforma:${NC}"
echo ""
echo "  1) 🌐  Web (Chrome)"
echo "  2) 🖥️  Windows"
echo "  3) 📱  Android"
echo "  4) 📦  Build APK para instalação direta"
echo "  5) 📦  Build Play Store (AAB)"
echo "  6) 📦  Build Windows Installer"
read -p "  Opção: " opt

case $opt in
  1) flutter run -d chrome ;;
  2) flutter run -d windows ;;
  3) flutter run -d android ;;
  4) bash build_android.sh ;;
  5) bash build_android.sh ;;
  6) bash build_windows.sh ;;
  *) echo "Opção inválida" ;;
esac
