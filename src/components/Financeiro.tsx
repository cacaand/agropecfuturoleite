import * as React from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from "@/components/ui/select";
import { Animal } from "@/types";
import { toast } from "sonner";
import { DollarSign, Users, User, Edit } from "lucide-react";

interface FinanceiroProps {
  animals: Animal[];
  onAddExpense: (expense: { tipo: string, valor: number, modo: 'Coletiva' | 'Individual', animalId?: string }) => void;
  onEditAnimal?: (animal: Animal) => void;
}

export function Financeiro({ animals, onAddExpense, onEditAnimal }: FinanceiroProps) {
  const [tipo, setTipo] = React.useState("Ração");
  const [valor, setValor] = React.useState("");
  const [modo, setModo] = React.useState<'Coletiva' | 'Individual'>("Coletiva");
  const [selectedAnimalId, setSelectedAnimalId] = React.useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const val = parseFloat(valor);
    if (isNaN(val) || val <= 0) {
      toast.error("Informe um valor válido.");
      return;
    }

    if (modo === 'Individual' && !selectedAnimalId) {
      toast.error("Selecione um animal para despesa individual.");
      return;
    }

    onAddExpense({
      tipo,
      valor: val,
      modo,
      animalId: modo === 'Individual' ? selectedAnimalId : undefined
    });

    setValor("");
    toast.success("Despesa lançada com sucesso!");
  };

  return (
    <div className="space-y-6 relative min-h-[80vh] p-6 rounded-2xl overflow-hidden print:overflow-visible">
      {/* Background Image */}
      <div 
        className="absolute inset-0 z-0 opacity-30 pointer-events-none"
        style={{ 
          backgroundImage: 'url("https://images.unsplash.com/photo-1580519327913-eb55ab934724?q=80&w=2072&auto=format&fit=crop")',
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          filter: 'brightness(0.3)'
        }}
      />

      <div className="relative z-10 space-y-6">
        <div className="flex flex-col gap-1">
          <h2 className="text-2xl font-bold tracking-tight text-slate-900">Financeiro / Gastos</h2>
          <p className="text-slate-500">Controle de despesas coletivas e individuais do rebanho.</p>
        </div>

        <div className="grid gap-6 md:grid-cols-2">
          <Card className="border-none shadow-sm bg-white">
            <CardHeader>
              <CardTitle className="text-lg font-semibold flex items-center gap-2">
                <DollarSign className="w-5 h-5 text-emerald-500" />
                Lançar Nova Despesa
              </CardTitle>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="space-y-2">
                  <Label>Tipo de Despesa</Label>
                  <Select value={tipo} onValueChange={setTipo}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Ração">Ração</SelectItem>
                      <SelectItem value="Suplemento">Suplemento</SelectItem>
                      <SelectItem value="Vacinas">Vacinas</SelectItem>
                      <SelectItem value="Medicamentos">Medicamentos</SelectItem>
                      <SelectItem value="Veterinário">Veterinário</SelectItem>
                      <SelectItem value="Inseminação Artificial">Inseminação Artificial</SelectItem>
                      <SelectItem value="Outros">Outros</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label>Valor Total (R$)</Label>
                  <Input 
                    type="number" 
                    step="0.01" 
                    value={valor} 
                    onChange={(e) => setValor(e.target.value)}
                    placeholder="0,00"
                    required
                  />
                </div>

                <div className="space-y-2">
                  <Label>Modo de Aplicação</Label>
                  <div className="grid grid-cols-2 gap-2">
                    <Button 
                      type="button"
                      variant={modo === 'Coletiva' ? 'default' : 'outline'}
                      onClick={() => setModo('Coletiva')}
                      className="gap-2"
                    >
                      <Users className="w-4 h-4" />
                      Coletiva
                    </Button>
                    <Button 
                      type="button"
                      variant={modo === 'Individual' ? 'default' : 'outline'}
                      onClick={() => setModo('Individual')}
                      className="gap-2"
                    >
                      <User className="w-4 h-4" />
                      Individual
                    </Button>
                  </div>
                </div>

                {modo === 'Individual' && (
                  <div className="space-y-2 animate-in fade-in slide-in-from-top-2">
                    <Label>Selecionar Animal</Label>
                    <Select value={selectedAnimalId} onValueChange={setSelectedAnimalId}>
                      <SelectTrigger>
                        <SelectValue placeholder="Escolha o animal pelo brinco" />
                      </SelectTrigger>
                      <SelectContent>
                        {animals.filter(a => a.status === 'Ativo').map(a => (
                          <SelectItem key={a.id} value={a.id}>
                            Brinco: {a.id} ({a.raca || 'Nelore'})
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                )}

                <Button type="submit" className="w-full bg-emerald-600 hover:bg-emerald-700 text-white mt-4">
                  Lançar Despesa
                </Button>
              </form>
            </CardContent>
          </Card>

          <Card className="border-none shadow-sm bg-white">
            <CardHeader>
              <CardTitle className="text-lg font-semibold">Resumo de Investimento</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="p-4 bg-slate-50/80 rounded-xl border border-slate-100">
                <p className="text-sm text-slate-500">Total Investido no Rebanho Ativo</p>
                <p className="text-3xl font-bold text-slate-900">
                  R$ {animals
                    .filter(a => a.status === 'Ativo')
                    .reduce((acc, a) => {
                      const entryDate = new Date(a.dataEntrada);
                      const today = new Date();
                      const diffDays = Math.ceil(Math.abs(today.getTime() - entryDate.getTime()) / (1000 * 60 * 60 * 24)) || 1;
                      const custoFinanciamento = a.precoCompra * ((a.taxaJurosAnual || 0) / 100) * (diffDays / 365);
                      return acc + a.precoCompra + custoFinanciamento + a.despesas.reduce((dAcc, d) => dAcc + d.valor, 0);
                    }, 0)
                    .toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
                </p>
              </div>
              
              <div className="space-y-2">
                <h4 className="text-sm font-medium text-slate-700">Dicas de Manejo</h4>
                <ul className="text-xs text-slate-500 space-y-1 list-disc pl-4">
                  <li>Mantenha o registro de vacinas sempre atualizado.</li>
                  <li>Despesas coletivas são rateadas igualmente entre todos os animais ativos.</li>
                  <li>O lucro real só é calculado após a venda do animal.</li>
                </ul>
              </div>

              <div className="pt-4 border-t">
                <h4 className="text-sm font-medium text-slate-700 mb-2">Investimento por Cabeça</h4>
                <div className="max-h-[200px] overflow-y-auto space-y-2 pr-2">
                  {animals.filter(a => a.status === 'Ativo').map(a => {
                    const entryDate = new Date(a.dataEntrada);
                    const today = new Date();
                    const diffDays = Math.ceil(Math.abs(today.getTime() - entryDate.getTime()) / (1000 * 60 * 60 * 24)) || 1;
                    const custoFinanciamento = a.precoCompra * ((a.taxaJurosAnual || 0) / 100) * (diffDays / 365);
                    const totalInvested = a.precoCompra + custoFinanciamento + a.despesas.reduce((acc, d) => acc + d.valor, 0);
                    
                    return (
                      <div key={a.id} className="flex justify-between items-center p-2 bg-slate-50/80 rounded-lg text-xs">
                        <div className="flex flex-col">
                          <span className="font-bold">#{a.id}</span>
                          <span className="text-[9px] text-slate-400 uppercase">{a.raca || 'Nelore'}</span>
                        </div>
                        <div className="flex items-center gap-3">
                          <span className="text-slate-600">R$ {totalInvested.toLocaleString('pt-BR')}</span>
                          <Button variant="ghost" size="icon" className="h-6 w-6" onClick={() => onEditAnimal?.(a)}>
                            <Edit className="w-3 h-3 text-slate-400" />
                          </Button>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
