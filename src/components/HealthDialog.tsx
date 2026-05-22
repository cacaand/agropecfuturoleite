import * as React from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from "@/components/ui/select";
import { Animal, OcorrenciaSaude } from "@/types";

interface HealthDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  animal: Animal | null;
  onSave: (animalId: string, ocorrencia: OcorrenciaSaude) => void;
}

export function HealthDialog({ open, onOpenChange, animal, onSave }: HealthDialogProps) {
  const [tipo, setTipo] = React.useState("Doença");
  const [diagnostico, setDiagnostico] = React.useState("");
  const [tratamento, setTratamento] = React.useState("");
  const [custo, setCusto] = React.useState("0");
  const [data, setData] = React.useState(new Date().toISOString().split('T')[0]);

  React.useEffect(() => {
    if (open) {
      setTipo("Doença");
      setDiagnostico("");
      setTratamento("");
      setCusto("0");
      setData(new Date().toISOString().split('T')[0]);
    }
  }, [open]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!animal) return;

    onSave(animal.id, {
      tipo,
      diagnostico,
      tratamento,
      custo: parseFloat(custo) || 0,
      data
    });
    onOpenChange(false);
  };

  if (!animal) return null;

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Registrar Ocorrência de Saúde - Animal #{animal.id}</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 py-4">
          <div className="space-y-2">
            <Label htmlFor="tipo">Tipo de Ocorrência</Label>
            <Select value={tipo} onValueChange={setTipo}>
              <SelectTrigger>
                <SelectValue placeholder="Selecione o tipo" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="Doença">Doença</SelectItem>
                <SelectItem value="Acidente">Acidente</SelectItem>
                <SelectItem value="Tratamento Preventivo">Tratamento Preventivo</SelectItem>
                <SelectItem value="Cirurgia">Cirurgia</SelectItem>
                <SelectItem value="Outro">Outro</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="diagnostico">Diagnóstico / Sintomas</Label>
            <Input 
              id="diagnostico" 
              value={diagnostico} 
              onChange={(e) => setDiagnostico(e.target.value)} 
              placeholder="Ex: Mastite, Febre, Picada"
              required 
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="tratamento">Tratamento Realizado</Label>
            <Input 
              id="tratamento" 
              value={tratamento} 
              onChange={(e) => setTratamento(e.target.value)} 
              placeholder="Ex: Antibiótico X, Limpeza Y" 
              required
            />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="data">Data</Label>
              <Input 
                id="data" 
                type="date" 
                value={data} 
                onChange={(e) => setData(e.target.value)} 
                required 
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="custo">Custo do Tratamento (R$)</Label>
              <Input 
                id="custo" 
                type="number" 
                step="0.01" 
                value={custo} 
                onChange={(e) => setCusto(e.target.value)} 
                required 
              />
            </div>
          </div>
          <DialogFooter>
            <Button type="submit" className="bg-emerald-600 hover:bg-emerald-700">
              Salvar Ocorrência
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
