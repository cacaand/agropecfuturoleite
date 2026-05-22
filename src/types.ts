export type AnimalStatus = 'Ativo' | 'Vendido' | 'Morto';
export type AnimalType = 'Compra' | 'Cria';
export type Sexo = 'Macho' | 'Fêmea';

export interface PesoRegistro {
  data: string;
  peso: number;
}

export interface VacinaRegistro {
  tipo: string;
  data: string;
}

export interface OcorrenciaSaude {
  tipo: string;
  diagnostico: string;
  tratamento: string;
  data: string;
  custo: number;
}

export interface DespesaRegistro {
  tipo: string;
  valor: number;
  data: string;
}

export interface VendaInfo {
  preco: number;
  data: string;
  lucro: number;
  lucroCDI?: number; // Quanto ganharia se o capital estivesse no CDI
  custoFinanciamento?: number; // Custo total do financiamento (juros pagos)
}

export interface Animal {
  id: string; // Brinco
  sexo: Sexo;
  pai?: string;
  mae?: string;
  metodoReproducao?: 'Natural' | 'IA'; // Inseminação Artificial
  dataEntrada: string;
  tipoEntrada: AnimalType;
  precoCompra: number;
  formaPagamento?: 'À vista' | 'A prazo';
  taxaJurosAnual?: number; // Em porcentagem (ex: 12.5)
  origemCapital?: 'Próprio' | 'Empréstimo';
  raca?: 'Nelore' | 'Angus' | 'Holandês' | 'Zebu' | 'Búfalo' | 'Outra';
  status: AnimalStatus;
  partos: number;
  idade?: string;
  dataPrenha?: string;
  dataDesmamaPrevista?: string;
  motivoMorte?: string;
  historicoPesos: PesoRegistro[];
  vacinas: VacinaRegistro[];
  ocorrenciasSaude: OcorrenciaSaude[];
  despesas: DespesaRegistro[];
  venda?: VendaInfo;
  createdAt: string;
  updatedAt: string;
}

export interface MilkProductionRecord {
  id: string;
  data: string;
  quantidade: number;
  numVacas: number;
  tipo: 'Vaca' | 'Búfala';
  observacoes?: string;
}

export interface UserSettings {
  nomeUsuario: string;
  nomePropriedade: string;
  cartaoProdutor: string;
  registroIMA: string;
  cotacaoLeiteVaca: number;
  cotacaoLeiteBufala: number;
}
