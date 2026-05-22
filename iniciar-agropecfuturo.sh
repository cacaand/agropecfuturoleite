#!/bin/bash
# Obtém o diretório onde o script está localizado
APP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PORT=3003

# Limpeza de arquivos de lixo que travam o sistema
rm -f "$APP_DIR/react" "$APP_DIR/{"

cd "$APP_DIR"

echo '╔════════════════════════════════════════════════╗'
echo '║   AgropecFuturo Leite - Modo Profissional     ║'
echo '║   Banco de Dados: Arquivo Físico no Disco     ║'
echo '╚════════════════════════════════════════════════╝'

# 1. Inicia o servidor de dados (salva no disco rígido)
echo '[1/3] Iniciando servidor de dados...'
node server/dados-server.cjs &
DATA_PID=$!
sleep 2

# 2. Inicia o servidor web (interface visual)
echo '[2/3] Iniciando interface do programa...'
npm run dev &
WEB_PID=$!

# 3. Aguarda o servidor web ficar pronto e abre o navegador
echo '[3/3] Aguardando programa ficar pronto...'
for i in $(seq 1 20); do
  sleep 1
  if curl -s http://localhost:$PORT > /dev/null 2>&1; then
    echo ''
    echo '══════════════════════════════════════════════════'
    echo '  PRONTO! Abrindo o programa no navegador...'
    echo '  Seus dados são salvos no arquivo:'
    echo "  $APP_DIR/dados_agropecfuturo.json"
    echo ''
    echo '  ⚠️  NÃO FECHE ESTA JANELA DO TERMINAL!'
    echo '  Feche apenas o navegador quando terminar.'
    echo '══════════════════════════════════════════════════'
    xdg-open http://localhost:$PORT
    break
  fi
  echo "  Aguardando... ($i/20)"
done

# Aguarda até o usuário fechar esta janela
wait $WEB_PID

# Quando o terminal for fechado, encerra os servidores
echo 'Encerrando servidores...'
kill $DATA_PID 2>/dev/null
kill $WEB_PID 2>/dev/null
echo 'AgropecFuturo encerrado. Seus dados estão seguros no disco.'
