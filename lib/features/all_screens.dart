import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../core/security.dart';
import '../database/database.dart';
import '../main.dart';
import '../shared/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

// ─── REPRODUCTION ─────────────────────────────────────────────────────────────

class ReproductionScreen extends ConsumerWidget {
  const ReproductionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(dbProvider);
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, toolbarHeight: 64,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reprodução', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900)),
          Text('Inseminação, partos e diagnósticos', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
        ]),
        actions: [
          ElevatedButton.icon(onPressed: () => _addRepro(context, db),
            icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Registrar')),
          const SizedBox(width: 16),
        ],
        bottom: const PreferredSize(preferredSize: Size.fromHeight(0.5), child: Divider(height: 0.5, color: AppColors.gray200)),
      ),
      body: StreamBuilder<List<Reproduction>>(
        stream: db.watchReproductions(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.green700));
          final records = snap.data!;
          final pregnant = records.where((r) => r.status == 'CONFIRMED_PREGNANT').length;
          final pending  = records.where((r) => r.status == 'PENDING').length;
          return ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [
              Expanded(child: StatCard(label: 'Prenhas confirmadas', value: '$pregnant', icon: Icons.favorite_rounded, iconColor: AppColors.purple600, iconBg: AppColors.purple100, accentColor: AppColors.purple600)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(label: 'Aguardando DG', value: '$pending', icon: Icons.pending_rounded, iconColor: AppColors.amber500, iconBg: AppColors.amber50, accentColor: AppColors.amber500)),
            ]),
            const SizedBox(height: 20),
            SectionHeader(title: 'Eventos (${records.length})'),
            if (records.isEmpty)
              const EmptyState(icon: Icons.favorite_outline, title: 'Nenhum evento reprodutivo', subtitle: 'Registre inseminações, diagnósticos e partos')
            else
              ...records.map((r) => _ReproCard(r)),
          ]);
        },
      ),
    );
  }

  void _addRepro(BuildContext context, AppDatabase db) {
    String type = 'ARTIFICIAL_INSEMINATION', animalId = '';
    final sireCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Registrar Evento Reprodutivo', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          StreamBuilder<List<Animal>>(
            stream: db.watchAnimals(),
            builder: (ctx2, snap) {
              final animals = (snap.data ?? <Animal>[]).where((a) => a.sex == 'FEMALE').toList();
              return DropdownButtonFormField<String>(
                value: animalId.isEmpty ? null : animalId,
                hint: const Text('Selecionar animal'),
                decoration: InputDecoration(labelText: 'Animal', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                items: animals.map((a) => DropdownMenuItem<String>(value: a.id, child: Text(a.name ?? '#${a.code}'))).toList(),
                onChanged: (v) => ss(() => animalId = v ?? ''));
            }),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: type,
            decoration: InputDecoration(labelText: 'Tipo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            items: const [
              DropdownMenuItem(value: 'ARTIFICIAL_INSEMINATION', child: Text('Inseminação Artificial')),
              DropdownMenuItem(value: 'IATF',           child: Text('IATF')),
              DropdownMenuItem(value: 'NATURAL_MATING', child: Text('Monta Natural')),
              DropdownMenuItem(value: 'EMBRYO_TRANSFER',child: Text('Transferência de Embrião')),
            ],
            onChanged: (v) => ss(() => type = v!)),
          const SizedBox(height: 12),
          TextField(controller: sireCtrl,
            decoration: InputDecoration(labelText: 'Nome do touro', hintText: 'Opcional', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (animalId.isEmpty) return;
              final now = DateTime.now();
              await db.insertReproduction({
                'animalId': animalId, 'type': type, 'status': 'PENDING',
                'date': now.toIso8601String(),
                'expectedBirth': now.add(const Duration(days: 283)).toIso8601String(),
                'sireName': AppSecurity.sanitize(sireCtrl.text),
              });
              AppSecurity.logEvent('INSERT_REPRODUCTION', detail: 'animal:$animalId');
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            child: const Text('Salvar')),
        ]),
      )),
    );
  }
}

