import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ─── MODELS ──────────────────────────────────────────────────────────────────

class Animal {
  final String id, code, breed, sex, category, status;
  final String? name, earTag, color, lotId, notes;
  final double? weight;
  final DateTime? birthDate;
  final DateTime createdAt;
  final bool isDeleted;

  Animal({
    required this.id, required this.code, required this.breed,
    required this.sex, required this.category, required this.status,
    this.name, this.earTag, this.color, this.lotId, this.notes,
    this.weight, this.birthDate, required this.createdAt, this.isDeleted = false,
  });

  factory Animal.fromMap(Map<String, dynamic> m) => Animal(
    id: m['id'], code: m['code'], breed: m['breed'],
    sex: m['sex'], category: m['category'], status: m['status'] ?? 'ACTIVE',
    name: m['name'], earTag: m['earTag'], color: m['color'],
    lotId: m['lotId'], notes: m['notes'],
    weight: m['weight'] != null ? (m['weight'] as num).toDouble() : null,
    birthDate: m['birthDate'] != null ? DateTime.tryParse(m['birthDate']) : null,
    createdAt: m['createdAt'] != null ? DateTime.tryParse(m['createdAt']) ?? DateTime.now() : DateTime.now(),
    isDeleted: m['isDeleted'] == true || m['isDeleted'] == 1,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'code': code, 'breed': breed, 'sex': sex,
    'category': category, 'status': status, 'name': name,
    'earTag': earTag, 'color': color, 'lotId': lotId, 'notes': notes,
    'weight': weight, 'birthDate': birthDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(), 'isDeleted': isDeleted,
  };
}

class MilkRecord {
  final String id, animalId, shift;
  final double volume;
  final double? fat, protein;
  final String? notes;
  final DateTime date, createdAt;

  MilkRecord({
    required this.id, required this.animalId, required this.shift,
    required this.volume, required this.date, required this.createdAt,
    this.fat, this.protein, this.notes,
  });

  factory MilkRecord.fromMap(Map<String, dynamic> m) => MilkRecord(
    id: m['id'], animalId: m['animalId'], shift: m['shift'],
    volume: (m['volume'] as num).toDouble(),
    fat: m['fat'] != null ? (m['fat'] as num).toDouble() : null,
    protein: m['protein'] != null ? (m['protein'] as num).toDouble() : null,
    notes: m['notes'],
    date: DateTime.parse(m['date']),
    createdAt: m['createdAt'] != null ? DateTime.tryParse(m['createdAt']) ?? DateTime.now() : DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'animalId': animalId, 'shift': shift, 'volume': volume,
    'fat': fat, 'protein': protein, 'notes': notes,
    'date': date.toIso8601String(), 'createdAt': createdAt.toIso8601String(),
  };
}

class Reproduction {
  final String id, animalId, type, status;
  final DateTime date;
  final DateTime? expectedBirth, actualBirth;
  final String? sireName, result, notes;

  Reproduction({
    required this.id, required this.animalId, required this.type,
    required this.status, required this.date,
    this.expectedBirth, this.actualBirth, this.sireName, this.result, this.notes,
  });

  factory Reproduction.fromMap(Map<String, dynamic> m) => Reproduction(
    id: m['id'], animalId: m['animalId'], type: m['type'],
    status: m['status'] ?? 'PENDING', date: DateTime.parse(m['date']),
    expectedBirth: m['expectedBirth'] != null ? DateTime.tryParse(m['expectedBirth']) : null,
    actualBirth: m['actualBirth'] != null ? DateTime.tryParse(m['actualBirth']) : null,
    sireName: m['sireName'], result: m['result'], notes: m['notes'],
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'animalId': animalId, 'type': type, 'status': status,
    'date': date.toIso8601String(),
    'expectedBirth': expectedBirth?.toIso8601String(),
    'actualBirth': actualBirth?.toIso8601String(),
    'sireName': sireName, 'result': result, 'notes': notes,
  };
}

class HealthEvent {
  final String id, animalId, type;
  final DateTime date;
  final String? diagnosis, treatment, medication, vet, notes;
  final double? cost;

  HealthEvent({
    required this.id, required this.animalId, required this.type,
    required this.date, this.diagnosis, this.treatment,
    this.medication, this.vet, this.notes, this.cost,
  });

