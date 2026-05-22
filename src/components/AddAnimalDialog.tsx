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
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Animal, AnimalType, Sexo } from "@/types";

interface AddAnimalDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSave: (animal: Partial<Animal>) => void;
  initialData?: Partial<Animal>;
}

export function AddAnimalDialog({ open, onOpenChange, onSave, initialData }: AddAnimalDialogProps) {
  const [type, setType] = React.useState<AnimalType>("Compra");
  const [formData, setFormData] = React.useState({
    id: "",
    sexo: "Macho" as Sexo,
    pai: "",
    mae: "",
    metodoReproducao: "Natural" as 'Natural' | 'IA',
    dataEntrada: new Date().toISOString().split('T')[0],
    precoCompra: "",
    formaPagamento: "À vista" as 'À vista' | 'A prazo',
    taxaJurosAnual: "0",
    valorParcela: "0",
    numeroParcelas: "0",
    origemCapital: "Próprio" as 'Próprio' | 'Empréstimo',
    raca: "Nelore" as 'Nelore' | 'Angus' | 'Holandês' | 'Zebu' | 'Búfalo' | 'Outra',
    pesoInicial: "",
    dataPrenha: "",
    dataDesmamaPrevista: "",
  });

  React.useEffect(() => {
    if (initialData) {
      setType(initialData.tipoEntrada || "Compra");
      setFormData({
        id: initialData.id || "",
        sexo: initialData.sexo || "Macho",
        pai: initialData.pai || "",
        mae: initialData.mae || "",
        metodoReproducao: initialData.metodoReproducao || "Natural",
        dataEntrada: initialData.dataEntrada || new Date().toISOString().split('T')[0],
        precoCompra: initialData.precoCompra !== undefined ? initialData.precoCompra.toString() : "",
        formaPagamento: initialData.formaPagamento || "À vista",
        taxaJurosAnual: (initialData.taxaJurosAnual || 0).toString(),
        valorParcela: "0",
        numeroParcelas: "0",
        origemCapital: initialData.origemCapital || "Próprio",
        raca: initialData.raca || "Nelore",
        pesoInicial: initialData.historicoPesos?.[0]?.peso.toString() || "",
        dataPrenha: initialData.dataPrenha || "",
        dataDesmamaPrevista: initialData.dataDesmamaPrevista || "",
      });
    } else {
      setFormData({
        id: "",
        sexo: "Macho",
        pai: "",
        mae: "",
        metodoReproducao: "Natural",
        dataEntrada: new Date().toISOString().split('T')[0],
        precoCompra: "",
        formaPagamento: "À vista",
        taxaJurosAnual: "0",
        valorParcela: "0",
        numeroParcelas: "0",
        origemCapital: "Próprio",
        raca: "Nelore",
        pesoInicial: "",
        dataPrenha: "",
        dataDesmamaPrevista: "",
      });
    }
  }, [initialData, open]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave({
      ...formData,
      tipoEntrada: type,
      precoCompra: parseFloat(formData.precoCompra) || 0,
      taxaJurosAnual: parseFloat(formData.taxaJurosAnual) || 0,
      historicoPesos: initialData ? initialData.historicoPesos : (formData.pesoInicial ? [{ 
        data: formData.dataEntrada, 
        peso: parseFloat(formData.pesoInicial) 
      }] : []),
      status: initialData?.status || "Ativo",
      partos: initialData?.partos || 0,
      vacinas: initialData?.vacinas || [],
      despesas: initialData?.despesas || [],
    });
    onOpenChange(false);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[500px] bg-white border-none shadow-2xl">
        <DialogHeader>
          <DialogTitle className="text-2xl font-bold text-slate-900">
            {initialData ? 'Editar Animal' : 'Cadastrar Novo Animal'}
          </DialogTitle>
          <DialogDescription>
            {initialData ? 'Atualize as informações do animal selecionado.' : 'Adicione um novo animal ao seu rebanho via compra ou nascimento.'}
          </DialogDescription>
        </DialogHeader>

        <Tabs value={type} onValueChange={(v) => setType(v as AnimalType)} className="w-full mt-4">
          <TabsList className="grid w-full grid-cols-2 bg-slate-100 p-1">
            <TabsTrigger value="Compra" className="data-[state=active]:bg-white data-[state=active]:shadow-sm">Compra / Entrada</TabsTrigger>
            <TabsTrigger value="Cria" className="data-[state=active]:bg-white data-[state=active]:shadow-sm">Nascimento / Cria</TabsTrigger>
          </TabsList>

          <form onSubmit={handleSubmit} className="space-y-4 mt-6">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="id">Brinco (ID)</Label>
                <Input 
                  id="id" 
                  value={formData.id} 
                  onChange={(e) => setFormData({...formData, id: e.target.value})}
                  placeholder="Ex: 1024" 
                  required 
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="raca">Raça / Tipo</Label>
                <Select value={formData.raca} onValueChange={(v: any) => setFormData({...formData, raca: v})}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Nelore">Nelore</SelectItem>
                    <SelectItem value="Angus">Angus</SelectItem>
                    <SelectItem value="Holandês">Holandês (Leite)</SelectItem>
                    <SelectItem value="Zebu">Zebu</SelectItem>
                    <SelectItem value="Búfalo">Búfalo</SelectItem>
                    <SelectItem value="Outra">Outra</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="sexo">Sexo</Label>
                <Select value={formData.sexo} onValueChange={(v: Sexo) => setFormData({...formData, sexo: v})}>
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="Macho">Macho</SelectItem>
                    <SelectItem value="Fêmea">Fêmea</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="pai">Pai (Opcional)</Label>
                <Input 
                  id="pai" 
                  value={formData.pai} 
                  onChange={(e) => setFormData({...formData, pai: e.target.value})}
                  placeholder="ID do Pai" 
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="mae">Mãe (Opcional)</Label>
                <Input 
                  id="mae" 
                  value={formData.mae} 
                  onChange={(e) => setFormData({...formData, mae: e.target.value})}
                  placeholder="ID da Mãe" 
                />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="data">{type === 'Compra' ? 'Data da Compra' : 'Data de Nasc.'}</Label>
                <Input 
                  id="data" 
                  type="date"
                  value={formData.dataEntrada} 
                  onChange={(e) => setFormData({...formData, dataEntrada: e.target.value})}
                  required 
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="peso">Peso Inicial (@)</Label>
                <Input 
                  id="peso" 
                  type="number"
                  step="0.1"
                  value={formData.pesoInicial} 
                  onChange={(e) => setFormData({...formData, pesoInicial: e.target.value})}
                  placeholder="Ex: 12.5" 
                />
              </div>
            </div>

            {formData.sexo === 'Fêmea' && (
              <div className="grid grid-cols-2 gap-4 border-t pt-4">
                <div className="space-y-2">
                  <Label htmlFor="prenha">Data Prenha (Opcional)</Label>
                  <Input 
                    id="prenha" 
                    type="date"
                    value={formData.dataPrenha} 
                    onChange={(e) => setFormData({...formData, dataPrenha: e.target.value})}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="desmama">Desmama Prevista</Label>
                  <Input 
                    id="desmama" 
                    type="date"
                    value={formData.dataDesmamaPrevista} 
                    onChange={(e) => setFormData({...formData, dataDesmamaPrevista: e.target.value})}
                  />
                </div>
              </div>
            )}

            {type === 'Compra' && (
              <div className="space-y-4 border-t pt-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="preco">Preço de Compra (R$)</Label>
                    <Input 
                      id="preco" 
                      type="number"
                      step="0.01"
                      value={formData.precoCompra} 
                      onChange={(e) => setFormData({...formData, precoCompra: e.target.value})}
                      placeholder="Ex: 2500.00" 
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="forma">Forma de Pagamento</Label>
                    <Select value={formData.formaPagamento} onValueChange={(v: any) => setFormData({...formData, formaPagamento: v})}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="À vista">À vista</SelectItem>
                        <SelectItem value="A prazo">A prazo</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="juros">Taxa de Juros Anual (%)</Label>
                    <Input 
                      id="juros" 
                      type="number"
                      step="0.01"
                      value={formData.taxaJurosAnual} 
                      onChange={(e) => setFormData({...formData, taxaJurosAnual: e.target.value})}
                      placeholder="Ex: 12.5" 
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="origem">Origem do Capital</Label>
                    <Select value={formData.origemCapital} onValueChange={(v: any) => setFormData({...formData, origemCapital: v})}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="Próprio">Capital Próprio</SelectItem>
                        <SelectItem value="Empréstimo">Empréstimo</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              </div>
            )}

            {type === 'Cria' && (
              <div className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="metodo">Método de Reprodução</Label>
                  <Select 
                    value={formData.metodoReproducao} 
                    onValueChange={(v: any) => setFormData({...formData, metodoReproducao: v})}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Selecione o método" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Natural">Monta Natural</SelectItem>
                      <SelectItem value="IA">Inseminação Artificial (IA)</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="bg-blue-50 p-3 rounded-lg text-xs text-blue-700">
                  Lembrete: Desmamar com 8 meses (200-250kg).
                </div>
              </div>
            )}

            <DialogFooter className="pt-4">
              <Button type="button" variant="ghost" onClick={() => onOpenChange(false)}>Cancelar</Button>
              <Button type="submit" className="bg-emerald-600 hover:bg-emerald-700 text-white">
                {initialData ? 'Atualizar Animal' : 'Salvar Animal'}
              </Button>
            </DialogFooter>
          </form>
        </Tabs>
      </DialogContent>
    </Dialog>
  );
}
