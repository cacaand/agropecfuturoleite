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
import { Animal } from "@/types";

interface SaleDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  animal: Animal | null;
  onSave: (animal: Animal, preco: number) => void;
}

export function SaleDialog({ open, onOpenChange, animal, onSave }: SaleDialogProps) {
  const [preco, setPreco] = React.useState("");

  React.useEffect(() => {
    if (open) {
      setPreco("");
    }
  }, [open]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const val = parseFloat(preco);
    if (animal && !isNaN(val) && val > 0) {
      onSave(animal, val);
      onOpenChange(false);
    }
  };

  if (!animal) return null;

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Registrar Venda - Animal #{animal.id}</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4 py-4">
          <div className="space-y-2">
            <Label htmlFor="preco">Valor da Venda (R$)</Label>
            <Input
              id="preco"
              type="number"
              step="0.01"
              value={preco}
              onChange={(e) => setPreco(e.target.value)}
              placeholder="0,00"
              required
            />
          </div>
          <div className="bg-slate-50 p-3 rounded-lg text-xs text-slate-600">
            O lucro será calculado descontando o preço de compra, despesas e custos de financiamento.
          </div>
          <DialogFooter>
            <Button type="submit" className="bg-emerald-600 hover:bg-emerald-700">
              Confirmar Venda
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
