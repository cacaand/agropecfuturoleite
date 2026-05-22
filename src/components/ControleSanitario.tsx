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
import { ScrollArea } from "@/components/ui/scroll-area";
import { 
  Syringe, 
  Scale, 
  Baby, 
  Skull, 
  Search, 
  Plus, 
  History,
  Trash2,
  AlertTriangle,
  Stethoscope,
  FileText,
  Printer
} from "lucide-react";
import { Animal, UserSettings } from "@/types";
import { cn } from "@/lib/utils";

interface ControleSanitarioProps {
  animals: Animal[];
  onAddWeight: (animal: Animal) => void;
  onAddVaccine: (animal: Animal) => void;
  onAddHealth: (animal: Animal) => void;
  onViewProfile: (animal: Animal) => void;
  onAddBirth: (animal: Animal) => void;
  onDeath: (animal: Animal) => void;
  onDeleteAnimal: (id: string) => void;
  settings?: UserSettings;
}

export function ControleSanitario({ 
  animals, 
  onAddWeight, 
  onAddVaccine, 
  onAddHealth,
  onViewProfile,
  onAddBirth, 
  onDeath,
  onDeleteAnimal,
  settings
}: ControleSanitarioProps) {
  const [search, setSearch] = React.useState("");
  
  const activeAnimals = animals.filter(a => a.status === 'Ativo');
  const deadAnimals = animals.filter(a => a.status === 'Morto');

  const filteredAnimals = activeAnimals.filter(a => 
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
        {/* Printable Header */}
        <div className="hidden print:flex justify-between items-start border-b-2 border-slate-900 pb-4 mb-4">
          <div className="space-y-1">
            <h1 className="text-2xl font-black tracking-tighter uppercase">AgropecFuturo</h1>
            <p className="text-[10px] text-slate-500 font-bold uppercase tracking-widest">Relatório para Vigilância Sanitária</p>
          </div>
          <div className="text-right space-y-1">
            <p className="text-sm font-bold uppercase">{settings?.nomePropriedade || 'PROPRIEDADE NÃO INFORMADA'}</p>
            <div className="text-[10px] text-slate-600 flex flex-col">
              <span>Produtor: {settings?.nomeUsuario || '---'}</span>
              <span>Cartão Produtor: {settings?.cartaoProdutor || '---'} | Registro IMA: {settings?.registroIMA || '---'}</span>
            </div>
          </div>
        </div>

        <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
          <div className="flex flex-col gap-1">
            <h2 className="text-3xl font-bold tracking-tight text-white">Controle Sanitário</h2>
            <p className="text-slate-300">Monitore vacinas, partos, pesos e ocorrências de mortalidade.</p>
          </div>
          <Button 
            onClick={() => window.print()} 
            className="bg-white text-slate-900 hover:bg-slate-100 gap-2 print:hidden"
          >
            <Printer className="w-4 h-4" /> Relatório para Vigilância
          </Button>
        </div>

        <div className="grid gap-6 md:grid-cols-4">
          <Card className="bg-white border-none shadow-sm">
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-slate-500 uppercase flex items-center gap-2">
                <Syringe className="w-4 h-4 text-pink-500" /> Total Vacinas
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">
                {animals.reduce((acc, a) => acc + a.vacinas.length, 0)}
              </div>
            </CardContent>
          </Card>
          <Card className="bg-white border-none shadow-sm">
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-slate-500 uppercase flex items-center gap-2">
                <Baby className="w-4 h-4 text-amber-500" /> Total Partos
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">
                {animals.reduce((acc, a) => acc + (a.partos || 0), 0)}
              </div>
            </CardContent>
          </Card>
          <Card className="bg-white border-none shadow-sm">
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-slate-500 uppercase flex items-center gap-2">
                <Skull className="w-4 h-4 text-orange-500" /> Mortes
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{deadAnimals.length}</div>
            </CardContent>
          </Card>
          <Card className="bg-white border-none shadow-sm">
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-medium text-slate-500 uppercase flex items-center gap-2">
                <Activity className="w-4 h-4 text-blue-500" /> Pesagem Média
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">
                {(animals.reduce((acc, a) => acc + (a.historicoPesos[a.historicoPesos.length - 1]?.peso || 0), 0) / (activeAnimals.length || 1)).toFixed(1)} @
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
          <CardHeader className="border-b bg-slate-50/50">
            <CardTitle className="text-lg font-semibold flex items-center gap-2">
              <Plus className="w-5 h-5 text-emerald-500" /> Lançamento de Eventos Sanitários
            </CardTitle>
          </CardHeader>
          <Table>
            <TableHeader className="bg-slate-50/50">
              <TableRow>
                <TableHead className="font-semibold text-slate-700">Animal (Brinco)</TableHead>
                <TableHead className="font-semibold text-slate-700">Última Vacina</TableHead>
                <TableHead className="font-semibold text-slate-700">Peso Atual</TableHead>
                <TableHead className="font-semibold text-slate-700">Partos</TableHead>
                <TableHead className="text-right font-semibold text-slate-700">Ações Sanitárias</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredAnimals.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} className="h-24 text-center text-slate-500">
                    Nenhum animal ativo encontrado.
                  </TableCell>
                </TableRow>
              ) : (
                filteredAnimals.map((animal) => {
                  const lastVaccine = animal.vacinas[animal.vacinas.length - 1];
                  const lastWeight = animal.historicoPesos[animal.historicoPesos.length - 1];
                  
                  return (
                    <TableRow key={animal.id} className="hover:bg-slate-50/50">
                      <TableCell className="font-bold text-slate-900">#{animal.id}</TableCell>
                      <TableCell>
                        {lastVaccine ? (
                          <div className="flex flex-col">
                            <span className="text-sm font-medium">{lastVaccine.tipo}</span>
                            <span className="text-[10px] text-slate-500">{new Date(lastVaccine.data).toLocaleDateString('pt-BR')}</span>
                          </div>
                        ) : (
                          <span className="text-slate-400 text-xs italic">Nenhuma</span>
                        )}
                      </TableCell>
                      <TableCell>
                        {lastWeight ? (
                          <div className="flex flex-col">
                            <span className="text-sm font-medium">{lastWeight.peso} @</span>
                            <span className="text-[10px] text-slate-500">{new Date(lastWeight.data).toLocaleDateString('pt-BR')}</span>
                          </div>
                        ) : (
                          <span className="text-slate-400 text-xs italic">Nenhum</span>
                        )}
                      </TableCell>
                      <TableCell>
                        <Badge variant="outline" className="font-medium">
                          {animal.sexo === 'Fêmea' ? `${animal.partos} partos` : '---'}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex items-center justify-end gap-2">
                          <Button 
                            variant="ghost" 
                            size="icon" 
                            className="text-slate-600 hover:bg-slate-50" 
                            title="Ver Perfil Completo"
                            onClick={() => onViewProfile(animal)}
                          >
                            <FileText className="w-4 h-4" />
                          </Button>
                          <Button 
                            variant="ghost" 
                            size="icon" 
                            className="text-pink-600 hover:bg-pink-50" 
                            title="Registrar Vacina"
                            onClick={() => onAddVaccine(animal)}
                          >
                            <Syringe className="w-4 h-4" />
                          </Button>
                          <Button 
                            variant="ghost" 
                            size="icon" 
                            className="text-blue-600 hover:bg-blue-50" 
                            title="Registrar Peso"
                            onClick={() => onAddWeight(animal)}
                          >
                            <Scale className="w-4 h-4" />
                          </Button>
                          <Button 
                            variant="ghost" 
                            size="icon" 
                            className="text-emerald-600 hover:bg-emerald-50" 
                            title="Registrar Ocorrência de Saúde"
                            onClick={() => onAddHealth(animal)}
                          >
                            <Stethoscope className="w-4 h-4" />
                          </Button>
                          {animal.sexo === 'Fêmea' && (
                            <Button 
                              variant="ghost" 
                              size="icon" 
                              className="text-amber-600 hover:bg-amber-50" 
                              title="Registrar Parto"
                              onClick={() => onAddBirth(animal)}
                            >
                              <Baby className="w-4 h-4" />
                            </Button>
                          )}
                          <Button 
                            variant="ghost" 
                            size="icon" 
                            className="text-orange-600 hover:bg-orange-50" 
                            title="Registrar Morte"
                            onClick={() => onDeath(animal)}
                          >
                            <Skull className="w-4 h-4" />
                          </Button>
                          <Button 
                            variant="ghost" 
                            size="icon" 
                            className="text-red-500 hover:bg-red-50" 
                            title="Excluir Registro"
                            onClick={() => onDeleteAnimal(animal.id)}
                          >
                            <Trash2 className="w-4 h-4" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  );
                })
              )}
            </TableBody>
          </Table>
        </Card>

        <div className="grid gap-6 md:grid-cols-2">
          {/* Recent Records Table */}
          <Card className="bg-white border-none shadow-sm overflow-hidden">
            <CardHeader className="bg-slate-50/50 border-b">
              <CardTitle className="text-lg font-semibold flex items-center gap-2">
                <History className="w-5 h-5 text-blue-500" /> Histórico Sanitário Recente
              </CardTitle>
            </CardHeader>
            <ScrollArea className="h-[300px]">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Data</TableHead>
                    <TableHead>Animal</TableHead>
                    <TableHead>Evento</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {/* Flat map all events and sort by date */}
                  {animals.flatMap(a => {
                    const vaccineEvents = a.vacinas.map(v => ({ date: v.data, id: a.id, type: 'Vacina', desc: v.tipo }));
                    const birthEvents = Array.from({ length: a.partos || 0 }).map((_, i) => ({ 
                      date: a.updatedAt, // Approximate or simplify for now
                      id: a.id, 
                      type: 'Parto', 
                      desc: `Parto #${i + 1}` 
                    }));
                    const weightEvents = a.historicoPesos.map(w => ({ date: w.data, id: a.id, type: 'Pesagem', desc: `${w.peso} @` }));
                    return [...vaccineEvents, ...birthEvents, ...weightEvents];
                  })
                  .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
                  .slice(0, 20)
                  .map((evt, i) => (
                    <TableRow key={i}>
                      <TableCell className="text-xs text-slate-500">
                        {new Date(evt.date).toLocaleDateString('pt-BR')}
                      </TableCell>
                      <TableCell className="font-bold">#{evt.id}</TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          {evt.type === 'Vacina' && <Syringe className="w-3 h-3 text-pink-500" />}
                          {evt.type === 'Parto' && <Baby className="w-3 h-3 text-amber-500" />}
                          {evt.type === 'Pesagem' && <Scale className="w-3 h-3 text-blue-500" />}
                          <span className="text-sm">{evt.desc}</span>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                  {animals.length === 0 && (
                    <TableRow>
                      <TableCell colSpan={3} className="text-center text-slate-400 py-8">Nenhum evento registrado</TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </ScrollArea>
          </Card>

          {/* Deaths Summary */}
          <Card className="bg-white border-none shadow-sm overflow-hidden">
            <CardHeader className="bg-slate-50/50 border-b">
              <CardTitle className="text-lg font-semibold flex items-center gap-2 text-orange-700">
                <Skull className="w-5 h-5" /> Registro de Mortalidade
              </CardTitle>
            </CardHeader>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Data</TableHead>
                  <TableHead>Animal</TableHead>
                  <TableHead>Motivo</TableHead>
                  <TableHead className="text-right">Perda</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {deadAnimals.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={4} className="h-32 text-center text-slate-400 italic">
                      Nenhuma ocorrência registrada.
                    </TableCell>
                  </TableRow>
                ) : (
                  deadAnimals.map((a) => {
                    const loss = a.precoCompra + a.despesas.reduce((sum, d) => sum + d.valor, 0);
                    return (
                      <TableRow key={a.id}>
                        <TableCell className="text-xs">
                          {new Date(a.updatedAt).toLocaleDateString('pt-BR')}
                        </TableCell>
                        <TableCell className="font-bold">#{a.id}</TableCell>
                        <TableCell>
                          <Badge variant="secondary" className="bg-orange-100 text-orange-700 hover:bg-orange-100">
                            {a.motivoMorte || 'Não informado'}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-right text-red-600 font-semibold">
                          - R$ {loss.toLocaleString('pt-BR')}
                        </TableCell>
                      </TableRow>
                    );
                  })
                )}
              </TableBody>
            </Table>
          </Card>
        </div>
      </div>
    </div>
  );
}

function Activity(props: any) {
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
      <path d="M22 12h-4l-3 9L9 3l-3 9H2" />
    </svg>
  )
}

function HistoryIcon(props: any) {
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
      <path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8" />
      <path d="M3 3v5h5" />
      <path d="M12 7v5l4 2" />
    </svg>
  )
}
