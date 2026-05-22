#!/bin/bash
# Script para criar o pacote de instalação Windows do AgropecFuturo Leite
APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTPUT="$APP_DIR/AgropecFuturoLeite-Windows.zip"

echo "╔════════════════════════════════════════════════╗"
echo "║   Criando pacote de instalação para Windows   ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Remove ZIP antigo se existir
rm -f "$OUTPUT"

# Cria o ZIP excluindo arquivos desnecessários
cd "$APP_DIR"
zip -r "$OUTPUT" \
  src/ \
  server/ \
  public/ \
  electron/ \
  index.html \
  package.json \
  package-lock.json \
  tsconfig.json \
  vite.config.ts \
  components.json \
  iniciar-agropecfuturo.bat \
  iniciar-agropecfuturo.sh \
  copiar-para-documentos.sh \
  README.md \
  -x "*.git*" "node_modules/*" "dist/*" "*.zip"

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║  Pacote Windows criado com sucesso!           ║"
echo "║  Arquivo: AgropecFuturoLeite-Windows.zip      ║"
echo "║                                               ║"
echo "║  INSTRUÇÕES PARA O WINDOWS:                   ║"
echo "║  1. Copie o .zip para o PC Windows            ║"
echo "║  2. Extraia a pasta                           ║"
echo "║  3. Instale o Node.js (nodejs.org)            ║"
echo "║  4. Abra a pasta e dê dois cliques em:        ║"
echo "║     iniciar-agropecfuturo.bat                 ║"
echo "╚════════════════════════════════════════════════╝"
