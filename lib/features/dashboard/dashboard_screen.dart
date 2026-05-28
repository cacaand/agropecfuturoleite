import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../database/database.dart';
import '../../main.dart';
import '../../shared/widgets/widgets.dart';

// Cache provider so dashboard loads instantly
final _dashDataProvider = FutureProvider<_DashData>((ref) async {
  final db = ref.read(dbProvider);
  final results = await Future.wait([
    db.getAnimalStats(),
    db.getTodayMilkTotal(),
    db.getMonthFinancials(),
    db.getPendingVaccines(),
    db.getLowStockCount(),
    db.getMilkLast7Days(),
  ]);
  return _DashData(
    stats:      results[0] as Map<String,int>,
    milkToday:  results[1] as double,
    finance:    results[2] as Map<String,double>,
    pendingVax: results[3] as int,
    lowStock:   results[4] as int,
    milkChart:  results[5] as List<Map<String,dynamic>>,
  );
});

class _DashData {
  final Map<String,int> stats;
  final double milkToday;
  final Map<String,double> finance;
  final int pendingVax, lowStock;
  final List<Map<String,dynamic>> milkChart;
  const _DashData({required this.stats, required this.milkToday, required this.finance,
    required this.pendingVax, required this.lowStock, required this.milkChart});
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final data = ref.watch(_dashDataProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: CustomScrollView(slivers: [
        // ── TopBar ──────────────────────────────────────────────
        SliverAppBar(
          pinned: true, backgroundColor: Colors.white, elevation: 0, toolbarHeight: 64,
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900)),
            Text('Fazenda Santa Maria · ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
              style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
          ]),
          actions: [
            _Ticker(label: 'Arroba', value: 'R\$ 312,40', up: true),
            _Ticker(label: 'Leite',  value: 'R\$ 2,87/L', up: false),
            const SizedBox(width: 8),
            Stack(children: [
              IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.gray600), onPressed: () {}),
              Positioned(right: 8, top: 8, child: Container(width: 8, height: 8,
                decoration: const BoxDecoration(color: AppColors.red600, shape: BoxShape.circle))),
            ]),
            Padding(padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(onTap: () => context.go('/settings'),
                child: const CircleAvatar(radius: 16, backgroundColor: AppColors.green700,
                  child: Text('JF', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))))),
          ],
          bottom: const PreferredSize(preferredSize: Size.fromHeight(0.5), child: Divider(height: 0.5, color: AppColors.gray200)),
        ),

        // ── Content ─────────────────────────────────────────────
        SliverToBoxAdapter(child: data.when(
          loading: () => const _DashSkeleton(),
          error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(40),
            child: Column(children: [
              const Icon(Icons.error_outline, color: AppColors.red600, size: 48),
              const SizedBox(height: 12),
              Text('Erro ao carregar: $e', style: const TextStyle(color: AppColors.gray600)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => ref.refresh(_dashDataProvider), child: const Text('Tentar novamente')),
            ]))),
          data: (d) => _DashContent(d: d, currency: currency),
        )),
      ]),
    );
  }
}

// ─── SKELETON LOADING ─────────────────────────────────────────────────────────

class _DashSkeleton extends StatefulWidget {
  const _DashSkeleton();
  @override
  State<_DashSkeleton> createState() => _DashSkeletonState();
}

class _DashSkeletonState extends State<_DashSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _anim, builder: (_, __) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Wrap(spacing: 8, children: List.generate(4, (_) => _SkBox(120, 40, _anim.value))),
        const SizedBox(height: 16),
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
          children: List.generate(6, (_) => _SkBox(double.infinity, 100, _anim.value))),
        const SizedBox(height: 16),
        _SkBox(double.infinity, 180, _anim.value),
        const SizedBox(height: 12),
        _SkBox(double.infinity, 220, _anim.value),
      ]),
    ));
  }
  Widget _SkBox(double w, double h, double opacity) => Container(
    width: w == double.infinity ? null : w, height: h,
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: AppColors.gray200.withOpacity(opacity),
      borderRadius: BorderRadius.circular(12)));
}

// ─── DASHBOARD CONTENT ────────────────────────────────────────────────────────