class _ReproCard extends StatelessWidget {
  final Reproduction r; const _ReproCard(this.r);
  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final (label, color) = switch (r.status) {
      'CONFIRMED_PREGNANT' => ('Prenhe ✓', AppColors.green700),
      'OPEN'   => ('Vazia', AppColors.red600),
      'CALVED' => ('Parto', AppColors.blue600),
      _        => ('Aguardando', AppColors.amber500),
    };
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.favorite_rounded, color: AppColors.purple600, size: 16), const SizedBox(width: 6),
          Text(_typeLabel(r.type), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color))),
        ]),
        const SizedBox(height: 6),
        Text('Data: ${fmt.format(r.date)}', style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
        if (r.sireName != null) Text('Touro: ${r.sireName}', style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
        if (r.expectedBirth != null)
          Text('Parto previsto: ${fmt.format(r.expectedBirth!)}',
            style: const TextStyle(fontSize: 12, color: AppColors.purple600, fontWeight: FontWeight.w500)),
      ]));
  }
  String _typeLabel(String t) => switch (t) {
    'ARTIFICIAL_INSEMINATION' => 'Inseminação Artificial',
    'IATF'             => 'IATF',
    'NATURAL_MATING'   => 'Monta Natural',
    'EMBRYO_TRANSFER'  => 'Transferência de Embrião',
    _ => t,
  };
}

// ─── HEALTH ───────────────────────────────────────────────────────────────────

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(dbProvider);
    return DefaultTabController(length: 2, child: Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, toolbarHeight: 64,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sanidade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900)),
          Text('Saúde animal e vacinação', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
        ]),
        actions: [
          ElevatedButton.icon(onPressed: () => _addHealth(context, db),
            icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Registrar')),
          const SizedBox(width: 16),
        ],
        bottom: const TabBar(
          labelColor: AppColors.green700, unselectedLabelColor: AppColors.gray500, indicatorColor: AppColors.green700,
          tabs: [Tab(text: 'Eventos de Saúde'), Tab(text: 'Vacinas')]),
      ),
      body: TabBarView(children: [
        StreamBuilder<List<HealthEvent>>(
          stream: db.watchHealthEvents(),
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.green700));
            final events = snap.data!;
            if (events.isEmpty) return const EmptyState(icon: Icons.health_and_safety_outlined, title: 'Nenhum evento', subtitle: 'Registre doenças e tratamentos');
            return ListView.builder(padding: const EdgeInsets.all(16), itemCount: events.length, itemBuilder: (_, i) => _HealthCard(events[i]));
          }),
        StreamBuilder<List<VaccineRecord>>(
          stream: db.watchVaccineRecords(),
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.green700));
            final records = snap.data!;
            final overdue = records.where((r) => r.nextDose != null && r.nextDose!.isBefore(DateTime.now())).length;
            return ListView(padding: const EdgeInsets.all(16), children: [
              if (overdue > 0) Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: AppColors.red50, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.red600.withOpacity(0.3))),
                child: Row(children: [const Icon(Icons.warning_rounded, color: AppColors.red600, size: 18), const SizedBox(width: 8), Text('$overdue vacinas vencidas!', style: const TextStyle(color: AppColors.red600, fontWeight: FontWeight.w600))])),
              if (records.isEmpty) const EmptyState(icon: Icons.vaccines_outlined, title: 'Nenhuma vacina', subtitle: 'Registre vacinas aplicadas')
              else ...records.map((r) => _VaccineCard(r)),
            ]);
          }),
      ]),
    ));
  }

  void _addHealth(BuildContext context, AppDatabase db) {
    String type = 'DISEASE', animalId = '';
    final diagCtrl = TextEditingController();
    final medCtrl  = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Registrar Evento de Saúde', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          StreamBuilder<List<Animal>>(
            stream: db.watchAnimals(),
            builder: (ctx2, snap) {
              final animals = snap.data ?? <Animal>[];
              return DropdownButtonFormField<String>(
                value: animalId.isEmpty ? null : animalId,
                hint: const Text('Selecionar animal'),
                decoration: InputDecoration(labelText: 'Animal', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                items: animals.map((a) => DropdownMenuItem<String>(value: a.id, child: Text(a.name ?? '#${a.code}'))).toList(),
                onChanged: (v) => ss(() => animalId = v ?? ''));
            }),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: type,
            decoration: InputDecoration(labelText: 'Tipo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            items: const [
              DropdownMenuItem(value: 'DISEASE',     child: Text('Doença')),
              DropdownMenuItem(value: 'MASTITIS',    child: Text('Mastite')),
              DropdownMenuItem(value: 'INJURY',      child: Text('Lesão')),
              DropdownMenuItem(value: 'TREATMENT',   child: Text('Tratamento')),
              DropdownMenuItem(value: 'EXAMINATION', child: Text('Exame')),
            ],
            onChanged: (v) => ss(() => type = v!)),
          const SizedBox(height: 12),
          TextField(controller: diagCtrl, decoration: InputDecoration(labelText: 'Diagnóstico', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 10),
          TextField(controller: medCtrl, decoration: InputDecoration(labelText: 'Medicamento', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (animalId.isEmpty) return;
              await db.insertHealthEvent({
                'animalId': animalId, 'type': type,
                'date': DateTime.now().toIso8601String(),
                'diagnosis': AppSecurity.sanitize(diagCtrl.text),
                'medication': AppSecurity.sanitize(medCtrl.text),
              });
              AppSecurity.logEvent('INSERT_HEALTH', detail: 'animal:$animalId type:$type');
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            child: const Text('Salvar')),
        ]),
      )),
    );
  }
}

