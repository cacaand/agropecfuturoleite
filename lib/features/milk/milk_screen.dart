import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../database/database.dart';
import '../../main.dart';
import '../../shared/widgets/widgets.dart';

class MilkScreen extends ConsumerWidget {
  const MilkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(dbProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, toolbarHeight: 64,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Produção Leiteira', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900)),
          Text('Controle de ordenha', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
        ]),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(context, db),
            icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Registrar'),
          ),
          const SizedBox(width: 16),
        ],
        bottom: const PreferredSize(preferredSize: Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: AppColors.gray200)),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([db.getMilkLast7Days(), db.getTodayMilkTotal()]),
        builder: (context, snap) {
          final milkChart = snap.hasData ? snap.data![0] as List<Map<String,dynamic>> : <Map<String,dynamic>>[];
          final todayTotal = snap.hasData ? snap.data![1] as double : 0.0;

          return ListView(padding: const EdgeInsets.all(16), children: [
            // Today hero
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.green700, AppColors.green600]),
                borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Icon(Icons.water_drop_rounded, color: Colors.white, size: 36),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${todayTotal.toStringAsFixed(0)}L',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                  const Text('produção hoje', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray200, width: 0.5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionHeader(title: 'Produção — 7 dias'),
                MiniBarChart(data: milkChart, barColor: AppColors.blue600, valueKey: 'volume', labelKey: 'day'),
              ]),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<MilkRecord>>(
              stream: db.watchMilkRecords(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.green700));
                final records = snap.data!;
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SectionHeader(title: 'Registros (${records.length})'),
                  if (records.isEmpty)
                    const EmptyState(icon: Icons.water_drop_outlined,
                      title: 'Sem registros', subtitle: 'Registre as ordenhas diárias')
                  else
                    ...records.take(50).map((r) => _MilkTile(r)),
                ]);
              },
            ),
          ]);
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, AppDatabase db) {
    final volCtrl = TextEditingController();
    String shift = 'MORNING';
    String? animalId;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Registrar Ordenha', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            StreamBuilder<List<Animal>>(
              stream: db.watchAnimals(status: 'ACTIVE', category: 'DAIRY_COW'),
              builder: (ctx2, snap) {
                final animals = snap.data ?? <Animal>[];
                return DropdownButtonFormField<String>(
                  value: animalId, hint: const Text('Selecionar animal'),
                  decoration: InputDecoration(labelText: 'Animal',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  items: animals.map((a) => DropdownMenuItem<String>(
                    value: a.id, child: Text('${a.name ?? a.code} — ${a.breed}'))).toList(),
                  onChanged: (v) => setState(() => animalId = v),
                );
              },
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: volCtrl, keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Volume (L)', hintText: '22.5',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<String>(
                value: shift,
                decoration: InputDecoration(labelText: 'Turno',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                items: const [
                  DropdownMenuItem(value: 'MORNING',   child: Text('Manhã')),
                  DropdownMenuItem(value: 'AFTERNOON', child: Text('Tarde')),
                  DropdownMenuItem(value: 'NIGHT',     child: Text('Noite')),
                ],
                onChanged: (v) => setState(() => shift = v!),
              )),
            ]),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (animalId == null || volCtrl.text.isEmpty) return;
                await db.insertMilkRecord({
                  'animalId': animalId,
                  'date': DateTime.now().toIso8601String(),
                  'shift': shift,
                  'volume': double.tryParse(volCtrl.text) ?? 0,
                });
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: const Text('Salvar registro'),
            ),
          ]),
        ),
      ),
    );
  }
}

class _MilkTile extends StatelessWidget {
  final MilkRecord r; const _MilkTile(this.r);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.gray200, width: 0.5)),
    child: Row(children: [
      const Icon(Icons.water_drop_rounded, color: AppColors.blue600, size: 16), const SizedBox(width: 8),
      Text(DateFormat('dd/MM HH:mm').format(r.date), style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
      const SizedBox(width: 8),
      Text(_shift(r.shift), style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
      const Spacer(),
      Text('${r.volume.toStringAsFixed(1)}L', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.blue600)),
    ]),
  );
  String _shift(String s) => switch (s) { 'MORNING' => '☀ Manhã', 'AFTERNOON' => '🌤 Tarde', _ => '🌙 Noite' };
}