class _DashContent extends StatelessWidget {
  final _DashData d; final NumberFormat currency;
  const _DashContent({required this.d, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Alerts
        Wrap(spacing: 8, runSpacing: 8, children: [
          if ((d.stats['sick'] ?? 0) > 0)
            AlertPill(label: '${d.stats['sick']} doentes',       icon: Icons.emergency_rounded, color: AppColors.red600, bg: AppColors.red50,
              onTap: () => _go(context, '/health')),
          if (d.pendingVax > 0)
            AlertPill(label: '${ d.pendingVax} vacinas pendentes', icon: Icons.vaccines_rounded, color: AppColors.amber500, bg: AppColors.amber50,
              onTap: () => _go(context, '/health')),
          if (d.lowStock > 0)
            AlertPill(label: '${d.lowStock} estoque baixo',      icon: Icons.inventory_2_outlined, color: AppColors.blue600, bg: AppColors.blue50,
              onTap: () => _go(context, '/stock')),
          AlertPill(label: '4 partos previstos', icon: Icons.child_care_rounded, color: AppColors.purple600, bg: AppColors.purple100,
            onTap: () => _go(context, '/reproduction')),
        ]),
        const SizedBox(height: 20),

        // Trial banner
        _TrialBanner(),
        const SizedBox(height: 20),

        // KPI Grid
        const SectionHeader(title: 'Rebanho'),
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3,
          children: [
            StatCard(label: 'Total animais', value: '${d.stats['total']??0}',    icon: Icons.pets_rounded,                   iconColor: AppColors.green700, iconBg: AppColors.green50,   accentColor: AppColors.green700,  delta: '+12 mês',  onTap: () => _go(context,'/animals')),
            StatCard(label: 'Em lactação',   value: '${d.stats['lactating']??0}', icon: Icons.water_drop_rounded,             iconColor: AppColors.blue600,  iconBg: AppColors.blue50,    accentColor: AppColors.blue600,   delta: '+5',       onTap: () => _go(context,'/milk')),
            StatCard(label: 'Prenhas',       value: '${d.stats['pregnant']??0}',  icon: Icons.favorite_rounded,               iconColor: AppColors.purple600,iconBg: AppColors.purple100, accentColor: AppColors.purple600,              onTap: () => _go(context,'/reproduction')),
            StatCard(label: 'Doentes',       value: '${d.stats['sick']??0}',      icon: Icons.local_hospital_rounded,         iconColor: AppColors.red600,   iconBg: AppColors.red50,     accentColor: AppColors.red600,    deltaPositive:false, onTap: () => _go(context,'/health')),
            StatCard(label: 'Vacas secas',   value: '${d.stats['dry']??0}',       icon: Icons.bedtime_rounded,                iconColor: AppColors.amber500, iconBg: AppColors.amber50,   accentColor: AppColors.amber500,              onTap: () => _go(context,'/animals')),
            StatCard(label: 'Bezerros',      value: '${d.stats['calves']??0}',    icon: Icons.cruelty_free_rounded,           iconColor: AppColors.green600, iconBg: AppColors.green50,   accentColor: AppColors.green600,  delta: '+8',       onTap: () => _go(context,'/animals')),
          ],
        ),
        const SizedBox(height: 20),

        // Milk chart
        _Panel(title: 'Produção — 7 dias', action: 'Ver tudo', onAction: () => _go(context, '/milk'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.water_drop_rounded, size: 20, color: AppColors.green700),
              const SizedBox(width: 6),
              Text('${d.milkToday.toStringAsFixed(0)} L hoje',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.green700)),
            ]),
            const SizedBox(height: 14),
            MiniBarChart(data: d.milkChart, barColor: AppColors.blue600, valueKey: 'volume', labelKey: 'day'),
          ])),
        const SizedBox(height: 12),

        // Finance
        _Panel(title: 'Financeiro — mês atual', action: 'Ver tudo', onAction: () => _go(context, '/finance'),
          child: Column(children: [
            _FinRow('Receitas', currency.format(d.finance['income']), AppColors.green700),
            const SizedBox(height: 6),
            _FinRow('Despesas', currency.format(d.finance['expense']), AppColors.red600),
            const Divider(height: 16),
            _FinRow('Lucro', currency.format(d.finance['profit']),
              (d.finance['profit']??0) >= 0 ? AppColors.green700 : AppColors.red600, bold: true),
          ])),
        const SizedBox(height: 32),
        const Center(child: Text('Desenvolvido por IAmina · GadoLeite ERP v1.0',
          style: TextStyle(fontSize: 11, color: AppColors.gray400))),
        const SizedBox(height: 20),
      ]),
    );
  }

  void _go(BuildContext context, String path) => context.go(path);
}

// ─── TRIAL BANNER ─────────────────────────────────────────────────────────────

class _TrialBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF7C3A00), Color(0xFFB87212)]),
      borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      const Icon(Icons.timer_outlined, color: Colors.white, size: 28),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Trial — 13 dias restantes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
        ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(
          value: 0.43, backgroundColor: Colors.white.withOpacity(0.2),
          valueColor: const AlwaysStoppedAnimation(Colors.white), minHeight: 4)),
      ])),
      const SizedBox(width: 12),
      ElevatedButton(
        onPressed: () => context.go('/subscription'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.amber700,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: const Text('Upgrade', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    ]),
  );
}

// ─── LOCAL WIDGETS ────────────────────────────────────────────────────────────

class _Ticker extends StatelessWidget {
  final String label, value; final bool up;
  const _Ticker({required this.label, required this.value, required this.up});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 6),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 9, color: AppColors.gray400)),
      Row(children: [
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray800)),
        Icon(up ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 14,
          color: up ? AppColors.green600 : AppColors.red600),
      ]),
    ]),
  );
}

class _Panel extends StatelessWidget {
  final String title; final String? action; final VoidCallback? onAction; final Widget child;
  const _Panel({required this.title, this.action, this.onAction, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.gray200, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
        const Spacer(),
        if (action != null) GestureDetector(onTap: onAction,
          child: Text(action!, style: const TextStyle(fontSize: 12, color: AppColors.green700, fontWeight: FontWeight.w500))),
      ]),
      const SizedBox(height: 14),
      child,
    ]),
  );
}

class _FinRow extends StatelessWidget {
  final String label, value; final Color color; final bool bold;
  const _FinRow(this.label, this.value, this.color, {this.bold = false});
  @override
  Widget build(BuildContext context) => Row(children: [
    Text(label, style: TextStyle(fontSize: 13, color: AppColors.gray600, fontWeight: bold ? FontWeight.w600 : FontWeight.w400)),
    const Spacer(),
    Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
  ]);
}
