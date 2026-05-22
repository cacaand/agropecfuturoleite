/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import * as React from "react";
import { Layout } from "./components/Layout";
import { Dashboard } from "./components/Dashboard";
import { AnimalTable } from "./components/AnimalTable";
import { AddAnimalDialog } from "./components/AddAnimalDialog";
import { Financeiro } from "./components/Financeiro";
import { Historico } from "./components/Historico";
import { Engorda } from "./components/Engorda";
import { ControleSanitario } from "./components/ControleSanitario";
import { Bezerros } from "./components/Bezerros";
import { ProducaoLeite } from "./components/ProducaoLeite";
import { UpdateWeightDialog } from "./components/UpdateWeightDialog";
import { VaccineDialog } from "./components/VaccineDialog";
import { SaleDialog } from "./components/SaleDialog";
import { DeathDialog } from "./components/DeathDialog";
import { HealthDialog } from "./components/HealthDialog";
import { AnimalProfileDialog } from "./components/AnimalProfileDialog";
import { DeleteConfirmDialog } from "./components/DeleteConfirmDialog";
import { Animal, OcorrenciaSaude, UserSettings, MilkProductionRecord } from "./types";
import { db } from "./db";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Toaster } from "@/components/ui/sonner";
import { toast } from "sonner";
import { cn } from "@/lib/utils";

import { Beef, Landmark, TrendingUp, Calendar, Droplets } from "lucide-react";

// Utility to ensure animal data is solid and won't crash the UI
const sanitizeAnimal = (a: any): Animal => {
  return {
    ...a,
    id: String(a.id || Date.now()),
    status: a.status || 'Ativo',
    sexo: a.sexo || 'Macho',
    precoCompra: Number(a.precoCompra) || 0,
    taxaJurosAnual: Number(a.taxaJurosAnual) || 0,
    historicoPesos: Array.isArray(a.historicoPesos) ? a.historicoPesos : [],
    vacinas: Array.isArray(a.vacinas) ? a.vacinas : [],
    ocorrenciasSaude: Array.isArray(a.ocorrenciasSaude) ? a.ocorrenciasSaude : [],
    despesas: Array.isArray(a.despesas) ? a.despesas.map((d: any) => ({
      ...d,
      valor: Number(d.valor) || 0
    })) : [],
    dataEntrada: a.dataEntrada || new Date().toISOString().split('T')[0],
    partos: Number(a.partos) || 0,
    updatedAt: a.updatedAt || new Date().toISOString()
  } as Animal;
};

const sanitizeMilk = (m: any): MilkProductionRecord => ({
  ...m,
  quantidade: Number(m.quantidade) || 0,
  numVacas: Number(m.numVacas) || 0,
  data: m.data || new Date().toISOString().split('T')[0]
});

