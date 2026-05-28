import 'package:flutter/material.dart';
import '../../core/theme.dart';

// ─── STAT CARD ────────────────────────────────────────────────────────────────

class StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color iconColor, iconBg, accentColor;
  final String? delta;
  final bool deltaPositive;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.accentColor = AppColors.green700,
    this.delta,
    this.deltaPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                if (delta != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: deltaPositive ? AppColors.green50 : AppColors.red50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(children: [
                      Icon(
                        deltaPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: 12,
                        color: deltaPositive ? AppColors.green700 : AppColors.red600,
                      ),
                      const SizedBox(width: 2),
                      Text(delta!, style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: deltaPositive ? AppColors.green700 : AppColors.red600,
                      )),
                    ]),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.gray900, height: 1)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
            const SizedBox(height: 8),
            Container(height: 3, decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(2),
            ), child: FractionallySizedBox(
              widthFactor: 0.7, alignment: Alignment.centerLeft,
              child: Container(decoration: BoxDecoration(
                color: accentColor, borderRadius: BorderRadius.circular(2),
              )),
            )),
          ],
        ),
      ),
    );
  }
}

// ─── SECTION HEADER ───────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.action, this.onAction, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900)),
          const Spacer(),
          if (trailing != null) trailing!,
          if (action != null) GestureDetector(
            onTap: onAction,
            child: Text(action!, style: const TextStyle(fontSize: 12, color: AppColors.green700, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ─── EMPTY STATE ──────────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: AppColors.green50, borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, color: AppColors.green700, size: 36),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray800)),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.gray500)),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── ALERT PILL ───────────────────────────────────────────────────────────────

class AlertPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color, bg;
  final VoidCallback? onTap;

  const AlertPill({super.key, required this.label, required this.icon, required this.color, required this.bg, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ]),
      ),
    );
  }
}

// ─── STATUS BADGE ─────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  (String, Color, Color) _resolve(String s) => switch (s) {
    'ACTIVE'    => ('Ativa', AppColors.green700, AppColors.green50),
    'PREGNANT'  => ('Prenhe', AppColors.blue600, AppColors.blue50),
    'DRY'       => ('Seca', AppColors.amber500, AppColors.amber50),
    'SICK'      => ('Doente', AppColors.red600, AppColors.red50),
    'SOLD'      => ('Vendida', AppColors.gray600, AppColors.gray100),
    'DEAD'      => ('Morta', AppColors.gray600, AppColors.gray100),
    'CALF'      => ('Bezerro', AppColors.purple600, AppColors.purple100),
    _           => (s, AppColors.gray600, AppColors.gray100),
  };
}

// ─── PAGE WRAPPER ─────────────────────────────────────────────────────────────

class PageWrapper extends StatelessWidget {
  final String title, subtitle;
  final Widget? action;
  final List<Widget> children;
  final ScrollController? scrollController;

  const PageWrapper({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
    required this.children,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
          ],
        ),
        actions: [if (action != null) Padding(padding: const EdgeInsets.only(right: 16), child: action!)],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: AppColors.gray200),
        ),
      ),
      body: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: children,
      ),
    );
  }
}

// ─── MINI CHART BAR ───────────────────────────────────────────────────────────

class MiniBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color barColor;
  final String valueKey, labelKey;

  const MiniBarChart({
    super.key,
    required this.data,
    required this.barColor,
    this.valueKey = 'volume',
    this.labelKey = 'day',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox(height: 100, child: Center(child: Text('Sem dados', style: TextStyle(color: AppColors.gray400, fontSize: 12))));
    final max = data.map((d) => (d[valueKey] as num).toDouble()).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((d) {
          final v = (d[valueKey] as num).toDouble();
          final frac = max > 0 ? v / max : 0.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(_fmt(v), style: const TextStyle(fontSize: 8, color: AppColors.gray500)),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    height: (frac * 70).clamp(4.0, 70.0),
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text('${d[labelKey]}', style: const TextStyle(fontSize: 8, color: AppColors.gray400)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}