  factory HealthEvent.fromMap(Map<String, dynamic> m) => HealthEvent(
    id: m['id'], animalId: m['animalId'], type: m['type'],
    date: DateTime.parse(m['date']),
    diagnosis: m['diagnosis'], treatment: m['treatment'],
    medication: m['medication'], vet: m['vet'], notes: m['notes'],
    cost: m['cost'] != null ? (m['cost'] as num).toDouble() : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'animalId': animalId, 'type': type,
    'date': date.toIso8601String(), 'diagnosis': diagnosis,
    'treatment': treatment, 'medication': medication,
    'vet': vet, 'notes': notes, 'cost': cost,
  };
}

class VaccineRecord {
  final String id, animalId, vaccineName, disease;
  final DateTime date;
  final DateTime? nextDose;
  final String? batch, notes;

  VaccineRecord({
    required this.id, required this.animalId, required this.vaccineName,
    required this.disease, required this.date, this.nextDose, this.batch, this.notes,
  });

  factory VaccineRecord.fromMap(Map<String, dynamic> m) => VaccineRecord(
    id: m['id'], animalId: m['animalId'], vaccineName: m['vaccineName'],
    disease: m['disease'], date: DateTime.parse(m['date']),
    nextDose: m['nextDose'] != null ? DateTime.tryParse(m['nextDose']) : null,
    batch: m['batch'], notes: m['notes'],
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'animalId': animalId, 'vaccineName': vaccineName,
    'disease': disease, 'date': date.toIso8601String(),
    'nextDose': nextDose?.toIso8601String(), 'batch': batch, 'notes': notes,
  };
}

class Finance {
  final String id, type, category, description, status;
  final double amount;
  final DateTime date;

  Finance({
    required this.id, required this.type, required this.category,
    required this.description, required this.status,
    required this.amount, required this.date,
  });

  factory Finance.fromMap(Map<String, dynamic> m) => Finance(
    id: m['id'], type: m['type'], category: m['category'],
    description: m['description'], status: m['status'] ?? 'PAID',
    amount: (m['amount'] as num).toDouble(),
    date: DateTime.parse(m['date']),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'type': type, 'category': category,
    'description': description, 'status': status,
    'amount': amount, 'date': date.toIso8601String(),
  };
}

class StockItem {
  final String id, name, category, unit;
  final double quantity;
  final double? minQuantity, costPerUnit;
  final String? supplier;

  StockItem({
    required this.id, required this.name, required this.category,
    required this.unit, required this.quantity,
    this.minQuantity, this.costPerUnit, this.supplier,
  });

  factory StockItem.fromMap(Map<String, dynamic> m) => StockItem(
    id: m['id'], name: m['name'], category: m['category'], unit: m['unit'],
    quantity: (m['quantity'] as num).toDouble(),
    minQuantity: m['minQuantity'] != null ? (m['minQuantity'] as num).toDouble() : null,
    costPerUnit: m['costPerUnit'] != null ? (m['costPerUnit'] as num).toDouble() : null,
    supplier: m['supplier'],
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'category': category, 'unit': unit,
    'quantity': quantity, 'minQuantity': minQuantity,
    'costPerUnit': costPerUnit, 'supplier': supplier,
  };
}

// ─── DATABASE ─────────────────────────────────────────────────────────────────

class AppDatabase {
  static AppDatabase? _instance;
  static AppDatabase get instance => _instance ??= AppDatabase._();
  AppDatabase._();

  SharedPreferences? _prefs;
  bool _initialized = false;

  // In-memory lists
  List<Animal>       _animals       = [];
  List<MilkRecord>   _milkRecords   = [];
  List<Reproduction> _reproductions = [];
  List<HealthEvent>  _healthEvents  = [];
  List<VaccineRecord>_vaccineRecs   = [];
  List<Finance>      _finances      = [];
  List<StockItem>    _stockItems    = [];

