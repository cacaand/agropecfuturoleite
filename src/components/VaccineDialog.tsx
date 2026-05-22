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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Animal } from "@/types";

interface VaccineDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  animal: Animal | null;
  onSave: (animalId: string, tipo: string, data: string) => void;
}

const VACCINES = [
  "Brucelose",
  "Tétano",
  "Raiva",
  "Leptospirose",
  "Febre Aftosa",
  "Clostridiose",
  "Vermífugo",
  "Outra"
];

export function VaccineDialog({ open, onOpenChange, animal, onSave }: VaccineDialogProps) {
  const [tipo, setTipo] = React.useState("");
  const [data, setData] = React.useState(new Date().toISOString().split('T')[0]);

  React.useEffect(() => {
    if (open) {
      setTipo("");
      setData(new Date().toISOString().split('T')[0]);
    }
  }, [open]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (animal && tipo && data) {
      onSave(animal.id, tipo, data);
      onOpenChange(false);
    }
  };

  if (!animal) return null;

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Registrar Vacina - Animal #{animal.id}</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 py-4">
          <div className="space-y-2">
            <Label htmlFor="tipo">Vacina</Label>
            <Select value={tipo} onValueChange={setTipo} required>
              <SelectTrigger>
                <SelectValue placeholder="Selecione a vacina" />
              </SelectTrigger>
              <SelectContent>
                {VACCINES.map((v) => (
                  <SelectItem key={v} value={v}>
                    {v}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="data">Data da Aplicação</Label>
            <Input
              id="data"
              type="date"
              value={data}
              onChange={(e) => setData(e.target.value)}
              required
            />
          </div>
          <DialogFooter>
            <Button type="submit" className="bg-emerald-600 hover:bg-emerald-700">
              Salvar Vacina
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
