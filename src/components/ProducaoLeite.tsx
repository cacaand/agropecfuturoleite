import * as React from "react";
import { MilkProductionRecord, UserSettings } from "@/types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Plus, Trash2, TrendingUp, Calendar, Users, Droplets } from "lucide-react";
import { format, startOfWeek, startOfMonth, isSameDay, isAfter, subDays, parseISO } from "date-fns";
import { ptBR } from "date-fns/locale";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import { toast } from "sonner";

interface ProducaoLeiteProps {
  production: MilkProductionRecord[];
  setProduction: React.Dispatch<React.SetStateAction<MilkProductionRecord[]>>;
  settings: UserSettings;
}

export function ProducaoLeite({ production, setProduction, settings }: ProducaoLeiteProps) {
  const [formData, setFormData] = React.useState<Partial<MilkProductionRecord>>({
    data: format(new Date(), 'yyyy-MM-dd'),
    quantidade: 0,
    numVacas: 0,
    tipo: 'Vaca'
  });

  const handleAdd = () => {
    if (!formData.quantidade || formData.quantidade <= 0 || !formData.numVacas || formData.numVacas <= 0) {
      toast.error("Por favor, preencha a quantidade e o número de vacas.");
      return;
    }

    const newRecord: MilkProductionRecord = {
      id: `MLK-${Date.now()}`,
      data: formData.data || format(new Date(), 'yyyy-MM-dd'),
      quantidade: Number(formData.quantidade),
      numVacas: Number(formData.numVacas),
      tipo: (formData.tipo as 'Vaca' | 'Búfala') || 'Vaca',
      observacoes: formData.observacoes
    };

    setProduction(prev => [newRecord, ...prev].sort((a, b) => b.data.localeCompare(a.data)));
    toast.success("Produção registrada com sucesso!");
    setFormData({
      ...formData,
      quantidade: 0,
      observacoes: ""
    });
  };

  const handleDelete = (id: string) => {
    setProduction(prev => prev.filter(p => p.id !== id));
    toast.info("Registro removido.");
  };

  // Calculations
  const today = new Date();
  const sevenDaysAgo = subDays(today, 7);
  const thirtyDaysAgo = subDays(today, 30);

  const filterByDays = (days: number) => {
    const cutoff = subDays(today, days);
    return production.filter(p => isAfter(parseISO(p.data), cutoff) || isSameDay(parseISO(p.data), cutoff));
  };

  const last7Days = filterByDays(7);
  const last30Days = filterByDays(30);

  const calculateStats = (records: MilkProductionRecord[]) => {
    if (records.length === 0) return { total: 0, avgPerDay: 0, avgPerCow: 0 };
    const total = records.reduce((acc, curr) => acc + curr.quantidade, 0);
    const avgPerDay = total / records.length;
    const avgPerCow = records.reduce((acc, curr) => acc + (curr.quantidade / curr.numVacas), 0) / records.length;
    return { total, avgPerDay, avgPerCow };
  };

  const stats7 = calculateStats(last7Days);
  const stats30 = calculateStats(last30Days);

  const chartData = [...production]
    .sort((a, b) => a.data.localeCompare(b.data))
    .slice(-15)
    .map(p => ({
      data: format(parseISO(p.data), 'dd/MM'),
      quantidade: p.quantidade,
      media: (p.quantidade / p.numVacas).toFixed(2),
      tipo: p.tipo
    }));

  return (
    <div className="space-y-8">
      <div className="flex flex-col gap-2">
        <h2 className="text-3xl font-bold tracking-tight text-slate-900">Gestão de Produção de Leite</h2>
        <p className="text-slate-500">Acompanhe a produtividade diária, semanal e mensal do seu rebanho.</p>
      </div>

      <div className="w-full h-48 md:h-64 rounded-2xl overflow-hidden shadow-2xl border-4 border-white relative group">
        <img 
          src="https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?q=80&w=1200&auto=format&fit=crop" 
          alt="Vaca Holandesa" 
          className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-105"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent flex items-end p-6">
          <div className="text-white">
            <Badge className="bg-emerald-500 mb-2">Padrão de Excelência</Badge>
            <h3 className="text-xl font-bold">Rebanho Leiteiro de Alta Produtividade</h3>
          </div>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        <Card className="bg-emerald-50 border-emerald-100">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-emerald-800 flex items-center gap-2">
              <TrendingUp className="w-4 h-4" /> Média Semanal (7 dias)
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-emerald-900">{stats7.avgPerDay.toFixed(1)} L/dia</div>
            <p className="text-xs text-emerald-600 mt-1">
              Média de {stats7.avgPerCow.toFixed(2)} L por vaca
            </p>
          </CardContent>
        </Card>

        <Card className="bg-blue-50 border-blue-100">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-blue-800 flex items-center gap-2">
              <Calendar className="w-4 h-4" /> Média Mensal (30 dias)
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-blue-900">{stats30.avgPerDay.toFixed(1)} L/dia</div>
            <p className="text-xs text-blue-600 mt-1">
              Total no período: {stats30.total.toFixed(0)} Litros
            </p>
          </CardContent>
        </Card>

        <Card className="bg-amber-50 border-amber-100">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-amber-800 flex items-center gap-2">
              <Droplets className="w-4 h-4" /> Valor Estimado (Mês)
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-amber-900">
              R$ {(last30Days.reduce((acc, curr) => {
                const cotacao = curr.tipo === 'Vaca' ? settings.cotacaoLeiteVaca : settings.cotacaoLeiteBufala;
                return acc + (curr.quantidade * cotacao);
              }, 0)).toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
            </div>
            <p className="text-xs text-amber-600 mt-1">
              Baseado nas cotações atuais
            </p>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Novo Registro de Produção</CardTitle>
            <CardDescription>Insira os dados da ordenha do dia.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="data">Data</Label>
                <Input 
                  id="data" 
                  type="date" 
                  value={formData.data} 
                  onChange={e => setFormData({...formData, data: e.target.value})} 
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="tipo">Tipo de Leite</Label>
                <Select value={formData.tipo} onValueChange={v => setFormData({...formData, tipo: v as any})}>
                  <SelectTrigger id="tipo">
                    <SelectValue placeholder="Selecione" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Vaca">Vaca</SelectItem>
                    <SelectItem value="Búfala">Búfala</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="quantidade">Total Litros (Dia)</Label>
                <Input 
                  id="quantidade" 
                  type="number" 
                  placeholder="Ex: 150.5" 
                  value={formData.quantidade || ''} 
                  onChange={e => setFormData({...formData, quantidade: Number(e.target.value)})} 
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="numVacas">Nº Vacas em Lactação</Label>
                <Input 
                  id="numVacas" 
                  type="number" 
                  placeholder="Ex: 25" 
                  value={formData.numVacas || ''} 
                  onChange={e => setFormData({...formData, numVacas: Number(e.target.value)})} 
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="obs">Observações (Opcional)</Label>
              <Input 
                id="obs" 
                placeholder="Ex: Ordenha manual, tempo chuvoso..." 
                value={formData.observacoes || ''} 
                onChange={e => setFormData({...formData, observacoes: e.target.value})} 
              />
            </div>
            <Button onClick={handleAdd} className="w-full bg-emerald-600 hover:bg-emerald-700 gap-2">
              <Plus className="w-4 h-4" /> Registrar Produção
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Evolução da Produção</CardTitle>
            <CardDescription>Últimos 15 registros (Litros Totais)</CardDescription>
          </CardHeader>
          <CardContent className="h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="data" stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} />
                <YAxis stroke="#94a3b8" fontSize={12} tickLine={false} axisLine={false} tickFormatter={(v) => `${v}L`} />
                <Tooltip 
                  contentStyle={{ backgroundColor: '#fff', borderRadius: '8px', border: '1px solid #e2e8f0', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                  labelStyle={{ fontWeight: 'bold', marginBottom: '4px' }}
                />
                <Legend />
                <Line 
                  type="monotone" 
                  dataKey="quantidade" 
                  name="Produção Total" 
                  stroke="#10b981" 
                  strokeWidth={3} 
                  dot={{ r: 4, fill: '#10b981' }} 
                  activeDot={{ r: 6 }} 
                />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Histórico Recente</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Data</TableHead>
                <TableHead>Tipo</TableHead>
                <TableHead>Litros Totais</TableHead>
                <TableHead>Nº Vacas</TableHead>
                <TableHead>Média/Vaca</TableHead>
                <TableHead>Valor Est.</TableHead>
                <TableHead className="text-right">Ações</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {production.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} className="text-center py-8 text-slate-400">
                    Nenhum registro encontrado.
                  </TableCell>
                </TableRow>
              ) : (
                production.slice(0, 10).map((p) => {
                  const cotacao = p.tipo === 'Vaca' ? settings.cotacaoLeiteVaca : settings.cotacaoLeiteBufala;
                  return (
                    <TableRow key={p.id}>
                      <TableCell className="font-medium">
                        {format(parseISO(p.data), 'dd/MM/yyyy', { locale: ptBR })}
                      </TableCell>
                      <TableCell>
                        <Badge variant={p.tipo === 'Vaca' ? 'outline' : 'secondary'} className={p.tipo === 'Vaca' ? 'border-emerald-200 text-emerald-700' : 'bg-slate-100'}>
                          {p.tipo}
                        </Badge>
                      </TableCell>
                      <TableCell>{p.quantidade.toFixed(1)} L</TableCell>
                      <TableCell>{p.numVacas}</TableCell>
                      <TableCell className="font-bold text-emerald-600">
                        {(p.quantidade / p.numVacas).toFixed(2)} L
                      </TableCell>
                      <TableCell>
                        R$ {(p.quantidade * cotacao).toFixed(2)}
                      </TableCell>
                      <TableCell className="text-right">
                        <Button 
                          variant="ghost" 
                          size="icon" 
                          onClick={() => handleDelete(p.id)}
                          className="text-slate-400 hover:text-red-500"
                        >
                          <Trash2 className="w-4 h-4" />
                        </Button>
                      </TableCell>
                    </TableRow>
                  );
                })
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
