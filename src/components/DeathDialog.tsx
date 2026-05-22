import * as React from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogDescription,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from "@/components/ui/select";
import { Animal } from "@/types";

interface DeathDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  animal: Animal | null;
  onConfirm: (animal: Animal, motivo: string) => void;
}

export function DeathDialog({ open, onOpenChange, animal, onConfirm }: DeathDialogProps) {
  const [motivo, setMotivo] = React.useState("Doenca");

  if (!animal) return null;

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle className="text-orange-600">Registrar Morte - Animal #{animal.id}</DialogTitle>
          <DialogDescription>
            Esta ação é irreversível. O animal será marcado como morto e todo o investimento acumulado será rateado como prejuízo entre os animais ativos.
          </DialogDescription>
        </DialogHeader>
        
        <div className="space-y-4 py-4">
          <div className="space-y-2">
            <Label htmlFor="motivo">Motivo da Morte</Label>
            <Select value={motivo} onValueChange={setMotivo}>
              <SelectTrigger>
                <SelectValue placeholder="Selecione o motivo" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="Doenca">Doença</SelectItem>
                <SelectItem value="Acidente com Peçonhentos">Acidente com Peçonhentos</SelectItem>
                <SelectItem value="Outro">Outro</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="bg-orange-50 p-4 rounded-lg border border-orange-100">
            <p className="text-sm text-orange-800 font-medium">Resumo do Prejuízo:</p>
            <ul className="text-xs text-orange-700 mt-2 space-y-1">
              <li>• Valor de Compra: R$ {animal.precoCompra.toLocaleString('pt-BR')}</li>
              <li>• Despesas Acumuladas: R$ {animal.despesas.reduce((acc, d) => acc + d.valor, 0).toLocaleString('pt-BR')}</li>
            </ul>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>Cancelar</Button>
          <Button 
            variant="destructive" 
            onClick={() => {
              onConfirm(animal, motivo);
              onOpenChange(false);
            }}
            className="bg-orange-600 hover:bg-orange-700"
          >
            Confirmar Morte
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
