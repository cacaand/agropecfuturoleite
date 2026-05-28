import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../database/database.dart';
import '../../main.dart';
import '../../shared/widgets/widgets.dart';

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(dbProvider);
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, toolbarHeight: 64,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Estoque', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900)),
          Text('Medicamentos, insumos e equipamentos', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
        ]),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showAdd(context, db),
            icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Adicionar'),
          ),
          const SizedBox(width: 16),
        ],
        bottom: const PreferredSize(preferredSize: Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: AppColors.gray200)),
      ),
      body: StreamBuilder<List<StockItem>>(
        stream: db.watchStock(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.green700));
          final items = snap.data!;
          final lowStock = items.where((s) => s.minQuantity != null && s.quantity <= s.minQuantity!).toList();

          return ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [
              Expanded(child: StatCard(label: 'Total de itens', value: '${items.length}',
                icon: Icons.inventory_2_rounded, iconColor: AppColors.green700, iconBg: AppColors.green50, accentColor: AppColors.green700)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(label: 'Estoque baixo', value: '${lowStock.length}',
                icon: Icons.warning_amber_rounded, iconColor: AppColors.red600, iconBg: AppColors.red50, accentColor: AppColors.red600)),
            ]),
            const SizedBox(height: 16),
            if (lowStock.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: AppColors.red50, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.red600.withOpacity(0.3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Icon(Icons.warning_rounded, color: AppColors.red600, size: 16), SizedBox(width: 6),
                    Text('Itens com estoque crítico:', style: TextStyle(color: AppColors.red600, fontWeight: FontWeight.w600, fontSize: 13)),
                  ]),
                  const SizedBox(height: 6),
                  ...lowStock.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('• ${s.name} — ${s.quantity.toStringAsFixed(1)} ${s.unit} (mín: ${s.minQuantity?.toStringAsFixed(1)})',
                      style: const TextStyle(fontSize: 12, color: AppColors.red600)))),
                ]),
              ),
            ],
            SectionHeader(title: 'Todos os itens (${items.length})'),
            if (items.isEmpty)
              const EmptyState(icon: Icons.inventory_2_outlined, title: 'Estoque vazio', subtitle: 'Adicione medicamentos e insumos')
            else
              ...items.map((item) => _StockCard(item)),
          ]);
        },
      ),
    );
  }

  void _showAdd(BuildContext context, AppDatabase db) {
    String category = 'MEDICINE';
    final nameCtrl     = TextEditingController();
    final unitCtrl     = TextEditingController(text: 'unidade');
    final qtyCtrl      = TextEditingController();
    final minCtrl      = TextEditingController();
    final costCtrl     = TextEditingController();
    final supplierCtrl = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Adicionar ao Estoque', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: category,
              decoration: InputDecoration(labelText: 'Categoria', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              items: const [
                DropdownMenuItem(value: 'MEDICINE',  child: Text('💊 Medicamento')),
                DropdownMenuItem(value: 'VACCINE',   child: Text('💉 Vacina')),
                DropdownMenuItem(value: 'FEED',      child: Text('🌾 Alimentação')),
                DropdownMenuItem(value: 'EQUIPMENT', child: Text('🔧 Equipamento')),
                DropdownMenuItem(value: 'OTHER',     child: Text('📦 Outros')),
              ],
              onChanged: (v) => setState(() => category = v!),
            ),
            const SizedBox(height: 10),
            _F(nameCtrl, 'Nome do item *', 'Ex: Oxitetraciclina 200mg'),
            Row(children: [
              Expanded(child: _F(qtyCtrl, 'Quantidade *', '10', type: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: _F(unitCtrl, 'Unidade', 'frasco, kg, L')),
            ]),
            Row(children: [
              Expanded(child: _F(minCtrl, 'Estoque mínimo', '5', type: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: _F(costCtrl, 'Custo unit. (R\$)', '45.00', type: TextInputType.number)),
            ]),
            _F(supplierCtrl, 'Fornecedor', 'Opcional'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || qtyCtrl.text.isEmpty) return;
                await db.insertStockItem({
                  'name':        nameCtrl.text.trim(),
                  'category':    category,
                  'unit':        unitCtrl.text.trim().isEmpty ? 'unidade' : unitCtrl.text.trim(),
                  'quantity':    double.tryParse(qtyCtrl.text) ?? 0,
                  'minQuantity': minCtrl.text.isEmpty ? null : double.tryParse(minCtrl.text),
                  'costPerUnit': costCtrl.text.isEmpty ? null : double.tryParse(costCtrl.text),
                  'supplier':    supplierCtrl.text.isEmpty ? null : supplierCtrl.text.trim(),
                });
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: const Text('Adicionar ao estoque'),
            ),
          ])),
        ),
      ),
    );
  }
}

Widget _F(TextEditingController ctrl, String label, String hint, {TextInputType type = TextInputType.text}) =>
  Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: ctrl, keyboardType: type,
    decoration: InputDecoration(labelText: label, hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))));

class _StockCard extends StatelessWidget {
  final StockItem item; const _StockCard(this.item);
  @override
  Widget build(BuildContext context) {
    final isLow = item.minQuantity != null && item.quantity <= item.minQuantity!;
    final (icon, color, bg) = switch (item.category) {
      'MEDICINE'  => (Icons.medication_rounded,   AppColors.red600,   AppColors.red50),
      'VACCINE'   => (Icons.vaccines_rounded,      AppColors.purple600,AppColors.purple100),
      'FEED'      => (Icons.grass_rounded,         AppColors.green700, AppColors.green50),
      'EQUIPMENT' => (Icons.build_rounded,         AppColors.blue600,  AppColors.blue50),
      _           => (Icons.inventory_2_rounded,   AppColors.gray600,  AppColors.gray100),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isLow ? AppColors.red600.withOpacity(0.3) : AppColors.gray200, width: 0.5)),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray900))),
            if (isLow) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: AppColors.red50, borderRadius: BorderRadius.circular(10)),
              child: const Text('Baixo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.red600))),
          ]),
          Text('${item.category.toLowerCase()} · ${item.supplier ?? "—"}',
            style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
          if (item.minQuantity != null) ...[
            const SizedBox(height: 5),
            ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(
              value: (item.quantity / (item.minQuantity! * 2)).clamp(0.0, 1.0),
              backgroundColor: AppColors.gray100,
              valueColor: AlwaysStoppedAnimation(isLow ? AppColors.red600 : AppColors.green600),
              minHeight: 4)),
          ],
        ])),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)} ${item.unit}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isLow ? AppColors.red600 : AppColors.gray800)),
          if (item.costPerUnit != null)
            Text('R\$ ${item.costPerUnit!.toStringAsFixed(2)}/un', style: const TextStyle(fontSize: 10, color: AppColors.gray400)),
        ]),
      ]),
    );
  }
}
