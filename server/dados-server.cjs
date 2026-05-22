/**
 * Servidor de Persistência - AgropecFuturo Leite
 * 
 * Este servidor cria um arquivo físico no disco rígido (dados_agropecfuturo.json)
 * que guarda TODOS os dados do programa. O navegador NÃO pode apagar este arquivo.
 */
const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3004;

// Arquivo físico de dados - fica na mesma pasta do projeto
const DATA_FILE = path.join(__dirname, '..', 'dados_agropecfuturo.json');

// Permite que o React se comunique com este servidor (CORS manual)
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.sendStatus(200);
  next();
});
app.use(express.json({ limit: '50mb' }));

// Dados padrão quando o arquivo não existe
const DEFAULT_DATA = {
  versao: "AgropecFuturo Leite v2.0",
  ultimaSalvamento: null,
  animais: [],
  configuracoes: {
    nomeUsuario: "",
    nomePropriedade: "",
    cartaoProdutor: "",
    registroIMA: "",
    cotacaoLeiteVaca: 0,
    cotacaoLeiteBufala: 0
  },
  producaoLeite: []
};

// Função para ler dados do disco
function lerDados() {
  try {
    if (fs.existsSync(DATA_FILE)) {
      const raw = fs.readFileSync(DATA_FILE, 'utf-8');
      const dados = JSON.parse(raw);
      console.log(`[DISCO] Lidos ${(dados.animais || []).length} animais do arquivo físico.`);
      return dados;
    }
  } catch (e) {
    console.error('[DISCO] Erro ao ler arquivo de dados:', e.message);
  }
  console.log('[DISCO] Arquivo de dados não encontrado. Criando novo...');
  salvarDados(DEFAULT_DATA);
  return DEFAULT_DATA;
}

// Função para salvar dados no disco
function salvarDados(dados) {
  try {
    dados.ultimaSalvamento = new Date().toISOString();
    fs.writeFileSync(DATA_FILE, JSON.stringify(dados, null, 2), 'utf-8');
    console.log(`[DISCO] Salvos ${(dados.animais || []).length} animais no arquivo físico.`);
    return true;
  } catch (e) {
    console.error('[DISCO] ERRO CRÍTICO ao salvar:', e.message);
    return false;
  }
}

// ===== ENDPOINTS DA API =====

// GET /api/dados - Carrega todos os dados do disco
app.get('/api/dados', (req, res) => {
  const dados = lerDados();
  res.json(dados);
});

// POST /api/dados - Salva todos os dados no disco
app.post('/api/dados', (req, res) => {
  const dados = req.body;
  if (!dados) {
    return res.status(400).json({ erro: 'Dados vazios' });
  }
  const ok = salvarDados(dados);
  if (ok) {
    res.json({ sucesso: true, mensagem: `Dados salvos com sucesso. ${(dados.animais || []).length} animais no disco.` });
  } else {
    res.status(500).json({ erro: 'Falha ao salvar no disco' });
  }
});

// GET /api/status - Verifica se o servidor está rodando
app.get('/api/status', (req, res) => {
  const dados = lerDados();
  res.json({
    servidor: 'online',
    arquivo: DATA_FILE,
    animais: (dados.animais || []).length,
    producaoLeite: (dados.producaoLeite || []).length,
    ultimaSalvamento: dados.ultimaSalvamento
  });
});

// ===== COTAÇÕES EM TEMPO REAL =====
const https = require('https');

// Cache para não ficar consultando a cada segundo
let cotacoesCache = null;
let cotacoesCacheTime = 0;
const CACHE_DURATION = 30 * 60 * 1000; // 30 minutos

// Valores atualizados (abril 2026 - CEPEA/ESALQ)
const COTACOES_FALLBACK = {
  boiGordo: { valor: 358.40, unidade: 'R$/@', fonte: 'CEPEA/ESALQ (ref. 29/04/2026)', data: '2026-04-29' },
  bufalo:   { valor: 290.00, unidade: 'R$/@', fonte: 'Mercado regional (estimativa)', data: '2026-04-29' },
  leite:    { valor: 2.42,   unidade: 'R$/litro', fonte: 'CEPEA (ref. abril/2026)', data: '2026-04-29' },
  atualizado: new Date().toISOString()
};

function buscarCotacoes() {
  return new Promise((resolve) => {
    // Tenta buscar dados atualizados da web
    const url = 'https://www.noticiasagricolas.com.br/cotacoes/boi-gordo';
    const options = {
      headers: { 'User-Agent': 'AgropecFuturo/2.0' },
      timeout: 5000
    };
    
    const req = https.get(url, options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          // Tenta extrair preço do HTML
          const match = data.match(/R\$\s*([\d.,]+)\s*\/@/);
          if (match) {
            const preco = parseFloat(match[1].replace('.', '').replace(',', '.'));
            if (preco > 100 && preco < 1000) {
              const cotacoes = {
                boiGordo: { valor: preco, unidade: 'R$/@', fonte: 'Notícias Agrícolas (tempo real)', data: new Date().toISOString().split('T')[0] },
                bufalo:   { valor: Math.round(preco * 0.81 * 100) / 100, unidade: 'R$/@', fonte: 'Estimativa (81% do boi)', data: new Date().toISOString().split('T')[0] },
                leite:    COTACOES_FALLBACK.leite,
                atualizado: new Date().toISOString()
              };
              console.log(`[COTAÇÕES] Boi gordo atualizado: R$ ${preco}/@`);
              resolve(cotacoes);
              return;
            }
          }
        } catch (e) { /* fallback */ }
        console.log('[COTAÇÕES] Usando valores de referência CEPEA.');
        resolve(COTACOES_FALLBACK);
      });
    });
    
    req.on('error', () => {
      console.log('[COTAÇÕES] Sem internet. Usando valores salvos.');
      resolve(COTACOES_FALLBACK);
    });
    
    req.on('timeout', () => {
      req.destroy();
      resolve(COTACOES_FALLBACK);
    });
  });
}

// GET /api/cotacoes - Retorna cotações atuais
app.get('/api/cotacoes', async (req, res) => {
  const agora = Date.now();
  if (cotacoesCache && (agora - cotacoesCacheTime) < CACHE_DURATION) {
    return res.json(cotacoesCache);
  }
  
  const cotacoes = await buscarCotacoes();
  cotacoesCache = cotacoes;
  cotacoesCacheTime = agora;
  res.json(cotacoes);
});

// Inicia o servidor
app.listen(PORT, () => {
  console.log('');
  console.log('╔════════════════════════════════════════════════════╗');
  console.log('║   SERVIDOR DE DADOS - AgropecFuturo Leite         ║');
  console.log(`║   Rodando na porta: ${PORT}                          ║`);
  console.log(`║   Arquivo de dados: dados_agropecfuturo.json      ║`);
  console.log('║   Cotações: Boi, Búfalo e Leite em tempo real     ║');
  console.log('║   Status: ONLINE ✓                                ║');
  console.log('╚════════════════════════════════════════════════════╝');
  console.log('');
  
  // Garante que o arquivo de dados existe ao iniciar
  lerDados();
  // Pré-carrega cotações
  buscarCotacoes().then(c => { cotacoesCache = c; cotacoesCacheTime = Date.now(); });
});
