import * as React from "react";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend, Cell } from "recharts";
import { TrendingUp, TrendingDown, History, DollarSign, Edit, PieChart as PieIcon, FileText } from "lucide-react";
import { Animal } from "@/types";
import { Button } from "@/components/ui/button";
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from "@/components/ui/table";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

import { cn } from "@/lib/utils";

interface HistoricoProps {
  animals: Animal[];
  onEdit?: (animal: Animal) => void;
  onViewProfile?: (animal: Animal) => void;
}

export function Historico({ animals, onEdit, onViewProfile }: HistoricoProps) {
  const vendidos = animals.filter(a => a.status === 'Vendido');
  const mortos = animals.filter(a => a.status === 'Morto');
  
  const totalVendas = vendidos.reduce((acc, a) => acc + (a.venda?.preco || 0), 0);
  const totalLucro = vendidos.reduce((acc, a) => acc + (a.venda?.lucro || 0), 0);
  const totalLucroCDI = vendidos.reduce((acc, a) => acc + (a.venda?.lucroCDI || 0), 0);
  
  const totalPrejuizoMorte = mortos.reduce((acc, a) => {
    const entryDate = new Date(a.dataEntrada);
    const today = new Date();
    const diffDays = Math.ceil(Math.abs(today.getTime() - entryDate.getTime()) / (1000 * 60 * 60 * 24)) || 1;
    const custoFinanciamento = a.precoCompra * ((a.taxaJurosAnual || 0) / 100) * (diffDays / 365);
    const invest = a.precoCompra + custoFinanciamento + a.despesas.reduce((dAcc, d) => dAcc + d.valor, 0);
    return acc + invest;
  }, 0);

  const resultadoFinal = totalLucro - totalPrejuizoMorte;

  const chartData = [
    { name: 'Lucro Gado', valor: totalLucro, color: '#10b981' },
    { name: 'Lucro CDI', valor: totalLucroCDI, color: '#6366f1' }
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-1">
        <h2 className="text-2xl font-bold tracking-tight text-slate-900">Histórico / Lucro</h2>
        <p className="text-slate-500">Acompanhe o desempenho das vendas e o balanço final comparado ao CDI.</p>
      </div>

      <div className="grid gap-4 md:grid-cols-4">
        <Card className="border-none shadow-sm bg-white">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-slate-500">Total em Vendas</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-blue-600">
              R$ {totalVendas.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
            </div>
          </CardContent>
        </Card>

        <Card className="border-none shadow-sm bg-white">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-slate-500">Lucro Real (Gado)</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-emerald-600">
              R$ {totalLucro.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
            </div>
          </CardContent>
        </Card>

        <Card className="border-none shadow-sm bg-white">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-slate-500">Lucro Potencial (CDI)</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-indigo-600">
              R$ {totalLucroCDI.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
            </div>
          </CardContent>
        </Card>

        <Card className="border-none shadow-sm bg-white">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-slate-500">Resultado Final</CardTitle>
          </CardHeader>
          <CardContent>
            <div className={cn(
              "text-2xl font-bold",
              resultadoFinal >= 0 ? "text-emerald-600" : "text-red-600"
            )}>
              R$ {resultadoFinal.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
            </div>
            <p className="text-xs text-slate-400 mt-1">Considerando mortes e custos</p>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-6 md:grid-cols-3">
        <Card className="md:col-span-2 border-none shadow-sm bg-white">
          <CardHeader>
            <CardTitle className="text-lg font-semibold flex items-center gap-2">
              <PieIcon className="w-5 h-5 text-blue-500" />
              Comparativo: Lucro Gado vs CDI
            </CardTitle>
          </CardHeader>
          <CardContent className="h-[300px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={chartData} margin={{ top: 20, right: 30, left: 20, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: '#64748b', fontSize: 12 }} />
                <YAxis axisLine={false} tickLine={false} tick={{ fill: '#64748b', fontSize: 12 }} tickFormatter={(v) => `R$ ${v}`} />
                <Tooltip 
                  cursor={{ fill: '#f8fafc' }}
                  contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                />
                <Bar dataKey="valor" radius={[4, 4, 0, 0]}>
                  {chartData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card className="border-none shadow-sm bg-white">
          <CardHeader>
            <CardTitle className="text-lg font-semibold">Análise de Performance</CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="p-4 rounded-xl bg-slate-50 border border-slate-100">
              <p className="text-xs text-slate-500 uppercase font-bold mb-1">Diferença vs CDI</p>
              <p className={cn(
                "text-2xl font-bold",
                totalLucro > totalLucroCDI ? "text-emerald-600" : "text-amber-600"
              )}>
                {totalLucro > totalLucroCDI ? '+' : ''} R$ {(totalLucro - totalLucroCDI).toLocaleString('pt-BR')}
              </p>
              <p className="text-[10px] text-slate-400 mt-1">
                {totalLucro > totalLucroCDI 
                  ? "A criação de gado superou o rendimento do CDI." 
                  : "O CDI teria rendido mais que a criação de gado."}
              </p>
            </div>
            
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-slate-500">Eficiência vs CDI</span>
                <span className="font-bold">
                  {totalLucroCDI > 0 ? ((totalLucro / totalLucroCDI) * 100).toFixed(1) : 0}%
                </span>
              </div>
              <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                <div 
                  className={cn("h-full", totalLucro > totalLucroCDI ? "bg-emerald-500" : "bg-amber-500")} 
                  style={{ width: `${Math.min(100, (totalLucro / (totalLucroCDI || 1)) * 100)}%` }} 
                />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
        <Table>
          <TableHeader className="bg-slate-50">
            <TableRow>
              <TableHead className="font-semibold text-slate-700">Brinco</TableHead>
              <TableHead className="font-semibold text-slate-700">Status</TableHead>
              <TableHead className="font-semibold text-slate-700">Lucro Líquido</TableHead>
              <TableHead className="font-semibold text-slate-700">Lucro CDI</TableHead>
              <TableHead className="font-semibold text-slate-700">Financ.</TableHead>
              <TableHead className="font-semibold text-slate-700">Data</TableHead>
              <TableHead className="text-right font-semibold text-slate-700">Ações</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {[...vendidos, ...mortos].length === 0 ? (
              <TableRow>
                <TableCell colSpan={7} className="h-32 text-center text-slate-500">
                  Nenhum registro no histórico.
                </TableCell>
              </TableRow>
            ) : (
              [...vendidos, ...mortos]
                .sort((a, b) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime())
                .map((animal) => {
                  const entryDate = new Date(animal.dataEntrada);
                  const endDate = animal.venda ? new Date(animal.venda.data) : new Date();
                  const diffDays = Math.ceil(Math.abs(endDate.getTime() - entryDate.getTime()) / (1000 * 60 * 60 * 24)) || 1;
                  const custoFinanciamento = animal.venda?.custoFinanciamento || (animal.precoCompra * ((animal.taxaJurosAnual || 0) / 100) * (diffDays / 365));
                  const totalInvested = animal.precoCompra + custoFinanciamento + animal.despesas.reduce((acc, d) => acc + d.valor, 0);

                  return (
                    <TableRow key={animal.id} className="hover:bg-slate-50/50 transition-colors">
                      <TableCell className="font-bold text-slate-900">{animal.id}</TableCell>
                      <TableCell>
                        <Badge variant={animal.status === 'Vendido' ? 'default' : 'destructive'} className={cn(
                          "font-medium",
                          animal.status === 'Vendido' ? "bg-emerald-100 text-emerald-700 hover:bg-emerald-100" : "bg-red-100 text-red-700 hover:bg-red-100"
                        )}>
                          {animal.status}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        {animal.status === 'Vendido' ? (
                          <span className={animal.venda!.lucro >= 0 ? "text-emerald-600 font-medium text-xs" : "text-red-600 font-medium text-xs"}>
                            R$ {animal.venda?.lucro.toLocaleString('pt-BR')}
                          </span>
                        ) : (
                          <span className="text-red-600 font-medium text-xs">
                            - R$ {totalInvested.toLocaleString('pt-BR')}
                          </span>
                        )}
                      </TableCell>
                      <TableCell className="text-indigo-600 text-xs font-medium">
                        {animal.status === 'Vendido' ? `R$ ${animal.venda?.lucroCDI?.toLocaleString('pt-BR')}` : '---'}
                      </TableCell>
                      <TableCell className="text-red-500 text-xs">
                        {custoFinanciamento > 0 ? `R$ ${custoFinanciamento.toLocaleString('pt-BR')}` : '---'}
                      </TableCell>
                      <TableCell className="text-slate-500 text-xs">
                        {new Date(animal.updatedAt).toLocaleDateString('pt-BR')}
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-1">
                          <Button variant="ghost" size="icon" onClick={() => onViewProfile?.(animal)} title="Ver Histórico / Imprimir">
                            <FileText className="w-4 h-4 text-slate-400" />
                          </Button>
                          <Button variant="ghost" size="icon" onClick={() => onEdit?.(animal)}>
                            <Edit className="w-4 h-4 text-slate-400" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  );
                })
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
