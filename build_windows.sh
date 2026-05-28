#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# GadoLeite ERP — Build Windows (executável + instalador)
# Desenvolvido por IAmina Software
# ═══════════════════════════════════════════════════════════════
set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${GREEN}🖥️  GadoLeite ERP — Build Windows${NC}"
echo ""

command -v flutter &>/dev/null || { echo -e "${RED}❌ Flutter não encontrado${NC}"; exit 1; }

OUTPUT_DIR="build/outputs/windows"
mkdir -p "$OUTPUT_DIR"
NOW=$(date +"%Y%m%d_%H%M")

echo -e "${YELLOW}📦 Instalando dependências...${NC}"
flutter clean && flutter pub get

echo -e "${YELLOW}🏗️  Compilando para Windows (release)...${NC}"
flutter build windows --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=ENVIRONMENT=production

SRC="build/windows/x64/runner/Release"
echo -e "${GREEN}✅ Executável em: $SRC/gadoleite.exe${NC}"

# Compress to zip for distribution
echo -e "${YELLOW}📦 Comprimindo para distribuição...${NC}"
cd "$SRC" && zip -r "../../../../$OUTPUT_DIR/GadoLeite-ERP-v1.0.0-windows-$NOW.zip" . && cd -
echo -e "${GREEN}✅ ZIP: $OUTPUT_DIR/GadoLeite-ERP-v1.0.0-windows-$NOW.zip${NC}"

# Try MSIX
echo -e "${YELLOW}📦 Tentando gerar MSIX (instalador Windows)...${NC}"
flutter pub run msix:create 2>/dev/null && {
  find . -name "*.msix" -exec cp {} "$OUTPUT_DIR/GadoLeite-ERP-v1.0.0-$NOW.msix" \;
  echo -e "${GREEN}✅ MSIX gerado${NC}"
} || {
  echo -e "${YELLOW}ℹ️  MSIX não disponível. Gerando script Inno Setup...${NC}"
  # Generate Inno Setup script
  cat > "$OUTPUT_DIR/gadoleite_setup.iss" << 'ISS'
; GadoLeite ERP — Inno Setup Script
; Desenvolvido por IAmina Software
#define AppName "GadoLeite ERP"
#define AppVersion "1.0.0"
#define AppPublisher "IAmina Software"
#define AppURL "https://gadoleite.com.br"
#define AppExeName "gadoleite.exe"

[Setup]
AppId={{B4E7C2A1-9D3F-4E6B-A2C5-1F8D3E5B7A9C}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}/suporte
AppUpdatesURL={#AppURL}/atualizacoes
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
OutputDir=.
OutputBaseFilename=GadoLeite-ERP-Setup-v{#AppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
MinVersion=10.0.17763
ArchitecturesInstallIn64BitMode=x64
WizardSmallImageFile=

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar ícone na {cm:DesktopName}"; GroupDescription: "Ícones adicionais:"; Flags: unchecked
Name: "quicklaunchicon"; Description: "Criar ícone na Barra de Tarefas"; GroupDescription: "Ícones adicionais:"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{group}\Desinstalar {#AppName}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "Abrir {#AppName} agora"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;
ISS
  echo -e "${GREEN}✅ Script Inno Setup: $OUTPUT_DIR/gadoleite_setup.iss${NC}"
  echo "   Para gerar .exe: Instale Inno Setup e abra o arquivo .iss"
  echo "   Download: https://jrsoftware.org/isdl.php"
}

echo ""
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ Build Windows concluído!${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"
ls -lh "$OUTPUT_DIR/"
