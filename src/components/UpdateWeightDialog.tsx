import * as React from "react";
import { 
  Dialog, 
  DialogContent, 
  DialogDescription, 
  DialogFooter, 
  DialogHeader, 
  DialogTitle 
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Animal } from "@/types";
import { Scale, Calendar } from "lucide-react";

interface UpdateWeightDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  animal: Animal | null;
  onSave: (animalId: string, peso: number, data: string) => void;
}

export function UpdateWeightDialog({ open, onOpenChange, animal, onSave }: UpdateWeightDialogProps) {
  const [peso, setPeso] = React.useState("");
  const [data, setData] = React.useState(new Date().toISOString().split('T')[0]);

  React.useEffect(() => {
    if (animal) {
      const lastWeight = animal.historicoPesos[animal.historicoPesos.length - 1]?.peso || "";
      setPeso(lastWeight.toString());
      setData(new Date().toISOString().split('T')[0]);
    }
  }, [animal, open]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (animal && peso) {
      onSave(animal.id, parseFloat(peso), data);
      onOpenChange(false);
    }
  };

  if (!animal) return null;

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[400px] bg-white border-none shadow-2xl">
        <DialogHeader>
          <DialogTitle className="text-2xl font-bold text-slate-900 flex items-center gap-2">
            <Scale className="w-6 h-6 text-emerald-600" />
            Atualizar Peso
          </DialogTitle>
          <DialogDescription>
            Registre a nova pesagem para o animal <span className="font-bold text-slate-900">#{animal.id}</span>.
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit} className="space-y-6 mt-4">
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="peso" className="text-sm font-medium text-slate-700">Novo Peso (@)</Label>
              <div className="relative">
                <Input 
                  id="peso" 
                  type="number"
                  step="0.1"
                  value={peso} 
                  onChange={(e) => setPeso(e.target.value)}
                  placeholder="Ex: 15.5" 
                  className="pl-10 h-12 text-lg font-semibold"
                  required 
                  autoFocus
                />
                <Scale className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
              </div>
              <p className="text-[10px] text-slate-500">Peso anterior: {animal.historicoPesos[animal.historicoPesos.length - 1]?.peso || 0}@</p>
            </div>

            <div className="space-y-2">
              <Label htmlFor="data" className="text-sm font-medium text-slate-700">Data da Pesagem</Label>
              <div className="relative">
                <Input 
                  id="data" 
                  type="date"
                  value={data} 
                  onChange={(e) => setData(e.target.value)}
                  className="pl-10 h-12"
                  required 
                />
                <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
              </div>
            </div>
          </div>

          <div className="bg-slate-50 p-4 rounded-xl border border-slate-100 space-y-2">
            <h4 className="text-xs font-bold text-slate-700 uppercase tracking-wider">Metas e Referências</h4>
            <ul className="text-[11px] text-slate-600 space-y-1">
              <li>• Desmama: 200kg a 250kg (aprox. 7-8 meses)</li>
              <li>• Prenhez: Média 300kg (aprox. 13-14 meses)</li>
              <li>• Abate: Média 18@ a 20@</li>
            </ul>
          </div>

          <DialogFooter>
            <Button type="button" variant="ghost" onClick={() => onOpenChange(false)}>Cancelar</Button>
            <Button type="submit" className="bg-emerald-600 hover:bg-emerald-700 text-white px-8">
              Salvar Pesagem
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
