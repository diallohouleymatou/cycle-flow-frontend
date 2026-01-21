import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'logic/auth_provider.dart';
import 'logic/cycle_provider.dart';
import 'logic/theme_provider.dart';
import 'logic/journal_provider.dart';
import 'logic/router.dart';
import 'ui/styles/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProxyProvider2<AuthProvider, JournalProvider, CycleProvider>(
          create: (context) => CycleProvider(
            context.read<AuthProvider>().api,
            context.read<JournalProvider>(),
          ),
          update: (context, auth, journal, previous) => CycleProvider(auth.api, journal),
        ),
      ],
      child: const CycleFlowApp(),
    );
  }
}

class CycleFlowApp extends StatefulWidget {
  const CycleFlowApp({super.key});

  @override
  State<CycleFlowApp> createState() => _CycleFlowAppState();
}

class _CycleFlowAppState extends State<CycleFlowApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _router = createRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return MaterialApp.router(
      title: 'CycleFlow',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}