import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'core/security.dart';
import 'database/database.dart';

final dbProvider = Provider<AppDatabase>((ref) => AppDatabase.instance);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await AppDatabase.instance.initialize();
  runApp(const ProviderScope(child: GadoLeiteApp()));
}

class GadoLeiteApp extends ConsumerWidget {
  const GadoLeiteApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'GadoLeite ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) => SecurityWrapper(child: child ?? const SizedBox()),
    );
  }
}