class _HealthCard extends StatelessWidget {
  final HealthEvent h; const _HealthCard(this.h);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gray200, width: 0.5)),
    child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.red50, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.local_hospital_rounded, color: AppColors.red600, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(h.type, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        if (h.diagnosis != null) Text(h.diagnosis!, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
        if (h.medication != null) Text(h.medication!, style: const TextStyle(fontSize: 12, color: AppColors.blue600)),
      ])),
      Text(DateFormat('dd/MM/yy').format(h.date), style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
    ]));
}

class _VaccineCard extends StatelessWidget {
  final VaccineRecord v; const _VaccineCard(this.v);
  @override
  Widget build(BuildContext context) {
    final overdue = v.nextDose != null && v.nextDose!.isBefore(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: overdue ? AppColors.red50 : Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: overdue ? AppColors.red600.withOpacity(0.4) : AppColors.gray200, width: 0.5)),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: overdue ? AppColors.red50 : AppColors.green50, borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.vaccines_rounded, color: overdue ? AppColors.red600 : AppColors.green700, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(v.vaccineName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(v.disease, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
          if (v.nextDose != null)
            Text(overdue ? '⚠ Vencida em ${DateFormat("dd/MM/yy").format(v.nextDose!)}' : 'Próxima: ${DateFormat("dd/MM/yy").format(v.nextDose!)}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: overdue ? AppColors.red600 : AppColors.green700)),
        ])),
        Text(DateFormat('dd/MM/yy').format(v.date), style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
      ]));
  }
}

