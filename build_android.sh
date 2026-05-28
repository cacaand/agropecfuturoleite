#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════
# GadoLeite ERP — Build Android APK + AAB Play Store
# Assinado por: IAmina Software
# ═══════════════════════════════════════════════════════════════════════
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'

echo -e "${GREEN}"
echo "  ██████╗  █████╗ ██████╗  ██████╗     ██╗     ███████╗██╗████████╗███████╗"
echo "  ██╔════╝ ██╔══██╗██╔══██╗██╔═══██╗    ██║     ██╔════╝██║╚══██╔══╝██╔════╝"
echo "  ██║  ███╗███████║██║  ██║██║   ██║    ██║     █████╗  ██║   ██║   █████╗"
echo "  ██║   ██║██╔══██║██║  ██║██║   ██║    ██║     ██╔══╝  ██║   ██║   ██╔══╝"
echo "  ╚██████╔╝██║  ██║██████╔╝╚██████╔╝    ███████╗███████╗██║   ██║   ███████╗"
echo "   ╚═════╝ ╚═╝  ╚═╝╚═════╝  ╚═════╝    ╚══════╝╚══════╝╚═╝   ╚═╝   ╚══════╝"
echo -e "${NC}"
echo -e "${BLUE}  Build Android — Assinado por IAmina Software${NC}"
echo ""

# ── Verificações ────────────────────────────────────────────────────────────────
check_tool() { command -v "$1" &>/dev/null || { echo -e "${RED}❌ $1 não encontrado. Instale e tente novamente.${NC}"; exit 1; }; }
check_tool flutter
check_tool java

echo -e "${GREEN}✅ Flutter: $(flutter --version 2>/dev/null | head -1)${NC}"
echo -e "${GREEN}✅ Java: $(java -version 2>&1 | head -1)${NC}"
echo ""

# ── Keystore ────────────────────────────────────────────────────────────────────
KEYSTORE="android/app/iamina-release.keystore"
if [ ! -f "$KEYSTORE" ]; then
  echo -e "${YELLOW}🔑 Gerando keystore IAmina...${NC}"
  keytool -genkey -v \
    -keystore "$KEYSTORE" \
    -alias iamina \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass "IAmina@2025#" \
    -keypass  "IAmina@2025#" \
    -dname "CN=IAmina Software, OU=Mobile, O=IAmina, L=Goiania, S=GO, C=BR"
  echo -e "${GREEN}✅ Keystore gerado${NC}"
else
  echo -e "${GREEN}✅ Keystore IAmina encontrado${NC}"
fi

# ── Dependências ────────────────────────────────────────────────────────────────
echo -e "${YELLOW}📦 Instalando dependências...${NC}"
flutter clean && flutter pub get

# ── Opção de build ─────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}══════════════════════════════════════════${NC}"
echo "  Selecione o tipo de build:"
echo "  1) APK Universal  — um único arquivo, instala em qualquer Android"
echo "  2) APK por ABI    — arquivos menores, separados por arquitetura"
echo "  3) AAB Play Store — formato para publicar na Google Play"
echo "  4) TUDO           — gera APK Universal + APK por ABI + AAB"
echo -e "${BLUE}══════════════════════════════════════════${NC}"
read -p "  Opção [1-4]: " OPT

OUTPUT_DIR="build/outputs/android"
mkdir -p "$OUTPUT_DIR"
NOW=$(date +"%Y%m%d_%H%M")

build_apk_universal() {
  echo -e "${YELLOW}📱 Gerando APK Universal...${NC}"
  flutter build apk --release \
    --obfuscate \
    --split-debug-info=build/debug-info \
    --dart-define=ENVIRONMENT=production
  cp build/app/outputs/flutter-apk/app-release.apk \
     "$OUTPUT_DIR/GadoLeite-ERP-v1.0.0-universal-$NOW.apk"
  echo -e "${GREEN}✅ APK Universal: $OUTPUT_DIR/GadoLeite-ERP-v1.0.0-universal-$NOW.apk${NC}"
  echo -e "${GREEN}   Tamanho: $(du -sh "$OUTPUT_DIR/GadoLeite-ERP-v1.0.0-universal-$NOW.apk" | cut -f1)${NC}"
}

build_apk_split() {
  echo -e "${YELLOW}📱 Gerando APKs por ABI...${NC}"
  flutter build apk --release \
    --obfuscate \
    --split-debug-info=build/debug-info \
    --split-per-abi \
    --dart-define=ENVIRONMENT=production
  for f in build/app/outputs/flutter-apk/app-*-release.apk; do
    ARCH=$(basename "$f" | sed 's/app-\(.*\)-release.apk/\1/')
    cp "$f" "$OUTPUT_DIR/GadoLeite-ERP-v1.0.0-$ARCH-$NOW.apk"
    echo -e "${GREEN}   ✅ APK $ARCH: $(du -sh "$OUTPUT_DIR/GadoLeite-ERP-v1.0.0-$ARCH-$NOW.apk" | cut -f1)${NC}"
  done
}

build_aab() {
  echo -e "${YELLOW}🏪 Gerando AAB para Play Store...${NC}"
  flutter build appbundle --release \
    --obfuscate \
    --split-debug-info=build/debug-info \
    --dart-define=ENVIRONMENT=production
  cp build/app/outputs/bundle/release/app-release.aab \
     "$OUTPUT_DIR/GadoLeite-ERP-v1.0.0-playstore-$NOW.aab"
  echo -e "${GREEN}✅ AAB Play Store: $OUTPUT_DIR/GadoLeite-ERP-v1.0.0-playstore-$NOW.aab${NC}"
  echo -e "${GREEN}   Tamanho: $(du -sh "$OUTPUT_DIR/GadoLeite-ERP-v1.0.0-playstore-$NOW.aab" | cut -f1)${NC}"
}

case $OPT in
  1) build_apk_universal ;;
  2) build_apk_split ;;
  3) build_aab ;;
  4) build_apk_universal; build_apk_split; build_aab ;;
  *) echo -e "${RED}Opção inválida${NC}"; exit 1 ;;
esac

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ BUILD CONCLUÍDO COM SUCESSO!${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}  📁 Arquivos gerados em: $OUTPUT_DIR/${NC}"
ls -lh "$OUTPUT_DIR/" 2>/dev/null
echo ""
echo -e "${YELLOW}  🔑 KEYSTORE — GUARDE COM SEGURANÇA:${NC}"
echo "     Arquivo: android/app/iamina-release.keystore"
echo "     Alias:   iamina"
echo "     Senha:   IAmina@2025#"
echo ""
echo -e "${YELLOW}  📋 PUBLICAR NA PLAY STORE:${NC}"
echo "     1. Acesse: https://play.google.com/console"
echo "     2. Crie app: 'GadoLeite ERP' — categoria: Empresas"
echo "     3. Production → Create release → Upload .aab"
echo "     4. Screenshots mínimos: 2 celular + 1 tablet"
echo "     5. Revisão: 2-7 dias úteis"
echo ""
echo -e "${YELLOW}  📲 INSTALAR APK DIRETAMENTE (sideload):${NC}"
echo "     Android: Configurações → Segurança → Fontes desconhecidas → ON"
echo "     Envie o .apk para o celular (WhatsApp, email, cabo USB)"
echo "     Toque no arquivo .apk para instalar"
