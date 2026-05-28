# 📦 Como gerar os pacotes de instalação

**Desenvolvido por IAmina**

---

## 🤖 Android APK / Play Store (AAB)

### Requisitos
- Flutter SDK instalado
- Java JDK 17+
- Android Studio ou Android SDK

### Gerar APK (instalação direta)
```bash
bash build_android.sh
# Escolha opção 1
# APK em: build/app/outputs/flutter-apk/
```

### Gerar AAB (Google Play Store)
```bash
bash build_android.sh
# Escolha opção 2
# AAB em: build/app/outputs/bundle/release/
```

### Keystore (assinatura)
- Arquivo: `android/app/iamina-release.keystore`
- Alias: `iamina`
- Senha: `IAmina@2025#`
- **⚠️ GUARDE ESTE ARQUIVO — sem ele não dá para atualizar o app na Play Store!**

### Subir para Play Store
1. Acesse https://play.google.com/console
2. Crie novo app: "GadoLeite ERP"
3. Production → Create new release
4. Upload do arquivo `.aab`
5. Preencha descrição, screenshots, categoria (Empresas)
6. Envie para revisão (2-3 dias úteis)

---

## 🖥️ Windows Installer

### Requisitos (no Windows)
- Flutter SDK
- Visual Studio 2022 com "Desktop development with C++"

### Gerar executável
```bash
# No Windows (PowerShell):
flutter pub get
flutter build windows --release

# Executável em:
# build\windows\x64\runner\Release\gadoleite.exe
```

### Gerar instalador MSIX (recomendado)
```bash
flutter pub run msix:create
# Instalador em: build\windows\gadoleite.msix
```

### Gerar instalador EXE (via Inno Setup)
1. Instale Inno Setup: https://jrsoftware.org/isdl.php
2. Rode `bash build_windows.sh`
3. Abra o `.iss` gerado no Inno Setup
4. Compile → instalador `.exe` pronto

---

## 🌐 Web (PWA)

```bash
flutter build web --release
# Deploy a pasta build/web/ em qualquer servidor
```

---

## 📋 Checklist antes de publicar

- [ ] Testar APK num celular físico Android
- [ ] Testar instalador Windows em PC sem Flutter instalado
- [ ] Verificar se os dados de demo aparecem ao abrir
- [ ] Testar fluxo de assinatura (PIX + Cartão)
- [ ] Verificar PIN de segurança
- [ ] Testar geração de PDFs
- [ ] Confirmar que dados persistem após fechar o app

---

**Suporte: contato@iamina.com.br**