// ─── FINANCE ──────────────────────────────────────────────────────────────────

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db       = ref.read(dbProvider);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, toolbarHeight: 64,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Financeiro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900)),
          Text('Receitas, despesas e fluxo de caixa', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
        ]),
        actions: [
          ElevatedButton.icon(onPressed: () => _addFinance(context, db, currency),
            icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Lançar')),
          const SizedBox(width: 16),
        ],
        bottom: const PreferredSize(preferredSize: Size.fromHeight(0.5), child: Divider(height: 0.5, color: AppColors.gray200)),
      ),
      body: FutureBuilder<Map<String,double>>(
        future: db.getMonthFinancials(),
        builder: (context, fin) => StreamBuilder<List<Finance>>(
          stream: db.watchFinances(),
          builder: (context, snap) {
            final records = snap.data ?? <Finance>[];
            return ListView(padding: const EdgeInsets.all(16), children: [
              if (fin.hasData) ...[
                Row(children: [
                  Expanded(child: _FinCard('Receitas', currency.format(fin.data!['income']), AppColors.green700, Icons.trending_up_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _FinCard('Despesas', currency.format(fin.data!['expense']), AppColors.red600, Icons.trending_down_rounded)),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [(fin.data!['profit']??0)>=0 ? AppColors.green700 : AppColors.red600, (fin.data!['profit']??0)>=0 ? AppColors.green600 : AppColors.red600.withOpacity(0.8)]),
                    borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24), const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Lucro do mês', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(currency.format(fin.data!['profit']), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                    ]),
                  ])),
                const SizedBox(height: 20),
              ],
              SectionHeader(title: 'Lançamentos (${records.length})'),
              if (records.isEmpty)
                const EmptyState(icon: Icons.account_balance_wallet_outlined, title: 'Nenhum lançamento', subtitle: 'Registre receitas e despesas')
              else
                ...records.map((r) => _FinanceTile(r, currency)),
            ]);
          }),
      ),
    );
  }

  void _addFinance(BuildContext context, AppDatabase db, NumberFormat currency) {
    String type = 'INCOME', category = 'MILK_SALE';
    final descCtrl   = TextEditingController();
    final amountCtrl = TextEditingController();
    
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Text('Novo Lançamento', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TypeBtn('Receita', Icons.add_circle_rounded, type == 'INCOME', AppColors.green700, () {
                      ss(() { type = 'INCOME'; category = 'MILK_SALE'; });
                    }),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TypeBtn('Despesa', Icons.remove_circle_rounded, type == 'EXPENSE', AppColors.red600, () {
                      ss(() { type = 'EXPENSE'; category = 'FEED'; });
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  labelText: 'Categoria', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: (type == 'INCOME'
                  ? {'MILK_SALE':'🥛 Venda de leite','ANIMAL_SALE':'🐄 Venda de animais','OTHER':'Outros'}
                  : {'FEED':'🌾 Alimentação','VETERINARY':'🏥 Veterinário','VACCINES':'💉 Vacinas','LABOR':'👤 Mão de obra','OTHER':'Outros'}
                ).entries.map((e) => DropdownMenuItem<String>(value: e.key, child: Text(e.value))).toList(),
                onChanged: (v) => ss(() => category = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl, 
                decoration: InputDecoration(
                  labelText: 'Descrição', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl, 
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Valor (R\$)', 
                  hintText: '1500.00', 
                  prefixText: 'R\$ ', 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (descCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
                  final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;
                  if (amount <= 0 || amount > 9999999) { 
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Valor inválido')),
                    );
                    return;
                  }
                  await db.insertFinance({
                    'type': type, 
                    'category': category,
                    'description': AppSecurity.sanitize(descCtrl.text),
                    'amount': amount, 
                    'date': DateTime.now().toIso8601String(), 
                    'status': 'PAID',
                  });
                  AppSecurity.logEvent('INSERT_FINANCE', detail: 'type:$type amount:$amount');
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                child: const Text('Salvar lançamento'),
              ),
            ],
          ),
        ),
      ),
    );
}
}
class _TypeBtn extends StatelessWidget {
  final String label; final IconData icon; final bool active; final Color color; final VoidCallback onTap;
  const _TypeBtn(this.label, this.icon, this.active, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap,
    child: Container(padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: active ? color.withOpacity(0.08) : AppColors.gray100, borderRadius: BorderRadius.circular(10), border: Border.all(color: active ? color : Colors.transparent)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: active ? color : AppColors.gray400, size: 18), const SizedBox(width: 6),
        Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: active ? color : AppColors.gray400)),
      ]))));
}

class _FinCard extends StatelessWidget {
  final String label, value; final Color color; final IconData icon;
  const _FinCard(this.label, this.value, this.color, this.icon);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: color, size: 16), const SizedBox(width: 5), Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500))]),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
    ]));
}

class _FinanceTile extends StatelessWidget {
  final Finance r; final NumberFormat currency;
  const _FinanceTile(this.r, this.currency);
  @override
  Widget build(BuildContext context) {
    final isIncome = r.type == 'INCOME';
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.gray200, width: 0.5)),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: isIncome ? AppColors.green50 : AppColors.red50, borderRadius: BorderRadius.circular(10)),
          child: Icon(isIncome ? Icons.add_rounded : Icons.remove_rounded, color: isIncome ? AppColors.green700 : AppColors.red600, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(r.category.toLowerCase().replaceAll('_', ' '), style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(currency.format(r.amount), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isIncome ? AppColors.green700 : AppColors.red600)),
          Text(DateFormat('dd/MM').format(r.date), style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
        ]),
      ]));
  }
}