  // Stream controllers
  final _aniCtrl   = StreamController<List<Animal>>.broadcast();
  final _milkCtrl  = StreamController<List<MilkRecord>>.broadcast();
  final _reproCtrl = StreamController<List<Reproduction>>.broadcast();
  final _hlthCtrl  = StreamController<List<HealthEvent>>.broadcast();
  final _vaxCtrl   = StreamController<List<VaccineRecord>>.broadcast();
  final _finCtrl   = StreamController<List<Finance>>.broadcast();
  final _stckCtrl  = StreamController<List<StockItem>>.broadcast();

  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _loadAll();
    if (_animals.isEmpty) _seed();
    _initialized = true;
  }

  Future<void> close() async {}

  // ─── LOAD / SAVE ────────────────────────────────────────────────────────────

  void _loadAll() {
    _animals       = _load('animals',       Animal.fromMap);
    _milkRecords   = _load('milkRecords',   MilkRecord.fromMap);
    _reproductions = _load('reproductions', Reproduction.fromMap);
    _healthEvents  = _load('healthEvents',  HealthEvent.fromMap);
    _vaccineRecs   = _load('vaccineRecs',   VaccineRecord.fromMap);
    _finances      = _load('finances',      Finance.fromMap);
    _stockItems    = _load('stockItems',    StockItem.fromMap);
  }

  List<T> _load<T>(String key, T Function(Map<String,dynamic>) fromMap) {
    final s = _prefs?.getString(key);
    if (s == null || s.isEmpty) return [];
    try {
      return (jsonDecode(s) as List).map((m) => fromMap(Map<String,dynamic>.from(m))).toList();
    } catch (_) { return []; }
  }

  Future<void> _save(String key, List items) async {
    await _prefs?.setString(key, jsonEncode(items.map((i) => i.toMap()).toList()));
  }

  // ─── SEED ───────────────────────────────────────────────────────────────────

  void _seed() {
    final now = DateTime.now();
    _animals = [
      Animal(id:'a1', code:'0001', name:'Mimosa',  breed:'Holandesa', sex:'FEMALE', category:'DAIRY_COW', status:'ACTIVE',   weight:520, birthDate:DateTime(2019,3,15),  createdAt:now),
      Animal(id:'a2', code:'0002', name:'Estrela', breed:'Girolando', sex:'FEMALE', category:'DAIRY_COW', status:'PREGNANT', weight:490, birthDate:DateTime(2020,7,8),   createdAt:now),
      Animal(id:'a3', code:'0003', name:'Bonita',  breed:'Jersey',    sex:'FEMALE', category:'DAIRY_COW', status:'SICK',     weight:380, birthDate:DateTime(2018,11,20), createdAt:now),
      Animal(id:'a4', code:'0004', name:'Clarita', breed:'Holandesa', sex:'FEMALE', category:'CALF',      status:'ACTIVE',   weight:85,  birthDate:DateTime(2024,2,10),  createdAt:now),
    ];

    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      _milkRecords.add(MilkRecord(id:'m1_$i', animalId:'a1', shift:'MORNING', volume:22.5+(i%3)*1.2, date:d, createdAt:now));
      _milkRecords.add(MilkRecord(id:'m2_$i', animalId:'a2', shift:'MORNING', volume:18.0+(i%2)*0.8, date:d, createdAt:now));
    }

    _reproductions = [
      Reproduction(id:'r1', animalId:'a2', type:'ARTIFICIAL_INSEMINATION', status:'CONFIRMED_PREGNANT',
        date:now.subtract(const Duration(days:120)),
        expectedBirth:now.add(const Duration(days:163)), sireName:'Guerreiro FIV'),
    ];

    _healthEvents = [
      HealthEvent(id:'h1', animalId:'a3', type:'MASTITIS',
        date:now.subtract(const Duration(days:2)),
        diagnosis:'Mastite subclínica', medication:'Oxitetraciclina 200mg',
        treatment:'Antibiótico intramamário'),
    ];

    _vaccineRecs = [
      VaccineRecord(id:'v1', animalId:'a1', vaccineName:'Febre Aftosa', disease:'Febre Aftosa',
        date:now.subtract(const Duration(days:180)),
        nextDose:now.subtract(const Duration(days:20))),
    ];

    _finances = [
      Finance(id:'f1', type:'INCOME',  category:'MILK_SALE',   description:'Venda de leite — Mai/2025', amount:87240.00, date:now,                                   status:'PAID'),
      Finance(id:'f2', type:'EXPENSE', category:'FEED',        description:'Silagem de milho',           amount:28500.00, date:now.subtract(const Duration(days:5)),  status:'PAID'),
      Finance(id:'f3', type:'EXPENSE', category:'VETERINARY',  description:'Consulta veterinária',       amount:1200.00,  date:now.subtract(const Duration(days:3)),  status:'PAID'),
    ];

    _stockItems = [
      StockItem(id:'s1', name:'Oxitetraciclina 200mg', category:'MEDICINE',  unit:'frasco', quantity:5,    minQuantity:10),
      StockItem(id:'s2', name:'Silagem de Milho',       category:'FEED',      unit:'ton',    quantity:45.5, minQuantity:20),
      StockItem(id:'s3', name:'Vacina Febre Aftosa',    category:'VACCINE',   unit:'dose',   quantity:50,   minQuantity:20),
    ];

    _saveAll();
  }

  void _saveAll() {
    _save('animals',       _animals);
    _save('milkRecords',   _milkRecords);
    _save('reproductions', _reproductions);
    _save('healthEvents',  _healthEvents);
    _save('vaccineRecs',   _vaccineRecs);
    _save('finances',      _finances);
    _save('stockItems',    _stockItems);
  }

  String _uid() => '${DateTime.now().microsecondsSinceEpoch}_${_animals.length}';

  // ─── NOTIFY ─────────────────────────────────────────────────────────────────

  void _notifyAnimals()  { if (!_aniCtrl.isClosed)   _aniCtrl.add(_animals.where((a) => !a.isDeleted).toList()); }
  void _notifyMilk()     { if (!_milkCtrl.isClosed)  _milkCtrl.add(List.from(_milkRecords)); }
  void _notifyRepro()    { if (!_reproCtrl.isClosed) _reproCtrl.add(List.from(_reproductions)); }
  void _notifyHealth()   { if (!_hlthCtrl.isClosed)  _hlthCtrl.add(List.from(_healthEvents)); }
  void _notifyVaccines() { if (!_vaxCtrl.isClosed)   _vaxCtrl.add(List.from(_vaccineRecs)); }
  void _notifyFinance()  { if (!_finCtrl.isClosed)   _finCtrl.add(List.from(_finances)); }
  void _notifyStock()    { if (!_stckCtrl.isClosed)  _stckCtrl.add(List.from(_stockItems)); }

  // ─── STREAMS ────────────────────────────────────────────────────────────────

  Stream<List<Animal>> watchAnimals({String? status, String? category}) {
    Future.microtask(() {
      var list = _animals.where((a) => !a.isDeleted).toList();
      if (status   != null) list = list.where((a) => a.status   == status).toList();
      if (category != null) list = list.where((a) => a.category == category).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!_aniCtrl.isClosed) _aniCtrl.add(list);
    });
    return _aniCtrl.stream;
  }

  Stream<List<MilkRecord>> watchMilkRecords({String? animalId}) {
    Future.microtask(() {
      var list = List<MilkRecord>.from(_milkRecords);
      if (animalId != null) list = list.where((r) => r.animalId == animalId).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      if (!_milkCtrl.isClosed) _milkCtrl.add(list);
    });
    return _milkCtrl.stream;
  }

  Stream<List<Reproduction>> watchReproductions() {
    Future.microtask(() {
      final list = List<Reproduction>.from(_reproductions)..sort((a,b) => b.date.compareTo(a.date));
      if (!_reproCtrl.isClosed) _reproCtrl.add(list);
    });
    return _reproCtrl.stream;
  }

  Stream<List<HealthEvent>> watchHealthEvents() {
    Future.microtask(() {
      final list = List<HealthEvent>.from(_healthEvents)..sort((a,b) => b.date.compareTo(a.date));
      if (!_hlthCtrl.isClosed) _hlthCtrl.add(list);
    });
    return _hlthCtrl.stream;
  }

  Stream<List<VaccineRecord>> watchVaccineRecords() {
    Future.microtask(() {
      final list = List<VaccineRecord>.from(_vaccineRecs)..sort((a,b) => b.date.compareTo(a.date));
      if (!_vaxCtrl.isClosed) _vaxCtrl.add(list);
    });
    return _vaxCtrl.stream;
  }

  Stream<List<Finance>> watchFinances() {
    Future.microtask(() {
      final list = List<Finance>.from(_finances)..sort((a,b) => b.date.compareTo(a.date));
      if (!_finCtrl.isClosed) _finCtrl.add(list);
    });
    return _finCtrl.stream;
  }

  Stream<List<StockItem>> watchStock() {
    Future.microtask(() {
      final list = List<StockItem>.from(_stockItems)..sort((a,b) => a.name.compareTo(b.name));
      if (!_stckCtrl.isClosed) _stckCtrl.add(list);
    });
    return _stckCtrl.stream;
  }

  // ─── INSERT / UPDATE / DELETE ────────────────────────────────────────────────

  Future<void> insertAnimal(Map<String, dynamic> data) async {
    data['id'] ??= _uid();
    data['createdAt'] ??= DateTime.now().toIso8601String();
    data['isDeleted'] = false;
    _animals.add(Animal.fromMap(data));
    await _save('animals', _animals);
    _notifyAnimals();
  }

  Future<void> updateAnimal(String id, Map<String, dynamic> data) async {
    final idx = _animals.indexWhere((a) => a.id == id);
    if (idx < 0) return;
    final old = _animals[idx].toMap();
    old.addAll(data);
    _animals[idx] = Animal.fromMap(old);
    await _save('animals', _animals);
    _notifyAnimals();
  }

  Future<void> deleteAnimal(String id) async {
    final idx = _animals.indexWhere((a) => a.id == id);
    if (idx < 0) return;
    final old = _animals[idx].toMap();
    old['isDeleted'] = true;
    _animals[idx] = Animal.fromMap(old);
    await _save('animals', _animals);
    _notifyAnimals();
  }

  Future<void> insertMilkRecord(Map<String, dynamic> data) async {
    data['id'] ??= _uid();
    data['createdAt'] ??= DateTime.now().toIso8601String();
    _milkRecords.add(MilkRecord.fromMap(data));
    await _save('milkRecords', _milkRecords);
    _notifyMilk();
  }

  Future<void> insertReproduction(Map<String, dynamic> data) async {
    data['id'] ??= _uid();
    _reproductions.add(Reproduction.fromMap(data));
    await _save('reproductions', _reproductions);
    _notifyRepro();
  }

  Future<void> insertHealthEvent(Map<String, dynamic> data) async {
    data['id'] ??= _uid();
    _healthEvents.add(HealthEvent.fromMap(data));
    await _save('healthEvents', _healthEvents);
    _notifyHealth();
  }

  Future<void> insertVaccineRecord(Map<String, dynamic> data) async {
    data['id'] ??= _uid();
    _vaccineRecs.add(VaccineRecord.fromMap(data));
    await _save('vaccineRecs', _vaccineRecs);
    _notifyVaccines();
  }

  Future<void> insertFinance(Map<String, dynamic> data) async {
    data['id'] ??= _uid();
    _finances.add(Finance.fromMap(data));
    await _save('finances', _finances);
    _notifyFinance();
  }

  Future<void> insertStockItem(Map<String, dynamic> data) async {
    data['id'] ??= _uid();
    _stockItems.add(StockItem.fromMap(data));
    await _save('stockItems', _stockItems);
    _notifyStock();
  }

  // ─── STATS ──────────────────────────────────────────────────────────────────

  Future<Map<String, int>> getAnimalStats() async {
    final all = _animals.where((a) => !a.isDeleted).toList();
    return {
      'total':     all.length,
      'lactating': all.where((a) => a.status=='ACTIVE'   && a.category=='DAIRY_COW').length,
      'pregnant':  all.where((a) => a.status=='PREGNANT').length,
      'dry':       all.where((a) => a.status=='DRY').length,
      'calves':    all.where((a) => a.category=='CALF').length,
      'sick':      all.where((a) => a.status=='SICK').length,
    };
  }

  Future<double> getTodayMilkTotal() async {
    final today = DateTime.now();
    return _milkRecords
      .where((r) => r.date.year==today.year && r.date.month==today.month && r.date.day==today.day)
      .fold<double>(0, (s, r) => s + r.volume);
  }

  Future<List<Map<String, dynamic>>> getMilkLast7Days() async {
    final byDay = <String, double>{};
    final since = DateTime.now().subtract(const Duration(days: 7));
    for (final r in _milkRecords.where((r) => r.date.isAfter(since))) {
      final key = '${r.date.day}/${r.date.month}';
      byDay[key] = (byDay[key] ?? 0) + r.volume;
    }
    return byDay.entries.map((e) => {'day': e.key, 'volume': e.value}).toList();
  }

  Future<Map<String, double>> getMonthFinancials() async {
    final now = DateTime.now();
    double income = 0, expense = 0;
    for (final f in _finances.where((f) => f.date.year==now.year && f.date.month==now.month)) {
      if (f.type == 'INCOME') income += f.amount;
      else expense += f.amount;
    }
    return {'income': income, 'expense': expense, 'profit': income - expense};
  }

  Future<int> getPendingVaccines() async {
    final now = DateTime.now();
    return _vaccineRecs.where((v) => v.nextDose != null && v.nextDose!.isBefore(now)).length;
  }

  Future<int> getLowStockCount() async {
    return _stockItems.where((s) => s.minQuantity != null && s.quantity <= s.minQuantity!).length;
  }
}
