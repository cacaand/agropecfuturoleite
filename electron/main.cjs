const { app, BrowserWindow } = require('electron');
const path = require('path');

function createWindow() {
  const win = new BrowserWindow({
    width: 1280,
    height: 800,
    title: 'AgropecFuturo Leite',
    // Oculta a barra de menus do topo para parecer um app nativo
    autoHideMenuBar: true,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      // O banco de dados (IndexedDB e LocalStorage) será salvo isoladamente
      // na pasta AppData/UserData do sistema operacional
    }
  });

  // Tenta carregar o servidor local (que estará rodando via Vite)
  const loadApp = () => {
    win.loadURL('http://localhost:3003').catch(() => {
      console.log("Servidor ainda iniciando, tentando novamente em 2 segundos...");
      setTimeout(loadApp, 2000);
    });
  };

  loadApp();
}

app.whenReady().then(() => {
  // Configura a pasta de dados persistentes para garantir que nunca seja apagada
  const userDataPath = app.getPath('userData');
  console.log('Pasta do Banco de Dados Físico:', userDataPath);
  
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
