import * as React from "react";
import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from "@/components/ui/table";
import { 
  DropdownMenu, 
  DropdownMenuContent, 
  DropdownMenuItem, 
  DropdownMenuLabel, 
  DropdownMenuSeparator, 
  DropdownMenuTrigger 
} from "@/components/ui/dropdown-menu";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { MoreHorizontal, Search, Plus, Scale, Syringe, Trash2, Edit, ExternalLink, DollarSign, Skull, Baby, AlertCircle, FileText, Stethoscope } from "lucide-react";
import { Animal } from "@/types";

import { cn } from "@/lib/utils";

interface AnimalTableProps {
  animals: Animal[];
  onAdd: () => void;
  onEdit: (animal: Animal) => void;
  onDelete: (id: string) => void;
  onAddWeight: (animal: Animal) => void;
  onAddVaccine: (animal: Animal) => void;
  onAddHealth: (animal: Animal) => void;
  onViewProfile: (animal: Animal) => void;
  onSale: (animal: Animal) => void;
  onDeath: (animal: Animal) => void;
  onAddBirth: (animal: Animal) => void;
}

export function AnimalTable({ 
  animals, 
  onAdd, 
  onEdit, 
  onDelete, 
  onAddWeight, 
  onAddVaccine,
  onAddHealth,
  onViewProfile,
  onSale,
  onDeath,
  onAddBirth
}: AnimalTableProps) {
  const [search, setSearch] = React.useState("");

  const filteredAnimals = animals.filter(a => 
    a.id.toLowerCase().includes(search.toLowerCase()) ||
    a.sexo.toLowerCase().includes(search.toLowerCase()) ||
    (a.raca || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-4 relative min-h-[80vh] p-6 rounded-2xl overflow-hidden">
      {/* Background Image */}
      <div 
        className="absolute inset-0 z-0 opacity-20 pointer-events-none"
        style={{ 
          backgroundImage: 'url("https://images.unsplash.com/photo-1551029506-0807df4e2031?q=80&w=2070&auto=format&fit=crop")',
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          filter: 'brightness(0.4)'
        }}
      />

      <div className="relative z-10 space-y-4">
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
          <div className="flex flex-col gap-1">
            <h2 className="text-2xl font-bold tracking-tight text-slate-900">Rebanho Ativo</h2>
            <p className="text-slate-500">Gerencie todos os animais ativos na propriedade.</p>
          </div>
          <Button onClick={onAdd} className="bg-emerald-600 hover:bg-emerald-700 text-white gap-2 shadow-lg shadow-emerald-600/20">
            <Plus className="w-4 h-4" />
            Novo Animal
          </Button>
        </div>

        <div className="bg-blue-50/90 backdrop-blur-sm border border-blue-100 rounded-xl p-3 flex gap-2 items-center text-xs text-blue-800">
          <AlertCircle className="w-4 h-4 text-blue-600 flex-shrink-0" />
          <p>
            <b>Lembrete:</b> Estação de monta em Novembro (13-14 meses). Partos em Setembro (23-24 meses). Desmama aos 8 meses.
          </p>
        </div>

        <div className="flex items-center gap-2 bg-white p-2 rounded-xl shadow-sm border border-slate-100">
          <Search className="w-4 h-4 text-slate-400 ml-2" />
          <Input 
            placeholder="Buscar por brinco, sexo ou raça..." 
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="border-none shadow-none focus-visible:ring-0 bg-transparent"
          />
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-slate-100 overflow-hidden">
          <Table>
            <TableHeader className="bg-slate-50/50">
              <TableRow>
                <TableHead className="font-semibold text-slate-700">Brinco (ID)</TableHead>
                <TableHead className="font-semibold text-slate-700">Raça / Sexo</TableHead>
                <TableHead className="font-semibold text-slate-700">Partos</TableHead>
                <TableHead className="font-semibold text-slate-700">Peso Atual</TableHead>
                <TableHead className="font-semibold text-slate-700">Última Vacina</TableHead>
                <TableHead className="font-semibold text-slate-700">Investimento</TableHead>
                <TableHead className="text-right font-semibold text-slate-700">Ações</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredAnimals.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} className="h-32 text-center text-slate-500">
                    Nenhum animal encontrado.
                  </TableCell>
                </TableRow>
              ) : (
                filteredAnimals.map((animal) => {
                  const lastWeight = animal.historicoPesos[animal.historicoPesos.length - 1]?.peso || 0;
                  const lastVaccine = animal.vacinas[animal.vacinas.length - 1]?.tipo || "---";
                  const totalExpenses = animal.despesas.reduce((acc, d) => acc + d.valor, 0);
                  
                  const entryDate = new Date(animal.dataEntrada);
                  const today = new Date();
                  const diffDays = Math.ceil(Math.abs(today.getTime() - entryDate.getTime()) / (1000 * 60 * 60 * 24)) || 1;
                  const custoFinanciamento = animal.precoCompra * ((animal.taxaJurosAnual || 0) / 100) * (diffDays / 365);
                  
                  const totalInvested = animal.precoCompra + custoFinanciamento + totalExpenses;

                  const needsVaccineWarning = animal.tipoEntrada === 'Cria' && 
                                            animal.sexo === 'Fêmea' && 
                                            diffDays > 90 && 
                                            animal.vacinas.length === 0;

                  return (
                    <TableRow key={animal.id} className="hover:bg-slate-50/50 transition-colors">
                      <TableCell className="font-bold text-slate-900">{animal.id}</TableCell>
                      <TableCell>
                        <div className="flex flex-col gap-1">
                          <span className="text-[10px] font-bold text-slate-500 uppercase">{animal.raca || 'Nelore'}</span>
                          <Badge variant={animal.sexo === 'Macho' ? 'default' : 'secondary'} className={cn(
                            "font-medium w-fit",
                            animal.sexo === 'Macho' ? "bg-blue-100 text-blue-700 hover:bg-blue-100" : "bg-pink-100 text-pink-700 hover:bg-pink-100"
                          )}>
                            {animal.sexo}
                          </Badge>
                        </div>
                      </TableCell>
                    <TableCell>
                      <span className="text-sm font-medium text-slate-600">{animal.sexo === 'Fêmea' ? animal.partos : '---'}</span>
                    </TableCell>
                    <TableCell>
                      <div className="flex flex-col">
                        <div className="flex items-center gap-2">
                          <Scale className="w-3 h-3 text-slate-400" />
                          <span className="font-medium">{lastWeight} @</span>
                        </div>
                        {animal.dataDesmamaPrevista && (
                          <span className="text-[10px] text-orange-600 font-medium">
                            Desmama: {new Date(animal.dataDesmamaPrevista).toLocaleDateString('pt-BR')}
                          </span>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex flex-col">
                        <div className="flex items-center gap-2">
                          <Syringe className={cn("w-3 h-3", needsVaccineWarning ? "text-red-500 animate-pulse" : "text-slate-400")} />
                          <span className={cn("text-sm", needsVaccineWarning && "text-red-600 font-bold")}>
                            {lastVaccine}
                          </span>
                        </div>
                        {needsVaccineWarning && (
                          <span className="text-[9px] text-red-500 font-bold uppercase">
                            Vacina Atrasada (&gt;3 meses)
                          </span>
                        )}
                        {animal.dataPrenha && (
                          <span className="text-[10px] text-emerald-600 font-medium">
                            Prenha: {new Date(animal.dataPrenha).toLocaleDateString('pt-BR')}
                          </span>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <span className="font-medium text-slate-900">R$ {totalInvested.toLocaleString('pt-BR')}</span>
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex items-center justify-end gap-1">
                        <Button 
                          variant="ghost" 
                          size="icon" 
                          className="h-8 w-8 text-slate-600 hover:text-slate-900 hover:bg-slate-100" 
                          onClick={() => onViewProfile(animal)}
                          title="Ver Histórico Completo / Imprimir"
                        >
                          <FileText className="h-4 w-4" />
                        </Button>
                        <Button 
                          variant="ghost" 
                          size="icon" 
                          className="h-8 w-8 text-blue-600 hover:text-blue-700 hover:bg-blue-50" 
                          onClick={() => onEdit(animal)}
                          title="Editar"
                        >
                          <Edit className="h-4 w-4" />
                        </Button>
                        <Button 
                          variant="ghost" 
                          size="icon" 
                          className="h-8 w-8 text-emerald-600 hover:text-emerald-700 hover:bg-emerald-50" 
                          onClick={() => onSale(animal)}
                          title="Vender"
                        >
                          <DollarSign className="h-4 w-4" />
                        </Button>
                        <Button 
                          variant="ghost" 
                          size="icon" 
                          className="h-8 w-8 text-orange-600 hover:text-orange-700 hover:bg-orange-50" 
                          onClick={() => onDeath(animal)}
                          title="Morte"
                        >
                          <Skull className="h-4 w-4" />
                        </Button>
                        <Button 
                          variant="ghost" 
                          size="icon" 
                          className="h-8 w-8 text-purple-600 hover:text-purple-700 hover:bg-purple-50" 
                          onClick={() => onAddWeight(animal)}
                          title="Peso"
                        >
                          <Scale className="h-4 w-4" />
                        </Button>
                        <Button 
                          variant="ghost" 
                          size="icon" 
                          className="h-8 w-8 text-pink-600 hover:text-pink-700 hover:bg-pink-50" 
                          onClick={() => onAddVaccine(animal)}
                          title="Vacina"
                        >
                          <Syringe className="h-4 w-4" />
                        </Button>
                        <Button 
                          variant="ghost" 
                          size="icon" 
                          className="h-8 w-8 text-emerald-700 hover:text-emerald-800 hover:bg-emerald-50" 
                          onClick={() => onAddHealth(animal)}
                          title="Saúde (Doenças/Tratamento)"
                        >
                          <Stethoscope className="h-4 w-4" />
                        </Button>
                        {animal.sexo === 'Fêmea' && (
                          <Button 
                            variant="ghost" 
                            size="icon" 
                            className="h-8 w-8 text-amber-600 hover:text-amber-700 hover:bg-amber-50" 
                            onClick={() => onAddBirth(animal)}
                            title="Parto"
                          >
                            <Baby className="h-4 w-4" />
                          </Button>
                        )}
                        <Button 
                          variant="ghost" 
                          size="icon" 
                          className="h-8 w-8 text-red-600 hover:text-red-700 hover:bg-red-50" 
                          onClick={() => onDelete(animal.id)}
                          title="Excluir"
                        >
                          <Trash2 className="h-4 w-4" />
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
    </div>
  );
}
