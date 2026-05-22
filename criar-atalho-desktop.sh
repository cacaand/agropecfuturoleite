#!/bin/bash
APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DESKTOP_DIR=$(xdg-user-dir DESKTOP 2>/dev/null)
if [ -z "$DESKTOP_DIR" ]; then
  DESKTOP_DIR="$HOME/Desktop"
fi

SHORTCUT_PATH="$DESKTOP_DIR/agropecfuturoleite.desktop"
ICON_SOURCE="/home/caca/.gemini/antigravity/brain/ff5509a2-029f-4e75-99ec-e5a147c7bab6/boi_icone_1777516637502.png"
ICON_DEST="$APP_DIR/public/icone_boi.png"

# Copia o ícone gerado pela IA para dentro do projeto
if [ -f "$ICON_SOURCE" ]; then
  cp "$ICON_SOURCE" "$ICON_DEST"
  echo "Ícone copiado para o projeto."
else
  # Se o caminho falhar, tenta achar qualquer png de boi_icone na pasta do brain
  find /home/caca/.gemini/antigravity/brain/ff5509a2-029f-4e75-99ec-e5a147c7bab6/ -name "boi_icone*.png" -exec cp {} "$ICON_DEST" \; -quit
fi

echo "[Desktop Entry]" > "$SHORTCUT_PATH"
echo "Version=1.0" >> "$SHORTCUT_PATH"
echo "Name=AgropecFuturo Leite" >> "$SHORTCUT_PATH"
echo "Comment=Sistema de Gestão Agropecuária" >> "$SHORTCUT_PATH"
echo "Exec=$APP_DIR/iniciar-agropecfuturo.sh" >> "$SHORTCUT_PATH"
echo "Icon=$ICON_DEST" >> "$SHORTCUT_PATH"
echo "Terminal=true" >> "$SHORTCUT_PATH"
echo "Type=Application" >> "$SHORTCUT_PATH"
echo "Categories=Office;" >> "$SHORTCUT_PATH"

chmod +x "$SHORTCUT_PATH"

# Permite execução confiável no Ubuntu
dbus-launch gio set "$SHORTCUT_PATH" metadata::trusted true 2>/dev/null || true

echo "=========================================================="
echo "Atalho criado na sua Área de Trabalho com a foto do boi!"
echo "Nome: agropecfuturoleite.desktop"
echo "Para abrir o programa, dê dois cliques nesse atalho."
echo "=========================================================="
