import Dexie, { Table } from 'dexie';
import { Animal, UserSettings, MilkProductionRecord } from './types';

export class AgropecDatabase extends Dexie {
  animals!: Table<Animal>;
  settings!: Table<{ id: string; value: UserSettings }>;
  milkProduction!: Table<MilkProductionRecord>;

  constructor() {
    super('AgropecFuturoDB');
    this.version(2).stores({
      animals: 'id, status, raca, createdAt', // Indexed fields
      settings: 'id',
      milkProduction: 'id, data, tipo'
    });
  }
}

export const db = new AgropecDatabase();
