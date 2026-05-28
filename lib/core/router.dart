import 'package:go_router/go_router.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/animals/animals_screen.dart';
import '../features/animals/animal_detail_screen.dart';
import '../features/animals/animal_form_screen.dart';
import '../features/milk/milk_screen.dart';
import '../features/stock/stock_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/subscription/subscription_screen.dart';
import '../features/all_screens.dart';
import '../shared/widgets/main_shell.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/',             builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/milk',         builder: (_, __) => const MilkScreen()),
        GoRoute(path: '/reproduction', builder: (_, __) => const ReproductionScreen()),
        GoRoute(path: '/health',       builder: (_, __) => const HealthScreen()),
        GoRoute(path: '/finance',      builder: (_, __) => const FinanceScreen()),
        GoRoute(path: '/stock',        builder: (_, __) => const StockScreen()),
        GoRoute(path: '/reports',      builder: (_, __) => const ReportsScreen()),
        GoRoute(path: '/settings',     builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/subscription', builder: (_, __) => const SubscriptionScreen()),
        GoRoute(
          path: '/animals',
          builder: (_, __) => const AnimalsScreen(),
          routes: [
            GoRoute(path: 'new',      builder: (_, __) => const AnimalFormScreen()),
            GoRoute(path: ':id',      builder: (c, s) => AnimalDetailScreen(id: s.pathParameters['id']!)),
            GoRoute(path: ':id/edit', builder: (c, s) => AnimalFormScreen(animalId: s.pathParameters['id'])),
          ],
        ),
      ],
    ),
  ],
);
