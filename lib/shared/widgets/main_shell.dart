import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool _sidebarExpanded = true;

  final List<_NavItem> _navItems = const [
    _NavItem('/',             Icons.dashboard_rounded,               'Dashboard'),
    _NavItem('/animals',      Icons.pets_rounded,                    'Animais'),
    _NavItem('/milk',         Icons.water_drop_rounded,              'Produção Leiteira'),
    _NavItem('/reproduction', Icons.favorite_rounded,                'Reprodução'),
    _NavItem('/health',       Icons.local_hospital_rounded,          'Sanidade'),
    _NavItem('/finance',      Icons.account_balance_wallet_rounded,  'Financeiro'),
    _NavItem('/reports',      Icons.bar_chart_rounded,               'Relatórios'),
    _NavItem('/settings',     Icons.settings_rounded,                'Configurações'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final currentPath = GoRouterState.of(context).uri.path;
    if (!isDesktop) {
      return Scaffold(
        body: widget.child,
        bottomNavigationBar: _buildBottomNav(currentPath, context),
      );
    }
    return Scaffold(
      body: Row(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220), curve: Curves.easeInOut,
          width: _sidebarExpanded ? 240 : 68,
          child: _buildSidebar(currentPath, context),
        ),
        Expanded(child: widget.child),
      ]),
    );
  }

  Widget _buildSidebar(String currentPath, BuildContext context) {
    return Container(
      color: AppColors.sidebar,
      child: Column(children: [
        // Logo
        Container(
          height: 64, padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF1E3A28), width: 0.5))),
          child: Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.green600, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.grass_rounded, color: Colors.white, size: 20)),
            if (_sidebarExpanded) ...[
              const SizedBox(width: 12),
              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('GadoLeite ERP', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text('Agritech SaaS', style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11)),
              ])),
            ],
            GestureDetector(
              onTap: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
              child: Icon(_sidebarExpanded ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.5), size: 20),
            ),
          ]),
        ),

        // Trial Banner
        if (_sidebarExpanded) _buildTrialBanner(),

        // Nav
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            children: [
              if (_sidebarExpanded) _NavLabel('Principal'),
              ..._navItems.take(4).map((item) => _NavTile(item: item, isActive: _isActive(item, currentPath), expanded: _sidebarExpanded, onTap: () => context.go(item.path))),
              if (_sidebarExpanded) const SizedBox(height: 4),
              if (_sidebarExpanded) _NavLabel('Gestão'),
              ..._navItems.skip(4).map((item) => _NavTile(item: item, isActive: _isActive(item, currentPath), expanded: _sidebarExpanded, onTap: () => context.go(item.path))),
            ],
          ),
        ),

        // User footer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF1E3A28), width: 0.5))),
          child: Row(children: [
            const CircleAvatar(radius: 16, backgroundColor: AppColors.green700,
              child: Text('JF', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
            if (_sidebarExpanded) ...[
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('João Fazendeiro', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                Text('Administrador', style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11)),
              ])),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _buildTrialBanner() => Container(
    margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFF1A3020), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.amber500.withOpacity(0.4))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.timer_outlined, size: 13, color: AppColors.amber500),
        const SizedBox(width: 4),
        Text('Trial ativo', style: TextStyle(color: AppColors.amber500, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 2),
      const Text('13 dias restantes', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      ClipRRect(borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(value: 0.43, backgroundColor: Colors.white.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation(AppColors.amber500), minHeight: 4)),
      const SizedBox(height: 8),
      SizedBox(width: double.infinity, child: TextButton(
        onPressed: () => context.go('/subscription'),
        style: TextButton.styleFrom(backgroundColor: AppColors.amber500, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))),
        child: const Text('Fazer Upgrade ↗', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      )),
    ]),
  );

  Widget _buildBottomNav(String currentPath, BuildContext context) {
    final mobileItems = [_navItems[0], _navItems[1], _navItems[2], _navItems[4], _navItems[5]];
    int currentIndex = mobileItems.indexWhere((item) => _isActive(item, currentPath));
    if (currentIndex < 0) currentIndex = 0;
    return NavigationBar(
      selectedIndex: currentIndex,
      backgroundColor: AppColors.sidebar,
      indicatorColor: AppColors.green700,
      onDestinationSelected: (i) => context.go(mobileItems[i].path),
      destinations: mobileItems.map((item) => NavigationDestination(
        icon: Icon(item.icon, color: Colors.white.withOpacity(0.5)),
        selectedIcon: Icon(item.icon, color: Colors.white),
        label: item.label,
      )).toList(),
    );
  }

  bool _isActive(_NavItem item, String path) =>
    path == item.path || (item.path != '/' && path.startsWith(item.path));
}

class _NavItem {
  final String path, label;
  final IconData icon;
  const _NavItem(this.path, this.icon, this.label);
}

class _NavLabel extends StatelessWidget {
  final String text;
  const _NavLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
    child: Text(text, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.35),
      letterSpacing: 0.5, fontWeight: FontWeight.w600)),
  );
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isActive, expanded;
  final VoidCallback onTap;
  const _NavTile({required this.item, required this.isActive, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 10, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.green700.withOpacity(0.35) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? Border.all(color: AppColors.green600.withOpacity(0.3)) : null,
      ),
      child: Row(children: [
        if (isActive)
          Container(width: 3, height: 18, margin: const EdgeInsets.only(right: 9),
            decoration: BoxDecoration(color: AppColors.green400, borderRadius: BorderRadius.circular(2)))
        else if (expanded)
          const SizedBox(width: 12),
        Icon(item.icon, size: 20,
          color: isActive ? AppColors.green400 : Colors.white.withOpacity(0.45)),
        if (expanded) ...[
          const SizedBox(width: 10),
          Expanded(child: Text(item.label, style: TextStyle(
            color: isActive ? AppColors.green400 : Colors.white.withOpacity(0.6),
            fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ))),
        ],
      ]),
    ),
  );
}
