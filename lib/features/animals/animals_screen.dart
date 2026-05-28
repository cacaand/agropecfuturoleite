import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../database/database.dart';
import '../../main.dart';
import '../../shared/widgets/widgets.dart';

final _filterProvider = StateProvider<String?>((ref) => null);
final _searchProvider  = StateProvider<String>((ref) => '');

class AnimalsScreen extends ConsumerWidget {
  const AnimalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db     = ref.read(dbProvider);
    final filter = ref.watch(_filterProvider);
    final search = ref.watch(_searchProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, toolbarHeight: 64,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Animais', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900)),
          Text('Gestão do rebanho', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
        ]),
        actions: [
          ElevatedButton.icon(
            onPressed: () => context.go('/animals/new'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Novo animal'),
          ),
          const SizedBox(width: 16),
        ],
        bottom: const PreferredSize(preferredSize: Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: AppColors.gray200)),
      ),
      body: Column(children: [
        // Search + Filters
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por nome, brinco, código...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.gray400, size: 20),
              ),
              onChanged: (v) => ref.read(_searchProvider.notifier).state = v,
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _Chip('Todos',    null,       filter, () => ref.read(_filterProvider.notifier).state = null),
                _Chip('Lactação','ACTIVE',    filter, () => ref.read(_filterProvider.notifier).state = 'ACTIVE'),
                _Chip('Prenhas', 'PREGNANT',  filter, () => ref.read(_filterProvider.notifier).state = 'PREGNANT'),
                _Chip('Secas',   'DRY',       filter, () => ref.read(_filterProvider.notifier).state = 'DRY'),
                _Chip('Doentes', 'SICK',      filter, () => ref.read(_filterProvider.notifier).state = 'SICK'),
                _Chip('Bezerros','CALF',      filter, () => ref.read(_filterProvider.notifier).state = 'CALF'),
              ]),
            ),
          ]),
        ),
        // List
        Expanded(
          child: StreamBuilder<List<Animal>>(
            stream: db.watchAnimals(
              status:   filter != 'CALF' ? filter : null,
              category: filter == 'CALF' ? 'CALF'  : null,
            ),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.green700));
              var list = snap.data!;
              if (search.isNotEmpty) {
                final q = search.toLowerCase();
                list = list.where((a) =>
                  (a.name?.toLowerCase().contains(q) ?? false) ||
                  a.code.contains(search) ||
                  (a.earTag?.contains(search) ?? false) ||
                  a.breed.toLowerCase().contains(q)
                ).toList();
              }
              if (list.isEmpty) return EmptyState(
                icon: Icons.pets_rounded,
                title: 'Nenhum animal encontrado',
                subtitle: 'Adicione animais ou ajuste os filtros',
                actionLabel: 'Adicionar animal',
                onAction: () => context.go('/animals/new'),
              );
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _AnimalCard(animal: list[i]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  final Animal animal;
  const _AnimalCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    final age = animal.birthDate != null
      ? '${((DateTime.now().difference(animal.birthDate!).inDays) / 365).floor()} anos'
      : 'Idade desconhecida';

    return GestureDetector(
      onTap: () => context.go('/animals/${animal.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200, width: 0.5)),
        child: Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: _catColor(animal.category).withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(_catEmoji(animal.category), style: const TextStyle(fontSize: 22)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(animal.name ?? 'Sem nome', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
              const SizedBox(width: 6),
              StatusBadge(animal.status),
            ]),
            const SizedBox(height: 3),
            Text('#${animal.code} · ${animal.breed} · $age', style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (animal.weight != null)
              Text('${animal.weight!.toStringAsFixed(0)} kg',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700)),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gray400, size: 20),
          ]),
        ]),
      ),
    );
  }

  Color  _catColor(String c) => switch (c) { 'DAIRY_COW' => AppColors.green700, 'CALF' => AppColors.purple600, 'BULL' => AppColors.blue600, _ => AppColors.amber500 };
  String _catEmoji(String c) => switch (c) { 'DAIRY_COW' => '🐄', 'CALF' => '🐮', 'BULL' => '🐂', _ => '🐄' };
}

class _Chip extends StatelessWidget {
  final String label; final String? value, current; final VoidCallback onTap;
  const _Chip(this.label, this.value, this.current, this.onTap);
  @override
  Widget build(BuildContext context) {
    final active = value == current;
    return GestureDetector(onTap: onTap, child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(color: active ? AppColors.green700 : AppColors.gray100, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.gray600)),
    ));
  }
}