// ─── SETTINGS ─────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<SettingsScreen> {
  bool _pinSet = false;

  @override
  void initState() { super.initState(); _loadPin(); }

  Future<void> _loadPin() async {
    final set = await AppSecurity.isPinSet();
    if (mounted) setState(() => _pinSet = set);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.gray50,
    appBar: AppBar(
      backgroundColor: Colors.white, elevation: 0, toolbarHeight: 64,
      title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Configurações', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900)),
        Text('Preferências do sistema', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
      ]),
      bottom: const PreferredSize(preferredSize: Size.fromHeight(0.5), child: Divider(height: 0.5, color: AppColors.gray200))),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      // Subscription CTA
      GestureDetector(
        onTap: () => context.go('/subscription'),
        child: Container(
          padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.green900, AppColors.green700]),
            borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Trial — 13 dias restantes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              Text('Assine agora e economize até 28%', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: const Text('Ver planos', style: TextStyle(color: AppColors.green700, fontWeight: FontWeight.w700, fontSize: 12))),
          ])),
      ),

      // Security
      _SCard('🔒 Segurança', [
        SwitchListTile(
          title: const Text('PIN de proteção', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          subtitle: Text(_pinSet ? 'Ativo — app bloqueado automaticamente' : 'Inativo — toque para ativar',
            style: TextStyle(fontSize: 11, color: _pinSet ? AppColors.green700 : AppColors.gray400)),
          value: _pinSet, activeColor: AppColors.green700,
          onChanged: (v) => v ? _setupPin() : _removePin()),
        if (_pinSet) ListTile(
          title: const Text('Alterar PIN', style: TextStyle(fontSize: 13)),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
          onTap: _setupPin),
        ListTile(
          title: const Text('Log de auditoria', style: TextStyle(fontSize: 13)),
          subtitle: const Text('Ver histórico de ações', style: TextStyle(fontSize: 11, color: AppColors.gray400)),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
          onTap: () => _showAuditLog(context)),
      ]),
      const SizedBox(height: 12),

      _SCard('Fazenda', [
        _STile(Icons.agriculture_rounded, 'Nome da fazenda', 'Fazenda Santa Maria'),
        _STile(Icons.location_on_rounded,  'Localização', 'Goiás, Brasil'),
        _STile(Icons.people_rounded,       'Usuários ativos', '3'),
      ]),
      const SizedBox(height: 12),

      _SCard('Sistema', [
        _STile(Icons.info_outline_rounded, 'Versão',        'GadoLeite ERP v1.0.0'),
        _STile(Icons.code_rounded,         'Desenvolvedor', 'IAmina'),
        _STile(Icons.storage_rounded,      'Armazenamento', 'Local + Criptografado'),
        _STile(Icons.devices_rounded,      'Plataformas',   'Web · Windows · Android'),
        _STile(Icons.security_rounded,     'Segurança',     'SHA-256 · TLS 1.3'),
      ]),
      const SizedBox(height: 32),
      const Center(child: Text('Desenvolvido por IAmina · GadoLeite ERP v1.0\n© 2025 IAmina Software. Todos os direitos reservados.',
        textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.gray400))),
    ]),
  );

  Future<void> _setupPin() async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => PinSetupScreen(onDone: () { Navigator.pop(context); _loadPin(); })));
  }

  Future<void> _removePin() async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Remover PIN'),
      content: const Text('Tem certeza? O app ficará sem proteção.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.red600),
          child: const Text('Remover')),
      ]));
    if (ok == true) {
      await AppSecurity.removePin();
      AppSecurity.logEvent('PIN_REMOVED');
      await _loadPin();
    }
  }

  Future<void> _showAuditLog(BuildContext context) async {
    final logs = await AppSecurity.getAuditLog();
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(initialChildSize: 0.7, maxChildSize: 0.9, minChildSize: 0.4, expand: false,
        builder: (_, ctrl) => Column(children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.gray300, borderRadius: BorderRadius.circular(2))),
          const Padding(padding: EdgeInsets.all(16), child: Text('Log de Auditoria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
          Expanded(child: logs.isEmpty
            ? const Center(child: Text('Nenhum evento registrado', style: TextStyle(color: AppColors.gray400)))
            : ListView.separated(controller: ctrl, itemCount: logs.length,
                separatorBuilder: (_, __) => const Divider(height: 0.5),
                itemBuilder: (_, i) {
                  final l = logs[i];
                  final dt = DateTime.tryParse(l['ts'] ?? '');
                  return ListTile(dense: true,
                    leading: const Icon(Icons.circle, size: 8, color: AppColors.green700),
                    title: Text(l['event'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    subtitle: Text(l['detail'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
                    trailing: Text(dt != null ? DateFormat('dd/MM HH:mm').format(dt) : '', style: const TextStyle(fontSize: 10, color: AppColors.gray400)));
                })),
        ])));
  }
}

class _SCard extends StatelessWidget {
  final String title; final List<Widget> children;
  const _SCard(this.title, this.children);
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gray200, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16,14,16,6),
        child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700))),
      ...children,
    ]));
}

class _STile extends StatelessWidget {
  final IconData icon; final String label, value;
  const _STile(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
    child: Row(children: [
      Icon(icon, size: 18, color: AppColors.green700), const SizedBox(width: 10),
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.gray600)), const Spacer(),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray800)),
    ]));
}
