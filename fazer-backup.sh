#!/bin/bash
# Script de Backup de Segurança
APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$APP_DIR/backup-seguro-$(date +%Y%m%d_%H%M%S)"
echo "Criando backup em: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cp -r "$APP_DIR/src" "$BACKUP_DIR/"
cp -r "$APP_DIR/server" "$BACKUP_DIR/"
cp "$APP_DIR/package.json" "$BACKUP_DIR/"
cp "$APP_DIR/iniciar-agropecfuturo.sh" "$BACKUP_DIR/"
cp "$APP_DIR/vite.config.ts" "$BACKUP_DIR/"
cp "$APP_DIR/index.html" "$BACKUP_DIR/"
echo "Backup concluído com sucesso!"
