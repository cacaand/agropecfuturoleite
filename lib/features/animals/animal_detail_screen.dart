import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../database/database.dart';
import '../../main.dart';
import '../../shared/widgets/widgets.dart';

class AnimalDetailScreen extends ConsumerWidget {
  final String id;
  const AnimalDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(dbProvider);
    return StreamBuilder<List<Animal>>(
      stream: db.watchAnimals(),
      builder: (context, snap) {
        if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.green700)));
        final animal = snap.data!.where((a) => a.id == id).firstOrNull;
        if (animal == null) return Scaffold(
          appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
          body: const EmptyState(icon: Icons.pets_rounded, title: 'Animal não encontrado', subtitle: 'Este animal pode ter sido removido'),
        );
        return DefaultTabController(
          length: 5,
          child: Scaffold(
            backgroundColor: AppColors.gray50,
            appBar: AppBar(
              backgroundColor: Colors.white, elevation: 0,
              leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppColors.gray700), onPressed: () => context.pop()),
              title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(animal.name ?? '#${animal.code}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.gray900)),
                Text('${animal.breed} · #${animal.code}', style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
              ]),
              actions: [
                IconButton(icon: const Icon(Icons.edit_rounded, color: AppColors.green700), onPressed: () => context.go('/animals/$id/edit')),
                IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red600), onPressed: () => _confirmDelete(context, db, animal)),
                const SizedBox(width: 8),
              ],
              bottom: const TabBar(
                isScrollable: true,
                labelColor: AppColors.green700, unselectedLabelColor: AppColors.gray500,
                indicatorColor: AppColors.green700, indicatorWeight: 2,
                labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                tabs: [Tab(text: 'Identificação'), Tab(text: 'Produção'), Tab(text: 'Reprodução'), Tab(text: 'Sanidade'), Tab(text: 'Vacinas')],
              ),
            ),
            body: TabBarView(children: [
              _IdentTab(animal: animal),
              _MilkTab(animalId: id, db: db),
              _ReproTab(animalId: id, db: db),
              _HealthTab(animalId: id, db: db),
              _VaccineTab(animalId: id, db: db),
            ]),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, AppDatabase db, Animal animal) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Arquivar animal'),
      content: Text('Deseja arquivar ${animal.name ?? "#${animal.code}"}? O histórico será mantido.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            await db.deleteAnimal(animal.id);
            if (context.mounted) { Navigator.pop(context); context.pop(); }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.red600),
          child: const Text('Arquivar'),
        ),
      ],
    ));
  }
}

// ─── TABS ─────────────────────────────────────────────────────────────────────

class _IdentTab extends StatelessWidget {
  final Animal animal;
  const _IdentTab({required this.animal});
  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200, width: 0.5)),
        child: Row(children: [
          Container(width: 60, height: 60,
            decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text('🐄', style: TextStyle(fontSize: 32)))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(animal.name ?? '#${animal.code}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900)),
            const SizedBox(height: 4),
            StatusBadge(animal.status),
          ])),
          if (animal.weight != null)
            Column(children: [
              Text('${animal.weight!.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.green700)),
              const Text('kg', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
            ]),
        ]),
      ),
      const SizedBox(height: 12),
      _Card('Identificação', [
        _Row('Código', '#${animal.code}'),
        _Row('Brinco', animal.earTag ?? '—'),
        _Row('Raça', animal.breed),
        _Row('Sexo', animal.sex == 'FEMALE' ? 'Fêmea' : 'Macho'),
        _Row('Categoria', _catLabel(animal.category)),
      ]),
      const SizedBox(height: 12),
      _Card('Datas', [
        _Row('Nascimento', animal.birthDate != null ? fmt.format(animal.birthDate!) : '—'),
        _Row('Idade', animal.birthDate != null
          ? '${((DateTime.now().difference(animal.birthDate!).inDays) / 365).floor()} anos' : '—'),
        _Row('Cadastro', fmt.format(animal.createdAt)),
      ]),
      if (animal.notes != null && animal.notes!.isNotEmpty) ...[
        const SizedBox(height: 12),
        _Card('Observações', [_Row('Nota', animal.notes!)]),
      ],
    ]);
  }
  String _catLabel(String c) => switch (c) {
    'DAIRY_COW' => 'Vaca Leiteira', 'HEIFER' => 'Novilha',
    'CALF' => 'Bezerra(o)', 'BULL' => 'Touro', 'DRY_COW' => 'Vaca Seca', _ => c,
  };
}

class _MilkTab extends StatelessWidget {
  final String animalId; final AppDatabase db;
  const _MilkTab({required this.animalId, required this.db});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MilkRecord>>(
      stream: db.watchMilkRecords(animalId: animalId),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.green700));
        final records = snap.data!;
        if (records.isEmpty) return const EmptyState(icon: Icons.water_drop_outlined,
          title: 'Sem registros de produção', subtitle: 'Adicione o primeiro registro de ordenha');
        final total = records.fold<double>(0, (s, r) => s + r.volume);
        final avg   = records.isNotEmpty ? total / records.length : 0.0;
        return ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            Expanded(child: _Mini('Total', '${records.length}', Icons.format_list_numbered_rounded, AppColors.green700)),
            const SizedBox(width: 12),
            Expanded(child: _Mini('Média/ordenha', '${avg.toStringAsFixed(1)}L', Icons.analytics_outlined, AppColors.blue600)),
          ]),
          const SizedBox(height: 12),
          ...records.take(30).map((r) => _MilkRow(r)),
        ]);
      },
    );
  }
}

