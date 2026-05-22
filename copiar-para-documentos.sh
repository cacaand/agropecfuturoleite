#!/bin/bash
# Script para copiar o AgropecFuturo para a pasta Documentos
APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEST="$HOME/Documentos/AgropecFuturoLeite"

# Detecta se é "Documentos" ou "Documents"
if [ -d "$HOME/Documents" ] && [ ! -d "$HOME/Documentos" ]; then
  DEST="$HOME/Documents/AgropecFuturoLeite"
fi

echo "Copiando AgropecFuturo Leite para: $DEST"
mkdir -p "$DEST"

# Copia tudo exceto node_modules (é pesado demais)
rsync -av --exclude='node_modules' --exclude='.git' --exclude='dist' "$APP_DIR/" "$DEST/"

# Instala dependências na pasta de destino
echo ""
echo "Instalando dependências na pasta de destino..."
cd "$DEST" && npm install

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║  Cópia concluída com sucesso!                ║"
echo "║  Local: $DEST"
echo "║  Para rodar: cd $DEST && ./iniciar-agropecfuturo.sh"
echo "╚═══════════════════════════════════════════════╝"