export default function App() {
  const [activeTab, setActiveTab] = React.useState("dashboard");
  
  // ===== ESTADO PRINCIPAL =====
  const [animals, setAnimals] = React.useState<Animal[]>([]);
  const [userSettings, setUserSettings] = React.useState<UserSettings>({
    nomeUsuario: "",
    nomePropriedade: "",
    cartaoProdutor: "",
    registroIMA: "",
    cotacaoLeiteVaca: 0,
    cotacaoLeiteBufala: 0
  });
  const [milkProduction, setMilkProduction] = React.useState<MilkProductionRecord[]>([]);
  // ===== FIM ESTADO PRINCIPAL =====

  const [isAddDialogOpen, setIsAddDialogOpen] = React.useState(false);
  const [editingAnimal, setEditingAnimal] = React.useState<Animal | null>(null);
  const [prefilledData, setPrefilledData] = React.useState<Partial<Animal> | null>(null);
  const [weightUpdateAnimal, setWeightUpdateAnimal] = React.useState<Animal | null>(null);
  const [vaccineUpdateAnimal, setVaccineUpdateAnimal] = React.useState<Animal | null>(null);
  const [saleAnimal, setSaleAnimal] = React.useState<Animal | null>(null);
  const [deathAnimal, setDeathAnimal] = React.useState<Animal | null>(null);
  const [healthAnimal, setHealthAnimal] = React.useState<Animal | null>(null);
  const [profileAnimal, setProfileAnimal] = React.useState<Animal | null>(null);
  const [deletingAnimalId, setDeletingAnimalId] = React.useState<string | null>(null);
  const [dbStatus, setDbStatus] = React.useState<'loading' | 'connected' | 'error'>('loading');
  const [isSaving, setIsSaving] = React.useState(false);
  const [isExiting, setIsExiting] = React.useState(false);
  const [backupConfig, setBackupConfig] = React.useState({
    frequency: localStorage.getItem("backup_frequency") || "weekly",
    lastDate: localStorage.getItem("last_backup_date") || ""
  });

  // URL do servidor de dados (roda na porta 3004)
  const API_URL = 'http://localhost:3004';

  // ===== CARREGAR DADOS DO ARQUIVO FÍSICO AO LIGAR =====
  React.useEffect(() => {
    async function carregarDoDisco() {
      console.log("[DISCO] Carregando dados do arquivo físico...");
      try {
        const res = await fetch(`${API_URL}/api/dados`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const dados = await res.json();
        
        if (dados.animais && dados.animais.length > 0) {
          setAnimals(dados.animais.map(sanitizeAnimal));
          console.log(`[DISCO] ${dados.animais.length} animais carregados do arquivo físico.`);
        }
        if (dados.configuracoes && dados.configuracoes.nomeUsuario !== undefined) {
          setUserSettings(dados.configuracoes);
        }
        if (dados.producaoLeite && dados.producaoLeite.length > 0) {
          setMilkProduction(dados.producaoLeite.map(sanitizeMilk));
        }
        setDbStatus('connected');
        console.log("[DISCO] Banco de dados conectado com sucesso.");
      } catch (e) {
        console.error("[DISCO] Servidor de dados não encontrado:", e);
        setDbStatus('error');
        toast.error("Servidor de dados não encontrado. Os dados NÃO serão salvos.", { duration: 10000 });
      }
    }
    carregarDoDisco();
  }, []);

  // ===== SALVAR NO ARQUIVO FÍSICO (SOMENTE QUANDO DADOS MUDAREM) =====
  const ultimoSalvo = React.useRef<string>('');
  const carregamentoCompleto = React.useRef(false);
  
  React.useEffect(() => {
    if (dbStatus !== 'connected') return;
    
    const dadosAtuais = JSON.stringify({ a: animals, s: userSettings, m: milkProduction });
    
    // Na primeira vez que conecta, apenas registra o estado inicial (não salva)
    if (!carregamentoCompleto.current) {
      carregamentoCompleto.current = true;
      ultimoSalvo.current = dadosAtuais;
      return;
    }
    
    // Se os dados não mudaram, não faz nada (evita piscar)
    if (dadosAtuais === ultimoSalvo.current) return;

    const salvarNoDisco = async () => {
      try {
        const dados = {
          versao: "AgropecFuturo Leite v2.0",
          animais: animals,
          configuracoes: userSettings,
          producaoLeite: milkProduction
        };
        const res = await fetch(`${API_URL}/api/dados`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(dados)
        });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        ultimoSalvo.current = dadosAtuais;
        console.log(`[DISCO] Salvo: ${animals.length} animais no disco.`);
      } catch (e) {
        console.error("[DISCO] Falha ao salvar no disco:", e);
      }
    };

    // Salva 2 segundos após a última mudança (debounce)
    const timeout = setTimeout(salvarNoDisco, 2000);
    return () => clearTimeout(timeout);
  }, [animals, userSettings, milkProduction, dbStatus]);

  const handleManualSaveAndExit = async () => {
    setIsSaving(true);
    try {
      // Salva no arquivo físico do disco
      const dados = {
        versao: "AgropecFuturo Leite v2.0",
        animais: animals,
        configuracoes: userSettings,
        producaoLeite: milkProduction
      };
      const res = await fetch(`${API_URL}/api/dados`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(dados)
      });
      if (!res.ok) throw new Error('Falha ao salvar');
      
      toast.success("✅ Dados salvos no disco com segurança!");
    } catch (err) {
      toast.error("Erro ao salvar os dados no disco.");
    } finally {
      setIsSaving(false);
    }
  };


  // Automatic Backup Logic
  React.useEffect(() => {
    if (backupConfig.frequency === 'disabled' || animals.length === 0) return;

    const now = new Date();
    const lastDate = backupConfig.lastDate ? new Date(backupConfig.lastDate) : new Date(0);
    const diffMs = now.getTime() - lastDate.getTime();
    const diffDays = diffMs / (1000 * 60 * 60 * 24);

    let threshold = 1; // daily
    if (backupConfig.frequency === 'weekly') threshold = 7;
    if (backupConfig.frequency === 'monthly') threshold = 30;

    if (diffDays >= threshold) {
      setTimeout(() => {
        toast("Cópia de segurança pendente", {
          description: `Sua última cópia foi há ${Math.floor(diffDays)} dias. Deseja baixar uma agora?`,
          action: {
            label: "Baixar Agora",
            onClick: () => handleBackup()
          },
        });
      }, 3000);
    }
  }, [animals, backupConfig]);

  const handleAddAnimal = (animalData: Partial<Animal>) => {
    const newAnimal: Animal = {
      ...animalData,
      id: animalData.id || `A-${Date.now()}`,
      sexo: animalData.sexo || 'Macho',
      tipoEntrada: animalData.tipoEntrada || 'Compra',
      precoCompra: animalData.precoCompra ?? 0,
      status: 'Ativo',
      partos: 0,
      historicoPesos: animalData.historicoPesos || [],
      vacinas: [],
      ocorrenciasSaude: [],
      despesas: [],
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    } as Animal;

    // Increment birth count for mother if applicable
    let updated = [...animals];
    if (newAnimal.tipoEntrada === 'Cria' && newAnimal.mae) {
      updated = updated.map(a => 
        a.id === newAnimal.mae ? { ...a, partos: (a.partos || 0) + 1, updatedAt: new Date().toISOString() } : a
      );
    }
    setAnimals([...updated, newAnimal]);
    setIsAddDialogOpen(false);
    setPrefilledData(null);
    toast.success("Animal cadastrado com sucesso!");
  };

  const handleEditAnimal = (updatedAnimal: Partial<Animal>) => {
    const updated = animals.map(a => a.id === updatedAnimal.id ? { ...a, ...updatedAnimal, updatedAt: new Date().toISOString() } : a);
    setAnimals(updated as Animal[]);
    setEditingAnimal(null);
    toast.success("Animal atualizado com sucesso!");
  };

  const handleBackup = () => {
    // Include BOTH animals AND settings in the backup
    const backupData = {
      versao: "AgropecFuturo v1.0",
      dataBackup: new Date().toISOString(),
      configuracoes: userSettings,
      animais: animals,
      producaoLeite: milkProduction
    };
    
    const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(backupData, null, 2));
    const downloadAnchorNode = document.createElement('a');
    downloadAnchorNode.setAttribute("href", dataStr);
    const date = new Date().toISOString().split('T')[0];
    const hora = new Date().toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' }).replace(':', 'h');
    downloadAnchorNode.setAttribute("download", `AgropecFuturo_Backup_${date}_${hora}.json`);
    document.body.appendChild(downloadAnchorNode);
    downloadAnchorNode.click();
    downloadAnchorNode.remove();
    
    // Update last backup date
    const now = new Date().toISOString();
    localStorage.setItem("last_backup_date", now);
    setBackupConfig(prev => ({ ...prev, lastDate: now }));
    
    toast.success(
      `Backup salvo! O arquivo foi para a pasta de Downloads do seu navegador (geralmente ~/Downloads). Copie para seu Pendrive ou HD Externo.`,
      { duration: 8000 }
    );
  };


  const handleImport = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const content = e.target?.result as string;
        const parsed = JSON.parse(content);
        
        // New format: { versao, configuracoes, animais }
        if (parsed && parsed.animais && Array.isArray(parsed.animais)) {
          setAnimals(parsed.animais.map(sanitizeAnimal));
          if (parsed.configuracoes) {
            setUserSettings(parsed.configuracoes);
          }
          if (parsed.producaoLeite) {
            setMilkProduction(parsed.producaoLeite.map(sanitizeMilk));
          }
          toast.success(`${parsed.animais.length} registros + configurações restaurados com sucesso!`);
        }
        // Old format: direct array
        else if (Array.isArray(parsed)) {
          setAnimals(parsed.map(sanitizeAnimal));
          toast.success(`${parsed.length} registros importados com sucesso!`);
        } else {
          toast.error("Formato de arquivo inválido.");
        }
      } catch (err) {
        toast.error("Erro ao ler o arquivo de backup.");
      }
    };
    reader.readAsText(file);
    // Reset input so the same file can be re-imported
    event.target.value = '';
  };


  const handleBackupFrequency = (freq: string) => {
    localStorage.setItem("backup_frequency", freq);
    setBackupConfig(prev => ({ ...prev, frequency: freq }));
    toast.success(`Frequência de backup alterada para: ${freq}`);
  };

  const handleDeleteAnimal = (id: string) => {
    setDeletingAnimalId(id);
  };

  const confirmDeleteAnimal = () => {
    if (deletingAnimalId) {
      setAnimals(animals.filter(a => a.id !== deletingAnimalId));
      setDeletingAnimalId(null);
      toast.info("Animal removido permanentemente.");
    }
  };

  const handleSaveWeight = (animalId: string, peso: number, data: string) => {
    const updatedAnimals = animals.map(a => {
      if (a.id === animalId) {
        return {
          ...a,
          historicoPesos: [...a.historicoPesos, { data, peso }],
          updatedAt: new Date().toISOString()
        };
      }
      return a;
    });
    setAnimals(updatedAnimals);
    setWeightUpdateAnimal(null);
    toast.success("Peso registrado com sucesso!");
  };

  const handleAddWeight = (animal: Animal) => {
    setWeightUpdateAnimal(animal);
  };

  const handleAddVaccine = (animal: Animal) => {
    setVaccineUpdateAnimal(animal);
  };

  const handleAddHealth = (animal: Animal) => {
    setHealthAnimal(animal);
  };

  const handleViewProfile = (animal: Animal) => {
    setProfileAnimal(animal);
  };

  const handleSaveVaccine = (animalId: string, tipo: string, data: string) => {
    const updatedAnimals = animals.map(a => {
      if (a.id === animalId) {
        return {
          ...a,
          vacinas: [...a.vacinas, { data, tipo }],
          updatedAt: new Date().toISOString()
        };
      }
      return a;
    });
    setAnimals(updatedAnimals);
    setVaccineUpdateAnimal(null);
    toast.success("Vacina registrada com sucesso!");
  };

  const handleSaveHealth = (animalId: string, ocorrencia: OcorrenciaSaude) => {
    const updatedAnimals = animals.map(a => {
      if (a.id === animalId) {
        return {
          ...a,
          ocorrenciasSaude: [...(a.ocorrenciasSaude || []), ocorrencia],
          despesas: [...a.despesas, {
            tipo: `Saúde: ${ocorrencia.tipo} - ${ocorrencia.diagnostico}`,
            valor: ocorrencia.custo,
            data: ocorrencia.data
          }],
          updatedAt: new Date().toISOString()
        };
      }
      return a;
    });
    setAnimals(updatedAnimals);
    setHealthAnimal(null);
    toast.success("Ocorrência de saúde registrada!");
  };

  const handleAddBirth = (animal: Animal) => {
    setPrefilledData({
      mae: animal.id,
      tipoEntrada: 'Cria',
      precoCompra: 0,
      raca: animal.raca
    });
    setIsAddDialogOpen(true);
  };

  const handleSale = (animal: Animal) => {
    setSaleAnimal(animal);
  };

  const handleConfirmSale = (animal: Animal, preco: number) => {
    // CDI Anual (ex: 11.25%)
    const CDI_ANUAL = 0.1125;
    
    // Cálculo de tempo (dias)
    const entryDate = new Date(animal.dataEntrada);
    const saleDate = new Date();
    const diffTime = Math.abs(saleDate.getTime() - entryDate.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) || 1;
    const diffYears = diffDays / 365;

    // Custo de Financiamento (se houver)
    let custoFinanciamento = 0;
    if (animal.origemCapital === 'Empréstimo' || animal.formaPagamento === 'A prazo') {
      custoFinanciamento = animal.precoCompra * ((animal.taxaJurosAnual || 0) / 100) * diffYears;
    }

    // Lucro CDI (Custo de Oportunidade)
    const lucroCDI = animal.precoCompra * Math.pow(1 + CDI_ANUAL, diffYears) - animal.precoCompra;

    const totalInvested = animal.precoCompra + custoFinanciamento + animal.despesas.reduce((acc, d) => acc + d.valor, 0);
    const lucro = preco - totalInvested;

    const updatedAnimals = animals.map(a => {
      if (a.id === animal.id) {
        return {
          ...a,
          status: 'Vendido' as const,
          venda: {
            preco,
            data: new Date().toISOString().split('T')[0],
            lucro,
            lucroCDI,
            custoFinanciamento
          },
          updatedAt: new Date().toISOString()
        };
      }
      return a;
    });
    setAnimals(updatedAnimals);
    setSaleAnimal(null);
    toast.success(`Venda registrada! Lucro: R$ ${lucro.toFixed(2)}.`);
  };

  const handleDeath = (animal: Animal) => {
    setDeathAnimal(animal);
  };

  const handleConfirmDeath = (animal: Animal, motivo: string) => {
    // Cálculo de tempo para juros
    const entryDate = new Date(animal.dataEntrada);
    const today = new Date();
    const diffDays = Math.ceil(Math.abs(today.getTime() - entryDate.getTime()) / (1000 * 60 * 60 * 24)) || 1;
    const custoFinanciamento = animal.precoCompra * ((animal.taxaJurosAnual || 0) / 100) * (diffDays / 365);

    const totalInvested = animal.precoCompra + custoFinanciamento + animal.despesas.reduce((acc, d) => acc + d.valor, 0);
    
    const activeAnimals = animals.filter(a => a.status === 'Ativo' && a.id !== animal.id);
    
    let updatedAnimals = animals.map(a => {
      if (a.id === animal.id) {
        return {
          ...a,
          status: 'Morto' as const,
          motivoMorte: motivo,
          updatedAt: new Date().toISOString()
        };
      }
      return a;
    });

    if (activeAnimals.length > 0) {
      const rateio = totalInvested / activeAnimals.length;
      updatedAnimals = updatedAnimals.map(a => {
        if (a.status === 'Ativo') {
          return {
            ...a,
            despesas: [...a.despesas, {
              tipo: `Rateio Morte (ID:${animal.id})`,
              valor: rateio,
              data: new Date().toISOString().split('T')[0]
            }],
            updatedAt: new Date().toISOString()
          };
        }
        return a;
      });
    }

    setAnimals(updatedAnimals);
    setDeathAnimal(null);
    toast.error("Morte registrada. Prejuízo rateado.");
  };

  const handleAddExpense = (expense: { tipo: string, valor: number, modo: 'Coletiva' | 'Individual', animalId?: string }) => {
    if (expense.modo === 'Coletiva') {
      const activeAnimals = animals.filter(a => a.status === 'Ativo');
      if (activeAnimals.length === 0) return;

      const rateio = expense.valor / activeAnimals.length;
      const updatedAnimals = animals.map(a => {
        if (a.status === 'Ativo') {
          return {
            ...a,
            despesas: [...a.despesas, {
              tipo: `Rateio ${expense.tipo}`,
              valor: rateio,
              data: new Date().toISOString().split('T')[0]
            }],
            updatedAt: new Date().toISOString()
          };
        }
        return a;
      });
      setAnimals(updatedAnimals);
    } else {
      const updatedAnimals = animals.map(a => {
        if (a.id === expense.animalId) {
          return {
            ...a,
            despesas: [...a.despesas, {
              tipo: expense.tipo,
              valor: expense.valor,
              data: new Date().toISOString().split('T')[0]
            }],
            updatedAt: new Date().toISOString()
          };
        }
        return a;
      });
      setAnimals(updatedAnimals);
    }
  };

  const handleExport = () => {
    const headers = ["ID", "Sexo", "Tipo", "Status", "Investimento", "Venda", "Lucro", "Lucro CDI", "Forma Pagto", "Taxa Juros Anual", "Origem Capital"];
    const rows = animals.map(a => {
      const entryDate = new Date(a.dataEntrada);
      const endDate = a.venda ? new Date(a.venda.data) : new Date();
      const diffDays = Math.ceil(Math.abs(endDate.getTime() - entryDate.getTime()) / (1000 * 60 * 60 * 24)) || 1;
      const custoFinanciamento = a.precoCompra * ((a.taxaJurosAnual || 0) / 100) * (diffDays / 365);

      const totalInvested = a.precoCompra + custoFinanciamento + a.despesas.reduce((acc, d) => acc + d.valor, 0);
      return [
        a.id,
        a.sexo,
        a.tipoEntrada,
        a.status,
        totalInvested.toFixed(2),
        a.venda?.preco.toFixed(2) || "0.00",
        a.venda?.lucro.toFixed(2) || (a.status === 'Morto' ? (-totalInvested).toFixed(2) : "0.00"),
        a.venda?.lucroCDI?.toFixed(2) || "0.00",
        a.formaPagamento || "---",
        `${a.taxaJurosAnual || 0}%`,
        a.origemCapital || "---"
      ];
    });

    const csvContent = [headers, ...rows].map(e => e.join(";")).join("\n");
    const blob = new Blob(["\ufeff" + csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute("download", `rebanho_${new Date().toISOString().split('T')[0]}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    toast.success("Relatório exportado com sucesso!");
  };




  if (isExiting) {
    return (
      <div className="h-screen w-full flex flex-col items-center justify-center bg-slate-900 text-white gap-6">
        <div className="w-20 h-20 bg-emerald-500 rounded-2xl flex items-center justify-center shadow-2xl shadow-emerald-500/20">
          <Beef className="w-10 h-10 text-white" />
        </div>
        <div className="flex flex-col items-center gap-2 text-center max-w-md px-6">
          <h2 className="text-3xl font-bold tracking-tighter uppercase">AgropecFuturo Leite</h2>
          <p className="text-slate-400">Dados salvos com 100% de segurança no banco de dados interno do seu computador.</p>
        </div>
        <div className="flex flex-col items-center gap-4">
          <Badge className="bg-emerald-600 px-4 py-1 text-sm">Sincronização Concluída</Badge>
          <Button 
            onClick={() => setIsExiting(false)} 
            variant="ghost" 
            className="text-slate-500 hover:text-white hover:bg-white/10"
          >
            Voltar ao Programa
          </Button>
          <p className="text-xs text-slate-600 mt-4 italic">Você pode fechar esta aba do navegador agora.</p>
        </div>
      </div>
    );
  }

  if (dbStatus === 'loading') {
    return (
      <div className="min-h-screen bg-slate-900 flex flex-col items-center justify-center gap-6">
        <div className="w-16 h-16 border-4 border-emerald-500 border-t-transparent rounded-full animate-spin"></div>
        <div className="text-center space-y-2">
          <h2 className="text-2xl font-bold text-white tracking-tighter uppercase">AgropecFuturo Leite</h2>
          <p className="text-slate-400 animate-pulse">Conectando ao banco de dados interno...</p>
        </div>
      </div>
    );
  }

  return (
    <Layout 
      activeTab={activeTab} 
      onTabChange={setActiveTab}
      onExit={handleManualSaveAndExit}
      settings={userSettings}
      onSettingsUpdate={setUserSettings}
      dbStatus={dbStatus}
      animalCount={animals.length}
      milkCount={milkProduction.length}
    >
      {activeTab === "dashboard" && <Dashboard animals={animals} />}
      {activeTab === "rebanho" && (
        <AnimalTable 
          animals={animals.filter(a => a.status === 'Ativo')} 
          onAdd={() => setIsAddDialogOpen(true)}
          onEdit={(a) => setEditingAnimal(a)}
          onDelete={handleDeleteAnimal}
          onAddWeight={handleAddWeight}
          onAddVaccine={handleAddVaccine}
          onAddHealth={handleAddHealth}
          onViewProfile={handleViewProfile}
          onSale={handleSale}
          onDeath={handleDeath}
          onAddBirth={handleAddBirth}
        />
      )}
      {activeTab === "engorda" && <Engorda animals={animals} onAddWeight={handleAddWeight} />}
      {activeTab === "bezerros" && (
        <Bezerros 
          animals={animals}
          onAddWeight={handleAddWeight}
          onAddVaccine={handleAddVaccine}
          onViewProfile={handleViewProfile}
          onDeleteAnimal={handleDeleteAnimal}
        />
      )}
      {activeTab === "controle_sanitario" && (
        <ControleSanitario 
          animals={animals}
          onAddWeight={handleAddWeight}
          onAddVaccine={handleAddVaccine}
          onAddHealth={handleAddHealth}
          onViewProfile={handleViewProfile}
          onAddBirth={handleAddBirth}
          onDeath={handleDeath}
          onDeleteAnimal={handleDeleteAnimal}
        />
      )}
      {activeTab === "financeiro" && (
        <Financeiro 
          animals={animals} 
          onAddExpense={handleAddExpense}
          onEditAnimal={(a) => setEditingAnimal(a)}
        />
      )}
      {activeTab === "historico" && (
        <Historico animals={animals} onEdit={(a) => setEditingAnimal(a)} onViewProfile={handleViewProfile} />
      )}
      {activeTab === "producao_leite" && (
        <ProducaoLeite production={milkProduction} setProduction={setMilkProduction} settings={userSettings} />
      )}
      {activeTab === "config" && (
        <div className="p-8 bg-white rounded-xl shadow-sm border border-slate-100 space-y-6 text-slate-900">
          <div className="flex flex-col gap-1">
            <h3 className="text-xl font-semibold text-slate-900 underline decoration-emerald-500 decoration-4 underline-offset-8">Perfil do Produtor e Propriedade</h3>
            <p className="text-slate-500">Dados que aparecerão em todos os documentos e impressões.</p>
          </div>

          <div className="grid gap-6 md:grid-cols-2 bg-slate-50 p-6 rounded-xl border border-slate-200 shadow-inner">
            <div className="space-y-4">
              <div className="grid gap-2">
                <Label htmlFor="nomeUsuario">Nome do Usuário / Responsável</Label>
                <Input 
                  id="nomeUsuario" 
                  value={userSettings.nomeUsuario} 
                  onChange={(e) => setUserSettings({...userSettings, nomeUsuario: e.target.value})}
                  placeholder="Ex: João da Silva"
                />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="nomePropriedade">Nome da Fazenda / Propriedade</Label>
                <Input 
                  id="nomePropriedade" 
                  value={userSettings.nomePropriedade} 
                  onChange={(e) => setUserSettings({...userSettings, nomePropriedade: e.target.value})}
                  placeholder="Ex: Fazenda Santa Fé"
                />
              </div>
            </div>
            <div className="space-y-4">
              <div className="grid gap-2">
                <Label htmlFor="cartaoProdutor">Número do Cartão do Produtor</Label>
                <Input 
                  id="cartaoProdutor" 
                  value={userSettings.cartaoProdutor} 
                  onChange={(e) => setUserSettings({...userSettings, cartaoProdutor: e.target.value})}
                  placeholder="000.000.000-00"
                />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="registroIMA">Registro no IMA</Label>
                <Input 
                  id="registroIMA" 
                  value={userSettings.registroIMA} 
                  onChange={(e) => setUserSettings({...userSettings, registroIMA: e.target.value})}
                  placeholder="Registro Sanitário"
                />
              </div>
            </div>
          </div>

          <div className="flex flex-col gap-1">
            <h3 className="text-xl font-semibold text-slate-900 underline decoration-blue-500 decoration-4 underline-offset-8">Cotações de Leite</h3>
            <p className="text-slate-500">Defina os valores atuais para cálculo de faturamento estimado.</p>
          </div>

          <div className="grid gap-6 md:grid-cols-2 bg-blue-50/50 p-6 rounded-xl border border-blue-100">
            <div className="grid gap-2">
              <Label htmlFor="cotacaoLeiteVaca">Cotação Leite de Vaca (R$ / Litro)</Label>
              <Input 
                id="cotacaoLeiteVaca" 
                type="number"
                step="0.01"
                value={userSettings.cotacaoLeiteVaca} 
                onChange={(e) => setUserSettings({...userSettings, cotacaoLeiteVaca: Number(e.target.value)})}
                placeholder="Ex: 2.15"
              />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="cotacaoLeiteBufala">Cotação Leite de Búfala (R$ / Litro)</Label>
              <Input 
                id="cotacaoLeiteBufala" 
                type="number"
                step="0.01"
                value={userSettings.cotacaoLeiteBufala} 
                onChange={(e) => setUserSettings({...userSettings, cotacaoLeiteBufala: Number(e.target.value)})}
                placeholder="Ex: 3.50"
              />
            </div>
          </div>

          <div className="pt-6 flex flex-col gap-1">
            <h3 className="text-xl font-semibold text-slate-900 underline decoration-emerald-500 decoration-4 underline-offset-8">Segurança e Backup</h3>
            <p className="text-slate-500">Gestão de dados e redundância.</p>
          </div>
          
          <div className="grid gap-6 md:grid-cols-2 pt-4">
            <div className="p-6 border rounded-xl space-y-4 shadow-sm bg-white">
              <div className="flex justify-between items-start">
                <h4 className="font-bold flex items-center gap-2">
                  📂 Banco de Dados e Segurança
                </h4>
                <Badge variant="outline" className={cn(
                  "gap-1",
                  dbStatus === 'connected' ? "text-emerald-600 border-emerald-200" : "text-amber-600 border-amber-200"
                )}>
                  <div className={cn("w-1.5 h-1.5 rounded-full", dbStatus === 'connected' ? "bg-emerald-500" : "bg-amber-500")} />
                  {dbStatus === 'connected' ? "Banco Interno Online" : "Conectando..."}
                </Badge>
              </div>
              <p className="text-xs text-slate-500">Seus dados são salvos em um <b>banco de dados interno</b> no seu computador. Para segurança total contra falhas do Windows/Ubuntu, use as opções abaixo:</p>
              
              <div className="space-y-4 border-t pt-4">
                <div className="space-y-2">
                  <p className="text-[10px] font-bold uppercase text-slate-400">Exportar (Backup p/ Pendrive)</p>
                  <Button onClick={handleBackup} className="bg-emerald-600 hover:bg-emerald-700 w-full gap-2 font-bold shadow-lg shadow-emerald-600/20">
                    💿 Salvar Banco de Dados no Pendrive
                  </Button>
                </div>

                <div className="space-y-2">
                  <p className="text-[10px] font-bold uppercase text-slate-400">Importar (Restaurar de arquivo)</p>
                  <div className="relative">
                    <input 
                      type="file" 
                      id="import-backup" 
                      className="hidden" 
                      accept=".json"
                      onChange={handleImport}
                    />
                    <Button 
                      onClick={() => document.getElementById('import-backup')?.click()} 
                      variant="outline" 
                      className="w-full gap-2 border-dashed border-slate-300 hover:border-emerald-500"
                    >
                      📥 Restaurar Backup do Pendrive
                    </Button>
                  </div>
                </div>
              </div>

              <div className="space-y-3 border-t pt-4">
                <label className="text-[10px] font-bold uppercase text-slate-400">Aviso de Backup Automático</label>
                <div className="flex flex-wrap gap-2">
                  {['daily', 'weekly', 'monthly', 'disabled'].map((f) => (
                    <Button 
                      key={f}
                      variant={backupConfig.frequency === f ? 'default' : 'outline'}
                      size="sm"
                      onClick={() => handleBackupFrequency(f)}
                      className="capitalize"
                    >
                      {f === 'daily' ? 'Diário' : f === 'weekly' ? 'Semanal' : f === 'monthly' ? 'Mensal' : 'Desativar'}
                    </Button>
                  ))}
                </div>
              </div>

              <div className="pt-2 flex flex-col gap-2">
                <Button onClick={handleBackup} className="bg-emerald-600 hover:bg-emerald-700 w-full gap-2 font-bold shadow-lg shadow-emerald-600/20">
                  📥 Salvar Backup Físico Agora (.JSON)
                </Button>
                
                <div className="relative w-full mt-2">
                  <input 
                    type="file" 
                    accept=".json" 
                    onChange={handleImport} 
                    className="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10"
                    title="Clique para restaurar um backup"
                  />
                  <Button variant="outline" className="w-full border-blue-500 text-blue-700 hover:bg-blue-50 font-bold gap-2 relative z-0">
                    📤 Restaurar Backup (.JSON)
                  </Button>
                </div>
                <div className="bg-amber-50 p-3 rounded-lg text-[11px] text-amber-800 flex items-start gap-2 border border-amber-200">
                  <span>📁</span>
                  <div>
                    <p className="font-bold mb-1">Onde o arquivo é salvo?</p>
                    <p>O arquivo vai para a <b>pasta de Downloads</b> do seu computador (geralmente <code className="bg-amber-100 px-1 rounded">~/Downloads</code> ou <code className="bg-amber-100 px-1 rounded">C:\Users\SeuNome\Downloads</code>).</p>
                    <p className="mt-1"><b>Para copiar para o Pendrive:</b> Abra o gerenciador de arquivos, vá em Downloads, procure pelo arquivo <code className="bg-amber-100 px-1 rounded">AgropecFuturo_Backup_...</code> e copie para seu Pendrive ou HD Externo.</p>
                  </div>
                </div>
                <p className="text-[10px] text-center text-slate-400 italic">
                  Último backup: {backupConfig.lastDate ? new Date(backupConfig.lastDate).toLocaleString('pt-BR') : 'Nunca'}
                </p>
              </div>
            </div>

            <div className="p-6 border rounded-xl space-y-4 bg-slate-50 border-slate-200">
              <div className="flex justify-between items-center">
                <h4 className="font-bold flex items-center gap-2">💻 Uso Offline (Windows/Ubuntu)</h4>
                <Badge className="bg-blue-600">Recomendado</Badge>
              </div>
              <div className="space-y-3">
                <p className="text-xs text-slate-600 font-medium">Ao baixar o programa (.ZIP), você recebe o software completo. Siga estes passos para ter seus dados em qualquer PC:</p>
                <div className="bg-white p-3 border rounded-lg space-y-2">
                  <p className="text-[10px] text-slate-700"><b>1. Copie seus Dados:</b> No programa aqui na internet, clique em <b className="text-emerald-700">"Salvar Banco de Dados no Pendrive"</b>.</p>
                  <p className="text-[10px] text-slate-700"><b>2. Abra o Offline:</b> No seu computador, abra a pasta <code>dist</code> e dê dois cliques no arquivo <code>index.html</code>.</p>
                  <p className="text-[10px] text-slate-700"><b>3. Restaure os Dados:</b> No programa offline, vá em Configurações e clique em <b className="text-blue-700">"Restaurar Backup do Pendrive"</b> e selecione o arquivo que você salvou no passo 1.</p>
                </div>
                <div className="bg-emerald-50 border border-emerald-100 p-3 rounded-lg flex items-start gap-2">
                  <span className="text-emerald-600">✅</span>
                  <p className="text-[10px] text-emerald-800 font-medium">Fiz uma atualização especial: agora o programa funciona apenas abrindo o arquivo <code>index.html</code>, sem precisar instalar nada extra!</p>
                </div>
              </div>
            </div>
          </div>
          
          <div className="p-6 border rounded-xl bg-white space-y-4">
             <h4 className="font-bold">📤 Relatórios Comerciais</h4>
             <p className="text-xs text-slate-500">Exporte os dados em formato Excel/CSV para análises externas.</p>
             <Button onClick={handleExport} variant="outline" className="gap-2">
                Exportar Dados do Rebanho (CSV)
             </Button>
          </div>
        </div>
      )}

      <AddAnimalDialog 
        open={isAddDialogOpen || !!editingAnimal} 
        onOpenChange={(open) => {
          if (!open) {
            setIsAddDialogOpen(false);
            setEditingAnimal(null);
          }
        }} 
        onSave={editingAnimal ? handleEditAnimal : handleAddAnimal}
        initialData={(editingAnimal || prefilledData) || undefined}
      />
      <UpdateWeightDialog 
        open={!!weightUpdateAnimal} 
        onOpenChange={(open) => !open && setWeightUpdateAnimal(null)}
        animal={weightUpdateAnimal}
        onSave={handleSaveWeight}
      />
      <VaccineDialog 
        open={!!vaccineUpdateAnimal} 
        onOpenChange={(open) => !open && setVaccineUpdateAnimal(null)}
        animal={vaccineUpdateAnimal}
        onSave={handleSaveVaccine}
      />
      <SaleDialog 
        open={!!saleAnimal} 
        onOpenChange={(open) => !open && setSaleAnimal(null)}
        animal={saleAnimal}
        onSave={handleConfirmSale}
      />
      <DeathDialog 
        open={!!deathAnimal} 
        onOpenChange={(open) => !open && setDeathAnimal(null)}
        animal={deathAnimal}
        onConfirm={handleConfirmDeath}
      />
      <HealthDialog 
        open={!!healthAnimal} 
        onOpenChange={(open) => !open && setHealthAnimal(null)}
        animal={healthAnimal}
        onSave={handleSaveHealth}
      />
      <AnimalProfileDialog 
        open={!!profileAnimal} 
        onOpenChange={(open) => !open && setProfileAnimal(null)}
        animal={profileAnimal}
        settings={userSettings}
      />
      <DeleteConfirmDialog 
        open={deletingAnimalId !== null} 
        onOpenChange={(open) => !open && setDeletingAnimalId(null)}
        animalId={deletingAnimalId || ""}
        onConfirm={confirmDeleteAnimal}
      />
      <Toaster position="top-right" />
    </Layout>
  );
}


