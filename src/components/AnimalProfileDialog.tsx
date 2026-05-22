import * as React from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { ScrollArea } from "@/components/ui/scroll-area";
import { 
  Printer, 
  Syringe, 
  Scale, 
  Baby, 
  Stethoscope, 
  TrendingUp, 
  DollarSign, 
  Calendar,
  FileText
} from "lucide-react";
import { Animal, UserSettings } from "@/types";
import { cn } from "@/lib/utils";

interface AnimalProfileDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  animal: Animal | null;
  settings?: UserSettings;
}

export function AnimalProfileDialog({ open, onOpenChange, animal, settings }: AnimalProfileDialogProps) {
  if (!animal) return null;

  const totalExpenses = animal.despesas.reduce((acc, d) => acc + d.valor, 0);
  
  // Dynamic interest calculation
  const entryDate = new Date(animal.dataEntrada);
  const endDate = animal.status === 'Vendido' && animal.venda ? new Date(animal.venda.data) : new Date();
  const diffDays = Math.ceil(Math.abs(endDate.getTime() - entryDate.getTime()) / (1000 * 60 * 60 * 24)) || 1;
  const custoFinanciamento = animal.precoCompra * ((animal.taxaJurosAnual || 0) / 100) * (diffDays / 365);
  
  const totalInvestment = animal.precoCompra + totalExpenses + custoFinanciamento;

  const handlePrint = () => {
    window.print();
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-4xl max-h-[90vh] flex flex-col p-0 overflow-hidden print:max-h-none print:overflow-visible">
        {/* Header - Not printed by CSS usually, but let's make it clean */}
        <div className="p-6 bg-slate-900 text-white flex justify-between items-center print:bg-white print:text-black print:border-b">
          <div>
            <div className="flex items-center gap-3">
              <h2 className="text-3xl font-bold tracking-tighter">Animal #{animal.id}</h2>
              <Badge className={cn(
                "uppercase font-bold pt-1",
                animal.status === 'Ativo' ? "bg-emerald-500" : animal.status === 'Morto' ? "bg-red-500" : "bg-blue-500"
              )}>
                {animal.status}
              </Badge>
            </div>
            <p className="text-slate-400 text-sm print:text-slate-600">Documento de Controle Sanitário e Histórico Individual</p>
          </div>
          <Button onClick={handlePrint} variant="outline" className="gap-2 bg-white/10 border-white/20 hover:bg-white/20 print:hidden">
            <Printer className="w-4 h-4" /> Imprimir Passaporte
          </Button>
        </div>

        <ScrollArea className="flex-1 p-6 print:overflow-visible">
          {/* Printable Content Area */}
          <div id="animal-passport" className="space-y-8 print:block">
            {/* Professional Print Header */}
            <div className="hidden print:flex justify-between items-start border-b-2 border-slate-900 pb-4 mb-8">
              <div className="space-y-1">
                <h1 className="text-2xl font-black tracking-tighter uppercase">AgropecFuturo</h1>
                <p className="text-[10px] text-slate-500 font-bold uppercase tracking-widest">Sistema de Gestão Pecuária Inteligente</p>
              </div>
              <div className="text-right space-y-1">
                <p className="text-sm font-bold uppercase">{settings?.nomePropriedade || 'PROPRIEDADE NÃO INFORMADA'}</p>
                <div className="text-[10px] text-slate-600 flex flex-col">
                  <span>Produtor: {settings?.nomeUsuario || '---'}</span>
                  <span>Cartão: {settings?.cartaoProdutor || '---'} | IMA: {settings?.registroIMA || '---'}</span>
                </div>
              </div>
            </div>

            {/* Quick Stats Grid */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div className="bg-slate-50 p-4 rounded-xl border border-slate-100 flex flex-col gap-1">
                <span className="text-[10px] text-slate-500 font-bold uppercase tracking-wider">Raça / Sexo</span>
                <span className="text-lg font-bold text-slate-900">{animal.raca || 'Nelore'} / {animal.sexo}</span>
              </div>
              <div className="bg-slate-50 p-4 rounded-xl border border-slate-100 flex flex-col gap-1">
                <span className="text-[10px] text-slate-500 font-bold uppercase tracking-wider">Data de Entrada</span>
                <span className="text-lg font-bold text-slate-900">{new Date(animal.dataEntrada).toLocaleDateString('pt-BR')}</span>
              </div>
              <div className="bg-slate-50 p-4 rounded-xl border border-slate-100 flex flex-col gap-1">
                <span className="text-[10px] text-slate-500 font-bold uppercase tracking-wider">Peso Atual</span>
                <span className="text-lg font-bold text-slate-900">
                  {animal.historicoPesos[animal.historicoPesos.length - 1]?.peso || 0} @
                </span>
              </div>
              <div className="bg-slate-50 p-4 rounded-xl border border-slate-100 flex flex-col gap-1">
                <span className="text-[10px] text-slate-500 font-bold uppercase tracking-wider">Investimento Total</span>
                <span className="text-lg font-bold text-emerald-600">R$ {totalInvestment.toLocaleString('pt-BR')}</span>
              </div>
            </div>

            {/* Main History Sections */}
            <div className="grid md:grid-cols-2 gap-8">
              {/* Vaccines Section */}
              <div className="space-y-4">
                <div className="flex items-center gap-2 border-b pb-2">
                  <Syringe className="w-5 h-5 text-pink-500" />
                  <h3 className="font-bold text-slate-900 uppercase tracking-tight">Registro de Vacinação</h3>
                </div>
                <div className="space-y-2">
                  {animal.vacinas.length > 0 ? (
                    animal.vacinas.map((v, i) => (
                      <div key={i} className="flex justify-between items-center p-3 bg-white border rounded-lg shadow-sm">
                        <span className="font-medium text-sm text-slate-800">{v.tipo}</span>
                        <div className="flex items-center gap-2 text-xs text-slate-500">
                          <Calendar className="w-3 h-3" />
                          {new Date(v.data).toLocaleDateString('pt-BR')}
                        </div>
                      </div>
                    ))
                  ) : (
                    <p className="text-sm text-slate-400 italic">Nenhuma vacina registrada.</p>
                  )}
                </div>
              </div>

              {/* Weight Growth Section */}
              <div className="space-y-4">
                <div className="flex items-center gap-2 border-b pb-2">
                  <TrendingUp className="w-5 h-5 text-blue-500" />
                  <h3 className="font-bold text-slate-900 uppercase tracking-tight">Evolução de Peso</h3>
                </div>
                <div className="space-y-2">
                  {animal.historicoPesos.length > 0 ? (
                    animal.historicoPesos.map((p, i) => (
                      <div key={i} className="flex justify-between items-center p-3 bg-white border rounded-lg shadow-sm">
                        <span className="font-bold text-sm text-slate-900">{p.peso} @</span>
                        <div className="flex items-center gap-2 text-xs text-slate-500">
                          <Calendar className="w-3 h-3" />
                          {new Date(p.data).toLocaleDateString('pt-BR')}
                        </div>
                      </div>
                    ))
                  ) : (
                    <p className="text-sm text-slate-400 italic">Nenhuma pesagem registrada.</p>
                  )}
                </div>
              </div>

              {/* Reproduction Section */}
              <div className="space-y-4">
                <div className="flex items-center gap-2 border-b pb-2">
                  <Baby className="w-5 h-5 text-amber-500" />
                  <h3 className="font-bold text-slate-900 uppercase tracking-tight">Histórico Reprodutivo</h3>
                </div>
                <div className="p-4 bg-amber-50 rounded-xl border border-amber-100 flex items-center justify-between">
                  <span className="text-sm font-medium text-amber-900">Total de Partos</span>
                  <Badge className="bg-amber-500 text-white border-none">{animal.partos}</Badge>
                </div>
              </div>

              {/* Health Events Section */}
              <div className="space-y-4">
                <div className="flex items-center gap-2 border-b pb-2">
                  <Stethoscope className="w-5 h-5 text-emerald-500" />
                  <h3 className="font-bold text-slate-900 uppercase tracking-tight">Ocorrências de Saúde</h3>
                </div>
                <div className="space-y-2">
                  {(animal.ocorrenciasSaude && animal.ocorrenciasSaude.length > 0) ? (
                    animal.ocorrenciasSaude.map((o, i) => (
                      <div key={i} className="p-3 bg-white border rounded-lg shadow-sm space-y-1">
                        <div className="flex justify-between">
                          <span className="font-bold text-sm text-emerald-700">{o.tipo}</span>
                          <span className="text-[10px] text-slate-400">{new Date(o.data).toLocaleDateString('pt-BR')}</span>
                        </div>
                        <p className="text-xs text-slate-600"><b>Diag:</b> {o.diagnostico}</p>
                        <p className="text-xs text-slate-600"><b>Trat:</b> {o.tratamento}</p>
                      </div>
                    ))
                  ) : (
                    <p className="text-sm text-slate-400 italic">Nenhuma ocorrência registrada.</p>
                  )}
                  {animal.status === 'Morto' && (
                    <div className="p-3 bg-red-50 border border-red-100 rounded-lg flex items-center gap-3">
                      <Skull className="w-5 h-5 text-red-500" />
                      <div>
                        <p className="text-xs font-bold text-red-700">ÓBITO REGISTRADO</p>
                        <p className="text-[10px] text-red-600 uppercase">Motivo: {animal.motivoMorte}</p>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </div>

            {/* Financial Summary Section */}
            <div className="space-y-4">
              <div className="flex items-center gap-2 border-b pb-2">
                <DollarSign className="w-5 h-5 text-emerald-600" />
                <h3 className="font-bold text-slate-900 uppercase tracking-tight">Resumo de Perda e Lucro</h3>
              </div>
              <div className="grid md:grid-cols-2 gap-4">
                <div className="p-4 bg-slate-50 rounded-xl border border-slate-100 space-y-2">
                  <div className="flex justify-between text-sm">
                    <span className="text-slate-500">Preço de Compra:</span>
                    <span className="font-medium">R$ {animal.precoCompra.toLocaleString('pt-BR')}</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-slate-500">Custos Médicos/Alimentares:</span>
                    <span className="font-medium text-orange-600">+ R$ {totalExpenses.toLocaleString('pt-BR')}</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-slate-500">Custo Financiamento:</span>
                    <span className="font-medium text-orange-600">+ R$ {custoFinanciamento.toLocaleString('pt-BR')}</span>
                  </div>
                  <div className="border-t pt-2 flex justify-between font-bold text-lg">
                    <span>Investimento Acumulado:</span>
                    <span className="text-slate-900">R$ {totalInvestment.toLocaleString('pt-BR')}</span>
                  </div>
                </div>
                
                {animal.status === 'Vendido' && animal.venda && (
                  <div className="p-4 bg-emerald-50 rounded-xl border border-emerald-100 space-y-2">
                    <div className="flex justify-between text-sm">
                      <span className="text-emerald-700">Preço de Venda:</span>
                      <span className="font-bold text-xl">R$ {animal.venda.preco.toLocaleString('pt-BR')}</span>
                    </div>
                    <div className="flex justify-between text-sm border-t pt-2">
                      <span className="font-medium text-emerald-800">Resultado Final:</span>
                      <Badge className={cn(
                        "text-lg font-bold px-3 py-1",
                        animal.venda.lucro >= 0 ? "bg-emerald-600" : "bg-red-600"
                      )}>
                        {animal.venda.lucro >= 0 ? 'LUCRO' : 'PREJUÍZO'} R$ {Math.abs(animal.venda.lucro).toLocaleString('pt-BR')}
                      </Badge>
                    </div>
                  </div>
                )}

                {animal.status === 'Morto' && (
                  <div className="p-4 bg-red-50 rounded-xl border border-red-100 flex items-center justify-between">
                    <span className="font-bold text-red-800 uppercase tracking-tighter">Prejuízo Total Devido ao Óbito:</span>
                    <span className="text-2xl font-black text-red-600">- R$ {totalInvestment.toLocaleString('pt-BR')}</span>
                  </div>
                )}
              </div>
            </div>

            {/* Signature Area for Printing */}
            <div className="hidden print:block pt-12 space-y-12">
              <div className="flex justify-between gap-12">
                <div className="flex-1 border-t border-black pt-2 text-center text-xs">
                  Assinatura do Produtor / Responsável
                </div>
                <div className="flex-1 border-t border-black pt-2 text-center text-xs">
                  Vigilância Sanitária / Orgão de Controle
                </div>
              </div>
              <p className="text-[10px] text-center text-slate-400">
                Documento gerado pelo sistema AgropecFuturo em {new Date().toLocaleString('pt-BR')}
              </p>
            </div>
          </div>
        </ScrollArea>
        
        <DialogFooter className="p-6 bg-slate-50 print:hidden">
          <Button variant="ghost" onClick={() => onOpenChange(false)}>Fechar Perfil</Button>
          <Button onClick={handlePrint} className="bg-slate-900 hover:bg-slate-800 gap-2">
            <Printer className="w-4 h-4" /> Imprimir Documentação
          </Button>
        </DialogFooter>
      </DialogContent>

      <style dangerouslySetInnerHTML={{ __html: `
        @media print {
          body * {
            visibility: hidden;
            background: none !important;
          }
          #animal-passport, #animal-passport * {
            visibility: visible;
          }
          #animal-passport {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            height: auto !important;
            overflow: visible !important;
          }
          /* Ensure dialog and its parents don't clip */
          [role="dialog"], [data-state="open"] {
            overflow: visible !important;
            position: static !important;
          }
        }
      `}} />
    </Dialog>
  );
}

function Skull(props: any) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <circle cx="9" cy="12" r="1" />
      <circle cx="15" cy="12" r="1" />
      <path d="M8 20v2h8v-2" />
      <path d="m12.5 17-.5-1-.5 1h1z" />
      <path d="M16 20a2 2 0 0 0 2-2 8 8 0 1 0-12 0 2 2 0 0 0 2 2h8z" />
    </svg>
  )
}
