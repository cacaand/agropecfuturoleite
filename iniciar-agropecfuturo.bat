@echo off
title AgropecFuturo Leite - Servidor Desktop
color 0A

echo ================================================
echo    AgropecFuturo Leite - Iniciando...
echo    Banco de Dados: Arquivo Fisico no Disco
echo ================================================
echo.

REM Verifica se o Node.js esta instalado
where node >nul 2>&1
if errorlevel 1 (
    color 0C
    echo ERRO: Node.js nao esta instalado!
    echo.
    echo Por favor, baixe e instale o Node.js em:
    echo https://nodejs.org/
    echo.
    echo Escolha a versao LTS e instale normalmente.
    echo Depois, rode este arquivo novamente.
    echo.
    pause
    exit /b 1
)

REM Vai para a pasta do script
cd /d "%~dp0"

REM Verifica se node_modules existe
if not exist "node_modules" (
    echo [1/4] Instalando dependencias pela primeira vez...
    echo Isso pode levar alguns minutos...
    call npm install
    echo.
)

REM Inicia o servidor de dados
echo [2/4] Iniciando servidor de dados...
start /b node server\dados-server.cjs
timeout /t 2 /nobreak >nul

REM Inicia o servidor web
echo [3/4] Iniciando interface do programa...
start /b npx vite --port=3003 --host=0.0.0.0

REM Aguarda o servidor ficar pronto
echo [4/4] Aguardando programa ficar pronto...
:WAIT_LOOP
timeout /t 1 /nobreak >nul
curl -s http://localhost:3003 >nul 2>&1
if errorlevel 1 (
    echo   Aguardando...
    goto WAIT_LOOP
)

echo.
echo ==================================================
echo   PRONTO! Abrindo o programa no navegador...
echo   Seus dados sao salvos no arquivo:
echo   %~dp0dados_agropecfuturo.json
echo.
echo   NAO FECHE ESTA JANELA DO TERMINAL!
echo   Feche apenas o navegador quando terminar.
echo ==================================================
echo.

REM Abre o navegador
start http://localhost:3003

REM Mantém a janela aberta
echo Pressione qualquer tecla para ENCERRAR o programa...
pause >nul

REM Encerra os processos
taskkill /f /im node.exe >nul 2>&1
echo AgropecFuturo encerrado. Seus dados estao seguros no disco.
timeout /t 3 /nobreak >nul
