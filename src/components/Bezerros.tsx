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
import { Input } from "@/components/ui/input";
import { 
  Baby, 
  Search, 
  Scale, 
  Syringe, 
  History,
  Trash2,
  TrendingUp,
  Beef
} from "lucide-react";
import { Animal } from "@/types";
import { cn } from "@/lib/utils";

interface BezerrosProps {
  animals: Animal[];
  onAddWeight: (animal: Animal) => void;
  onAddVaccine: (animal: Animal) => void;
  onViewProfile: (animal: Animal) => void;
  onDeleteAnimal: (id: string) => void;
}

export function Bezerros({ 
  animals, 
  onAddWeight, 
  onAddVaccine, 
  onViewProfile,
  onDeleteAnimal
}: BezerrosProps) {
  const [search, setSearch] = React.useState("");
  
  const newborns = animals.filter(a => a.tipoEntrada === 'Cria' && a.status === 'Ativo');

  const filtered = newborns.filter(a => 
    a.id.toLowerCase().includes(search.toLowerCase()) ||
    (a.raca || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6 relative min-h-[80vh] p-6 rounded-2xl overflow-hidden print:overflow-visible">
      {/* Background Image */}
      <div 
        className="absolute inset-0 z-0 opacity-20 pointer-events-none"
        style={{ 
          backgroundImage: 'url("https://images.unsplash.com/photo-1545468241-929344177708?q=80&w=2070&auto=format&fit=crop")',
          backgroundSize: 'cover',
          backgroundPosition: 'center',
          filter: 'brightness(0.3)'
        }}
      />

      <div className="relative z-10 space-y-6">
        <div className="flex flex-col gap-1">
          <h2 className="text-3xl font-bold tracking-tight text-white">Bezerros e Crias</h2>
          <p className="text-slate-300">Controle de animais nascidos na propriedade (Custo de Entrada: R$ 0,00).</p>
        </div>

        <div className="grid gap-6 md:grid-cols-4">
          <Card className="bg-white border-none shadow-sm">
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-slate-500 uppercase flex items-center gap-2">
                <Baby className="w-4 h-4 text-emerald-500" /> Total Bezerros
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{newborns.length}</div>
            </CardContent>
          </Card>
          <Card className="bg-white border-none shadow-sm">
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-slate-500 uppercase flex items-center gap-2">
                <TrendingUp className="w-4 h-4 text-emerald-500" /> Ganho de Peso Médio
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-emerald-600">
                {(newborns.reduce((acc, a) => {
                  const first = a.historicoPesos[0]?.peso || 0;
                  const last = a.historicoPesos[a.historicoPesos.length - 1]?.peso || 0;
                  return acc + (last - first);
                }, 0) / (newborns.length || 1)).toFixed(2)} @
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="flex items-center gap-2 bg-white p-2 rounded-xl shadow-sm border border-slate-100">
          <Search className="w-4 h-4 text-slate-400 ml-2" />
          <Input 
            placeholder="Buscar por brinco ou raça..." 
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="border-none shadow-none focus-visible:ring-0 bg-transparent text-slate-900"
          />
        </div>

        <Card className="bg-white border-none shadow-sm overflow-hidden">
          <Table>
            <TableHeader className="bg-slate-50/50">
              <TableRow>
                <TableHead className="font-semibold text-slate-700">Brinco</TableHead>
                <TableHead className="font-semibold text-slate-700">Mãe / Pai</TableHead>
                <TableHead className="font-semibold text-slate-700">Nascimento</TableHead>
                <TableHead className="font-semibold text-slate-700">Peso Desmama</TableHead>
                <TableHead className="text-right font-semibold text-slate-700">Ações</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filtered.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} className="h-48 text-center text-slate-400">
                    Nenhum filhote registrado ainda.
                  </TableCell>
                </TableRow>
              ) : (
                filtered.map((animal) => (
                  <TableRow key={animal.id} className="hover:bg-slate-50/50">
                    <TableCell className="font-bold text-slate-900">#{animal.id}</TableCell>
                    <TableCell>
                      <div className="flex flex-col text-xs">
                        <span className="font-medium">Mãe: {animal.mae || '---'}</span>
                        <span className="text-slate-500">Pai: {animal.pai || '---'}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      {new Date(animal.dataEntrada).toLocaleDateString('pt-BR')}
                    </TableCell>
                    <TableCell>
                      <div className="flex flex-col">
                        <span className="font-bold">{animal.historicoPesos[animal.historicoPesos.length - 1]?.peso || 0} @</span>
                        {animal.dataDesmamaPrevista && (
                          <span className="text-[10px] text-blue-600 uppercase font-bold">
                            Previsto: {new Date(animal.dataDesmamaPrevista).toLocaleDateString('pt-BR')}
                          </span>
                        )}
                      </div>
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex items-center justify-end gap-2">
                        <Button 
                          variant="ghost" 
                          size="icon" 
                          className="h-8 w-8 text-slate-600"
                          onClick={() => onViewProfile(animal)}
                        >
                          <History className="h-4 w-4" />
                        </Button>
                        <Button 
                          variant="ghost" 
                          size="icon" 
                          className="h-8 w-8 text-blue-600"
                          onClick={() => onAddWeight(animal)}
                        >
                          <Scale className="h-4 w-4" />
                        </Button>
                        <Button 
                          variant="ghost" 
                          size="icon" 
                          className="h-8 w-8 text-pink-600"
                          onClick={() => onAddVaccine(animal)}
                        >
                          <Syringe className="h-4 w-4" />
                        </Button>
                        <Button 
                          variant="ghost" 
                          size="icon" 
                          className="h-8 w-8 text-red-500 hover:bg-red-50"
                          onClick={() => onDeleteAnimal(animal.id)}
                          title="Excluir Registro"
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </Card>
      </div>
    </div>
  );
}