class _ReproTab extends StatelessWidget {
  final String animalId; final AppDatabase db;
  const _ReproTab({required this.animalId, required this.db});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Reproduction>>(
      stream: db.watchReproductions(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.green700));
        final records = snap.data!.where((r) => r.animalId == animalId).toList();
        if (records.isEmpty) return const EmptyState(icon: Icons.favorite_outline,
          title: 'Sem registros reprodutivos', subtitle: 'Adicione inseminações e diagnósticos');
        return ListView(padding: const EdgeInsets.all(16), children: records.map((r) => _ReproRow(r)).toList());
      },
    );
  }
}

class _HealthTab extends StatelessWidget {
  final String animalId; final AppDatabase db;
  const _HealthTab({required this.animalId, required this.db});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<HealthEvent>>(
      stream: db.watchHealthEvents(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.green700));
        final records = snap.data!.where((h) => h.animalId == animalId).toList();
        if (records.isEmpty) return const EmptyState(icon: Icons.health_and_safety_outlined,
          title: 'Sem eventos de saúde', subtitle: 'O animal não possui registros veterinários');
        return ListView(padding: const EdgeInsets.all(16), children: records.map((h) => _HealthRow(h)).toList());
      },
    );
  }
}

class _VaccineTab extends StatelessWidget {
  final String animalId; final AppDatabase db;
  const _VaccineTab({required this.animalId, required this.db});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<VaccineRecord>>(
      stream: db.watchVaccineRecords(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.green700));
        final records = snap.data!.where((v) => v.animalId == animalId).toList();
        if (records.isEmpty) return const EmptyState(icon: Icons.vaccines_outlined,
          title: 'Sem vacinas registradas', subtitle: 'Registre as vacinas aplicadas');
        return ListView(padding: const EdgeInsets.all(16), children: records.map((v) => _VaccineRow(v)).toList());
      },
    );
  }
}

// ─── ROW WIDGETS ─────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title; final List<Widget> rows;
  const _Card(this.title, this.rows);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.gray200, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700)),
      const SizedBox(height: 10),
      ...rows,
    ]),
  );
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.gray500))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray800))),
    ]),
  );
}

class _Mini extends StatelessWidget {
  final String label, value; final IconData icon; final Color color;
  const _Mini(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.gray200, width: 0.5)),
    child: Row(children: [
      Icon(icon, color: color, size: 20), const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
      ]),
    ]),
  );
}

class _MilkRow extends StatelessWidget {
  final MilkRecord r; const _MilkRow(this.r);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.gray200, width: 0.5)),
    child: Row(children: [
      const Icon(Icons.water_drop_rounded, color: AppColors.blue600, size: 16), const SizedBox(width: 8),
      Text(DateFormat('dd/MM').format(r.date), style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
      const SizedBox(width: 6),
      Text(_shift(r.shift), style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
      const Spacer(),
      Text('${r.volume.toStringAsFixed(1)} L', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.blue600)),
    ]),
  );
  String _shift(String s) => switch (s) { 'MORNING' => 'Manhã', 'AFTERNOON' => 'Tarde', _ => 'Noite' };
}

class _ReproRow extends StatelessWidget {
  final Reproduction r; const _ReproRow(this.r);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.gray200, width: 0.5)),
    child: Row(children: [
      const Icon(Icons.favorite_rounded, color: AppColors.purple600, size: 16), const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(r.type, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        if (r.sireName != null) Text('Touro: ${r.sireName}', style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
      ])),
      Text(DateFormat('dd/MM/yy').format(r.date), style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
    ]),
  );
}

class _HealthRow extends StatelessWidget {
  final HealthEvent h; const _HealthRow(this.h);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.gray200, width: 0.5)),
    child: Row(children: [
      const Icon(Icons.local_hospital_rounded, color: AppColors.red600, size: 16), const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(h.type, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        if (h.diagnosis != null) Text(h.diagnosis!, style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
        if (h.medication != null) Text(h.medication!, style: const TextStyle(fontSize: 11, color: AppColors.blue600)),
      ])),
      Text(DateFormat('dd/MM/yy').format(h.date), style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
    ]),
  );
}

class _VaccineRow extends StatelessWidget {
  final VaccineRecord v; const _VaccineRow(this.v);
  @override
  Widget build(BuildContext context) {
    final overdue = v.nextDose != null && v.nextDose!.isBefore(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: overdue ? AppColors.red50 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: overdue ? AppColors.red600.withOpacity(0.3) : AppColors.gray200, width: 0.5)),
      child: Row(children: [
        Icon(Icons.vaccines_rounded, color: overdue ? AppColors.red600 : AppColors.green700, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(v.vaccineName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          if (v.nextDose != null)
            Text(overdue ? 'VENCIDA — ${DateFormat("dd/MM/yy").format(v.nextDose!)}' : 'Próxima: ${DateFormat("dd/MM/yy").format(v.nextDose!)}',
              style: TextStyle(fontSize: 11, color: overdue ? AppColors.red600 : AppColors.green700)),
        ])),
        Text(DateFormat('dd/MM/yy').format(v.date), style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
      ]),
    );
  }
}
