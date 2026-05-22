import * as React from "react";
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
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { Scale, TrendingUp, DollarSign, Activity, Syringe, Beef } from "lucide-react";
import { Animal } from "@/types";

interface EngordaProps {
  animals: Animal[];
  onAddWeight: (animal: Animal) => void;
}

export function Engorda({ animals, onAddWeight }: EngordaProps) {
  const activeAnimals = animals.filter(a => a.status === 'Ativo');

  return (
    <div className="space-y-6 relative min-h-[80vh] p-6 rounded-2xl overflow-hidden print:overflow-visible">
      {/* Background Image */}
      <div 
        className="absolute inset-0 z-0 opacity-30 pointer-events-none"
        style={{ 
          backgroundImage: 'url("https://images.unsplash.com/photo-1500595046743-cd271d694d30?q=80&w=2070&auto=format&fit=crop")',
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          filter: 'brightness(0.3)'
        }}
      />

      <div className="relative z-10 space-y-6">
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
          <div className="flex flex-col gap-1">
            <h2 className="text-2xl font-bold tracking-tight text-slate-900">Gestão de Engorda e Custos Individuais</h2>
            <p className="text-slate-500">Análise detalhada de ganho de peso e composição de custos por animal.</p>
          </div>
          <Button 
            onClick={() => activeAnimals.length > 0 && onAddWeight(activeAnimals[0])} 
            className="bg-emerald-600 hover:bg-emerald-700 text-white gap-2 shadow-lg shadow-emerald-500/20"
          >
            <Scale className="w-4 h-4" />
            Nova Pesagem
          </Button>
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
          <Table>
            <TableHeader className="bg-slate-50/50">
              <TableRow>
                <TableHead className="font-semibold text-slate-700">Brinco</TableHead>
                <TableHead className="font-semibold text-slate-700">Ganho (@)</TableHead>
                <TableHead className="font-semibold text-slate-700">GMD (kg)</TableHead>
                <TableHead className="font-semibold text-slate-700">Custo Compra</TableHead>
                <TableHead className="font-semibold text-slate-700">Custo Ração</TableHead>
                <TableHead className="font-semibold text-slate-700">Custo Saúde</TableHead>
                <TableHead className="font-semibold text-slate-700">Custo Engorda</TableHead>
                <TableHead className="font-semibold text-slate-700">Custo Total</TableHead>
                <TableHead className="font-semibold text-slate-700">Custo/@</TableHead>
                <TableHead className="text-right font-semibold text-slate-700">Ações</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {activeAnimals.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={9} className="h-32 text-center text-slate-500">
                    Nenhum animal ativo para análise.
                  </TableCell>
                </TableRow>
              ) : (
                activeAnimals.map((animal) => {
                  const initialWeight = animal.historicoPesos[0]?.peso || 0;
                  const currentWeight = animal.historicoPesos[animal.historicoPesos.length - 1]?.peso || 0;
                  const weightGain = currentWeight - initialWeight;

                  const entryDate = new Date(animal.dataEntrada);
                  const today = new Date();
                  const diffDays = Math.ceil(Math.abs(today.getTime() - entryDate.getTime()) / (1000 * 60 * 60 * 24)) || 1;
                  const custoFinanciamento = animal.precoCompra * ((animal.taxaJurosAnual || 0) / 100) * (diffDays / 365);

                  const racaoCosts = animal.despesas
                    .filter(d => d.tipo.toLowerCase().includes('ração'))
                    .reduce((acc, d) => acc + d.valor, 0);
                  
                  const saudeCosts = animal.despesas
                    .filter(d => 
                      d.tipo.toLowerCase().includes('vacina') || 
                      d.tipo.toLowerCase().includes('medicamento') ||
                      d.tipo.toLowerCase().includes('remedio') ||
                      d.tipo.toLowerCase().includes('veterinário')
                    )
                    .reduce((acc, d) => acc + d.valor, 0);
                  
                  const otherCosts = animal.despesas
                    .filter(d => 
                      !d.tipo.toLowerCase().includes('ração') && 
                      !d.tipo.toLowerCase().includes('vacina') && 
                      !d.tipo.toLowerCase().includes('medicamento') &&
                      !d.tipo.toLowerCase().includes('remedio') &&
                      !d.tipo.toLowerCase().includes('veterinário')
                    )
                    .reduce((acc, d) => acc + d.valor, 0);

                  const custoEngorda = racaoCosts + saudeCosts + otherCosts;
                  const totalInvested = animal.precoCompra + custoFinanciamento + custoEngorda;
                  const costPerArroba = currentWeight > 0 ? totalInvested / currentWeight : 0;
                  
                  // ROI on Feed: (Weight Gain * Market Price) / Feed Cost
                  const marketPrice = animal.raca === 'Búfalo' ? 245 : 285.5; // Use state prices if available, but here we use constants for simplicity or pass them
                  const gainValue = weightGain * marketPrice;
                  const feedRoi = racaoCosts > 0 ? (gainValue / racaoCosts) : 0;

                  return (
                    <TableRow key={animal.id} className="hover:bg-slate-50/50 transition-colors">
                      <TableCell className="font-bold text-slate-900">{animal.id}</TableCell>
                      <TableCell>
                        <div className="flex flex-col">
                          <div className="flex items-center gap-1 text-emerald-600 font-medium">
                            <TrendingUp className="w-3 h-3" />
                            +{weightGain.toFixed(1)}
                          </div>
                          <span className="text-[10px] text-slate-400">{currentWeight}@</span>
                          {(() => {
                            const currentKg = currentWeight * 30;
                            if (animal.sexo === 'Fêmea' && currentKg >= 280 && currentKg <= 320) {
                              return <Badge className="mt-1 bg-purple-100 text-purple-700 hover:bg-purple-100 border-none text-[8px] h-4 px-1">Prenhez</Badge>;
                            }
                            if (animal.tipoEntrada === 'Cria' && currentKg >= 180 && currentKg <= 250) {
                              return <Badge className="mt-1 bg-amber-100 text-amber-700 hover:bg-amber-100 border-none text-[8px] h-4 px-1">Desmama</Badge>;
                            }
                            return null;
                          })()}
                        </div>
                      </TableCell>
                      <TableCell>
                        {(() => {
                          const gmd = (weightGain * 30) / diffDays;
                          return (
                            <div className="flex flex-col">
                              <span className={cn("font-bold text-xs", gmd > 0.7 ? "text-emerald-600" : "text-amber-600")}>
                                {gmd.toFixed(3)}
                              </span>
                              <span className="text-[9px] text-slate-400">kg/dia</span>
                            </div>
                          );
                        })()}
                      </TableCell>
                      <TableCell>
                        <div className="flex flex-col">
                          <span className="text-slate-900 font-medium text-xs">R$ {animal.precoCompra.toLocaleString('pt-BR')}</span>
                          {custoFinanciamento > 0 ? (
                            <span className="text-[10px] text-red-500 font-medium">+ R$ {custoFinanciamento.toLocaleString('pt-BR')} (Juros)</span>
                          ) : null}
                          <span className="text-[9px] text-slate-400 uppercase">{animal.formaPagamento} | {animal.origemCapital}</span>
                        </div>
                      </TableCell>
                      <TableCell>
                        <div className="flex flex-col">
                          <span className="text-slate-600 text-xs">R$ {racaoCosts.toLocaleString('pt-BR')}</span>
                          {racaoCosts > 0 && (
                            <span className={cn("text-[9px] font-bold", feedRoi > 1 ? "text-emerald-600" : "text-amber-600")}>
                              ROI: {feedRoi.toFixed(2)}x
                            </span>
                          )}
                        </div>
                      </TableCell>
                      <TableCell className="text-slate-600 text-xs">R$ {saudeCosts.toLocaleString('pt-BR')}</TableCell>
                      <TableCell className="text-emerald-700 font-medium text-xs">R$ {custoEngorda.toLocaleString('pt-BR')}</TableCell>
                      <TableCell className="font-bold text-slate-900 text-xs">R$ {totalInvested.toLocaleString('pt-BR')}</TableCell>
                      <TableCell>
                        <Badge variant="outline" className="bg-blue-50 text-blue-700 border-blue-100 text-[10px]">
                          R$ {costPerArroba.toLocaleString('pt-BR', { maximumFractionDigits: 2 })}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <Button 
                          variant="outline" 
                          size="sm" 
                          className="h-8 text-emerald-600 border-emerald-200 hover:bg-emerald-50 gap-1"
                          onClick={() => onAddWeight(animal)}
                        >
                          <Scale className="h-3.5 w-3.5" />
                          Pesar
                        </Button>
                      </TableCell>
                    </TableRow>
                  );
                })
              )}
            </TableBody>
          </Table>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        <Card className="border-none shadow-sm bg-white">
          <CardHeader>
            <CardTitle className="text-lg font-semibold flex items-center gap-2">
              <Beef className="w-5 h-5 text-orange-500" />
              Composição de Custos (Média por Cabeça)
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {activeAnimals.length > 0 && (() => {
              const count = activeAnimals.length;
              const avgCompra = activeAnimals.reduce((acc, a) => {
                const entryDate = new Date(a.dataEntrada);
                const today = new Date();
                const diffDays = Math.ceil(Math.abs(today.getTime() - entryDate.getTime()) / (1000 * 60 * 60 * 24)) || 1;
                const custoFinanciamento = a.precoCompra * ((a.taxaJurosAnual || 0) / 100) * (diffDays / 365);
                return acc + a.precoCompra + custoFinanciamento;
              }, 0) / count;
              const avgRacao = activeAnimals.reduce((acc, a) => acc + a.despesas.filter(d => d.tipo.toLowerCase().includes('ração')).reduce((s, d) => s + d.valor, 0), 0) / count;
              const avgSaude = activeAnimals.reduce((acc, a) => acc + a.despesas.filter(d => d.tipo.toLowerCase().includes('vacina') || d.tipo.toLowerCase().includes('medicamento')).reduce((s, d) => s + d.valor, 0), 0) / count;
              const total = avgCompra + avgRacao + avgSaude;

              return (
                <div className="space-y-3">
                  <div className="space-y-1">
                    <div className="flex justify-between text-xs font-medium">
                      <span>Compra</span>
                      <span>{((avgCompra/total)*100).toFixed(1)}%</span>
                    </div>
                    <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                      <div className="bg-slate-400 h-full" style={{ width: `${(avgCompra/total)*100}%` }} />
                    </div>
                  </div>
                  <div className="space-y-1">
                    <div className="flex justify-between text-xs font-medium">
                      <span>Ração / Nutrição</span>
                      <span>{((avgRacao/total)*100).toFixed(1)}%</span>
                    </div>
                    <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                      <div className="bg-emerald-500 h-full" style={{ width: `${(avgRacao/total)*100}%` }} />
                    </div>
                  </div>
                  <div className="space-y-1">
                    <div className="flex justify-between text-xs font-medium">
                      <span>Saúde / Medicamentos</span>
                      <span>{((avgSaude/total)*100).toFixed(1)}%</span>
                    </div>
                    <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                      <div className="bg-blue-500 h-full" style={{ width: `${(avgSaude/total)*100}%` }} />
                    </div>
                  </div>
                </div>
              );
            })()}
          </CardContent>
        </Card>

        <Card className="border-none shadow-sm bg-white">
          <CardHeader>
            <CardTitle className="text-lg font-semibold flex items-center gap-2">
              <Activity className="w-5 h-5 text-emerald-500" />
              Eficiência de Engorda
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {(() => {
                let totalGmd = 0;
                let bestAnimal = { id: '---', gmd: 0 };
                let totalCostPerArroba = 0;
                let count = activeAnimals.length;

                activeAnimals.forEach(a => {
                  const initialWeight = a.historicoPesos[0]?.peso || 0;
                  const currentWeight = a.historicoPesos[a.historicoPesos.length - 1]?.peso || 0;
                  const weightGain = currentWeight - initialWeight;
                  const entryDate = new Date(a.dataEntrada);
                  const today = new Date();
                  const diffDays = Math.ceil(Math.abs(today.getTime() - entryDate.getTime()) / (1000 * 60 * 60 * 24)) || 1;
                  const gmd = (weightGain * 30) / diffDays;
                  
                  totalGmd += gmd;
                  if (gmd > bestAnimal.gmd) {
                    bestAnimal = { id: a.id, gmd };
                  }

                  const custoFinanciamento = a.precoCompra * ((a.taxaJurosAnual || 0) / 100) * (diffDays / 365);

                  const totalInvested = a.precoCompra + custoFinanciamento + a.despesas.reduce((acc, d) => acc + d.valor, 0);
                  totalCostPerArroba += currentWeight > 0 ? totalInvested / currentWeight : 0;
                });

                const avgGmd = count > 0 ? totalGmd / count : 0;
                const avgCostPerArroba = count > 0 ? totalCostPerArroba / count : 0;

                return (
                  <>
                    <div className="p-4 bg-emerald-50 rounded-xl border border-emerald-100">
                      <p className="text-xs text-emerald-700 font-medium uppercase tracking-wider">GMD Médio do Rebanho</p>
                      <p className="text-2xl font-bold text-emerald-900">{avgGmd.toFixed(3)} kg/dia</p>
                      <p className="text-[10px] text-emerald-600 mt-1">*Baseado em todo o período de engorda</p>
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="p-3 bg-slate-50 rounded-lg border border-slate-100">
                        <p className="text-[10px] text-slate-500 uppercase">Melhor Desempenho</p>
                        <p className="text-sm font-bold">Brinco #{bestAnimal.id}</p>
                        <p className="text-[9px] text-emerald-600">{bestAnimal.gmd.toFixed(3)} kg/dia</p>
                      </div>
                      <div className="p-3 bg-slate-50 rounded-lg border border-slate-100">
                        <p className="text-[10px] text-slate-500 uppercase">Custo Médio/@</p>
                        <p className="text-sm font-bold">R$ {avgCostPerArroba.toLocaleString('pt-BR', { maximumFractionDigits: 2 })}</p>
                        <p className="text-[9px] text-slate-400">Investimento total / @ atual</p>
                      </div>
                    </div>
                  </>
                );
              })()}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
