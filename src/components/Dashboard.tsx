import * as React from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { TrendingUp, Users, DollarSign, Activity, AlertCircle, TrendingDown, Baby, Scale } from "lucide-react";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line, PieChart, Pie, Cell, Legend } from "recharts";
import { cn } from "@/lib/utils";
import { Animal } from "@/types";

interface DashboardProps {
  animals: Animal[];
}

export function Dashboard({ animals }: DashboardProps) {
  const [arrobaPrice, setArrobaPrice] = React.useState(358.40);
  const [buffaloPrice, setBuffaloPrice] = React.useState(290.00);
  const [milkPrice, setMilkPrice] = React.useState(2.42);
  const [priceSource, setPriceSource] = React.useState('Carregando...');
  const [priceDate, setPriceDate] = React.useState('');

  // Busca cotações atualizadas do servidor
  React.useEffect(() => {
    async function fetchCotacoes() {
      try {
        const res = await fetch('http://localhost:3004/api/cotacoes');
        if (!res.ok) return;
        const dados = await res.json();
        if (dados.boiGordo) setArrobaPrice(dados.boiGordo.valor);
        if (dados.bufalo) setBuffaloPrice(dados.bufalo.valor);
        if (dados.leite) setMilkPrice(dados.leite.valor);
        setPriceSource(dados.boiGordo?.fonte || 'CEPEA/ESALQ');
        setPriceDate(dados.boiGordo?.data || '');
      } catch (e) {
        setPriceSource('Sem conexão (valores de referência)');
      }
    }
    fetchCotacoes();
    // Atualiza a cada 30 minutos
    const interval = setInterval(fetchCotacoes, 30 * 60 * 1000);
    return () => clearInterval(interval);
  }, []);
  const activeAnimals = animals.filter(a => a.status === 'Ativo');
  const soldAnimals = animals.filter(a => a.status === 'Vendido');
  const deadAnimals = animals.filter(a => a.status === 'Morto');

  const totalInvestment = React.useMemo(() => {
    return activeAnimals.reduce((acc, a) => {
      const expenses = a.despesas.reduce((sum, d) => sum + d.valor, 0);
      const entryDate = new Date(a.dataEntrada);
      const today = new Date();
      const diffDays = Math.ceil(Math.abs(today.getTime() - entryDate.getTime()) / (1000 * 60 * 60 * 24)) || 1;
      const custoFinanciamento = a.precoCompra * ((a.taxaJurosAnual || 0) / 100) * (diffDays / 365);
      
      return acc + a.precoCompra + custoFinanciamento + expenses;
    }, 0);
  }, [activeAnimals]);

  const totalProfit = soldAnimals.reduce((acc, a) => acc + (a.venda?.lucro || 0), 0);
  const totalLoss = deadAnimals.reduce((acc, a) => {
    const entryDate = new Date(a.dataEntrada);
    const today = new Date();
    const diffDays = Math.ceil(Math.abs(today.getTime() - entryDate.getTime()) / (1000 * 60 * 60 * 24)) || 1;
    const custoFinanciamento = a.precoCompra * ((a.taxaJurosAnual || 0) / 100) * (diffDays / 365);
    const invest = a.precoCompra + custoFinanciamento + a.despesas.reduce((dAcc, d) => dAcc + d.valor, 0);
    return acc + invest;
  }, 0);
  
  const birthRate = activeAnimals.length > 0 
    ? (activeAnimals.filter(a => a.tipoEntrada === 'Cria').length / activeAnimals.length) * 100 
    : 0;

  // Global ROI on Feed calculation
  const globalFeedRoi = React.useMemo(() => {
    let totalGainValue = 0;
    let totalFeedCost = 0;

    activeAnimals.forEach(a => {
      const initialWeight = a.historicoPesos[0]?.peso || 0;
      const currentWeight = a.historicoPesos[a.historicoPesos.length - 1]?.peso || 0;
      const weightGain = currentWeight - initialWeight;
      const marketPrice = a.raca === 'Búfalo' ? buffaloPrice : arrobaPrice;
      
      totalGainValue += weightGain * marketPrice;
      totalFeedCost += a.despesas
        .filter(d => d.tipo.toLowerCase().includes('ração'))
        .reduce((acc, d) => acc + d.valor, 0);
    });

    return totalFeedCost > 0 ? totalGainValue / totalFeedCost : 0;
  }, [activeAnimals, arrobaPrice, buffaloPrice]);

  // Gráfico de Crescimento do Rebanho (Simulado por data de entrada)
  const growthData = React.useMemo(() => {
    const months: Record<string, number> = {};
    animals.forEach(a => {
      const month = a.dataEntrada.substring(0, 7); // YYYY-MM
      months[month] = (months[month] || 0) + 1;
    });
    return Object.entries(months)
      .sort()
      .map(([name, count]) => ({ name, count }));
  }, [animals]);

  // Gráfico de Engorda (Peso Individual ao longo do tempo)
  const engordaData = React.useMemo(() => {
    const allWeights: { date: string, weight: number, id: string }[] = [];
    animals.forEach(a => {
      a.historicoPesos.forEach(p => {
        allWeights.push({ date: p.data, weight: p.peso, id: a.id });
      });
    });
    
    // Agrupar por data para mostrar a evolução temporal
    const groupedByDate: Record<string, number> = {};
    const countsByDate: Record<string, number> = {};
    
    allWeights.forEach(w => {
      groupedByDate[w.date] = (groupedByDate[w.date] || 0) + w.weight;
      countsByDate[w.date] = (countsByDate[w.date] || 0) + 1;
    });

    return Object.entries(groupedByDate)
      .sort((a, b) => a[0].localeCompare(b[0]))
      .map(([date, sum]) => ({ 
        name: new Date(date).toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' }), 
        peso: parseFloat((sum / countsByDate[date]).toFixed(1)) 
      }));
  }, [animals]);

  // Gráfico de Crias (Temporal)
  const birthTrendData = React.useMemo(() => {
    const births: Record<string, number> = {};
    animals.forEach(a => {
      if (a.tipoEntrada === 'Cria') {
        const date = a.dataEntrada.substring(0, 7); // YYYY-MM
        births[date] = (births[date] || 0) + 1;
      }
    });
    return Object.entries(births)
      .sort()
      .map(([name, count]) => ({ 
        name: new Date(name + "-01").toLocaleDateString('pt-BR', { month: 'short', year: '2-digit' }), 
        count 
      }));
  }, [animals]);

  const COLORS = ['#10b981', '#3b82f6', '#f59e0b', '#ef4444'];

  return (
    <div className="space-y-8 relative min-h-[80vh] p-6 rounded-2xl overflow-hidden">
      {/* Background Image */}
      <div 
        className="absolute inset-0 z-0 opacity-20 pointer-events-none"
        style={{ 
          backgroundImage: 'url("https://images.unsplash.com/photo-1596733430284-f7437764b1a9?q=80&w=2070&auto=format&fit=crop")',
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          filter: 'brightness(0.5)'
        }}
      />

      <div className="relative z-10 space-y-8">
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
          <div className="flex flex-col gap-1">
            <h2 className="text-3xl font-bold tracking-tight text-slate-900">Painel de Controle</h2>
            <p className="text-slate-500">Dados reais e projeções de mercado.</p>
          </div>
          
          <div className="flex flex-col sm:flex-row gap-3">
            <div className="bg-white border border-slate-200 rounded-xl p-3 shadow-sm flex items-center gap-3">
              <div className="bg-emerald-100 p-2 rounded-lg">
                <TrendingUp className="w-5 h-5 text-emerald-600" />
              </div>
              <div>
                <p className="text-[10px] text-slate-500 font-medium uppercase tracking-wider">Arroba Nelore</p>
                <div className="flex items-center gap-2">
                  <span className="text-lg font-bold text-slate-900">R$ {arrobaPrice.toFixed(2)}</span>
                </div>
              </div>
            </div>

            <div className="bg-white border border-slate-200 rounded-xl p-3 shadow-sm flex items-center gap-3">
              <div className="bg-blue-100 p-2 rounded-lg">
                <TrendingUp className="w-5 h-5 text-blue-600" />
              </div>
              <div>
                <p className="text-[10px] text-slate-500 font-medium uppercase tracking-wider">Arroba Búfalo</p>
                <div className="flex items-center gap-2">
                  <span className="text-lg font-bold text-slate-900">R$ {buffaloPrice.toFixed(2)}</span>
                </div>
              </div>
            </div>

            <div className="bg-white border border-slate-200 rounded-xl p-3 shadow-sm flex items-center gap-3">
              <div className="bg-cyan-100 p-2 rounded-lg">
                <DollarSign className="w-5 h-5 text-cyan-600" />
              </div>
              <div>
                <p className="text-[10px] text-slate-500 font-medium uppercase tracking-wider">Leite ao Produtor</p>
                <div className="flex items-center gap-2">
                  <span className="text-lg font-bold text-slate-900">R$ {milkPrice.toFixed(2)}/L</span>
                </div>
              </div>
            </div>
          </div>
          <p className="text-[9px] text-slate-400 mt-1 italic">
            Fonte: {priceSource} {priceDate ? `• Ref: ${priceDate}` : ''} • Atualiza a cada 30 min
          </p>
        </div>

        <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 flex gap-3 items-start">
          <AlertCircle className="w-5 h-5 text-amber-600 mt-0.5 flex-shrink-0" />
          <div className="text-sm text-amber-800 space-y-1">
            <p className="font-bold">Diretrizes de Manejo:</p>
            <p>• Estação de monta: Novembro (13-14 meses, média 300kg).</p>
            <p>• Partos: Setembro (23-24 meses, média 400kg).</p>
            <p>• Desmama: 8 meses (margem de 200 a 250 kg).</p>
          </div>
        </div>

        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-5">
          <Card className="border-none shadow-sm bg-white">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-slate-500">Total Ativos</CardTitle>
              <Users className="h-4 w-4 text-emerald-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{activeAnimals.length}</div>
              <p className="text-xs text-slate-500 mt-1">Animais na propriedade</p>
            </CardContent>
          </Card>

          <Card className="border-none shadow-sm bg-white">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-slate-500">Investimento Ativo</CardTitle>
              <DollarSign className="h-4 w-4 text-blue-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">R$ {totalInvestment.toLocaleString('pt-BR')}</div>
              <p className="text-xs text-slate-500 mt-1">Média: R$ {(totalInvestment / (activeAnimals.length || 1)).toFixed(0)}/cab</p>
            </CardContent>
          </Card>

          <Card className="border-none shadow-sm bg-white">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-slate-500">Resultado (Lucro/Perda)</CardTitle>
              <Activity className="h-4 w-4 text-orange-500" />
            </CardHeader>
            <CardContent>
              <div className={cn("text-2xl font-bold", (totalProfit - totalLoss) >= 0 ? "text-emerald-600" : "text-red-600")}>
                R$ {(totalProfit - totalLoss).toLocaleString('pt-BR')}
              </div>
              <p className="text-xs text-slate-500 mt-1">Perda por morte: R$ {totalLoss.toLocaleString('pt-BR')}</p>
            </CardContent>
          </Card>

          <Card className="border-none shadow-sm bg-white">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-slate-500">% Nascimentos</CardTitle>
              <Baby className="h-4 w-4 text-purple-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{birthRate.toFixed(1)}%</div>
              <p className="text-xs text-slate-500 mt-1">Proporção de crias no rebanho</p>
            </CardContent>
          </Card>

          <Card className="border-none shadow-sm bg-white">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-slate-500">ROI sobre Ração</CardTitle>
              <TrendingUp className={cn("h-4 w-4", globalFeedRoi > 1 ? "text-emerald-500" : "text-amber-500")} />
            </CardHeader>
            <CardContent>
              <div className={cn("text-2xl font-bold", globalFeedRoi > 1 ? "text-emerald-600" : "text-amber-600")}>
                {globalFeedRoi.toFixed(2)}x
              </div>
              <p className="text-xs text-slate-500 mt-1">Retorno em peso vs custo ração</p>
            </CardContent>
          </Card>
        </div>

        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
          <Card className="lg:col-span-4 border-none shadow-sm bg-white">
            <CardHeader>
              <CardTitle className="text-lg font-semibold flex items-center gap-2">
                <TrendingUp className="w-5 h-5 text-emerald-500" />
                Crescimento do Rebanho
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="h-[300px]">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={growthData}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                    <XAxis dataKey="name" stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} />
                    <YAxis stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} />
                    <Tooltip contentStyle={{ backgroundColor: '#fff', borderRadius: '8px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }} />
                    <Line type="monotone" dataKey="count" stroke="#10b981" strokeWidth={3} dot={{ r: 4, fill: '#10b981' }} />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>

          <Card className="lg:col-span-3 border-none shadow-sm bg-white">
            <CardHeader>
              <CardTitle className="text-lg font-semibold flex items-center gap-2">
                <Scale className="w-5 h-5 text-blue-500" />
                Evolução de Peso (@)
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="h-[300px]">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={engordaData}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                    <XAxis dataKey="name" stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} />
                    <YAxis stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} />
                    <Tooltip cursor={{ fill: '#f8fafc' }} contentStyle={{ backgroundColor: '#fff', borderRadius: '8px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }} />
                    <Bar dataKey="peso" fill="#3b82f6" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>

          <Card className="lg:col-span-7 border-none shadow-sm bg-white">
            <CardHeader>
              <CardTitle className="text-lg font-semibold flex items-center gap-2">
                <Baby className="w-5 h-5 text-purple-500" />
                Tendência de Nascimentos (Crias)
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="h-[300px]">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={birthTrendData}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                    <XAxis dataKey="name" stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} />
                    <YAxis stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} />
                    <Tooltip cursor={{ fill: '#f8fafc' }} contentStyle={{ backgroundColor: '#fff', borderRadius: '8px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }} />
                    <Bar dataKey="count" fill="#8b5cf6" radius={[4, 4, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
