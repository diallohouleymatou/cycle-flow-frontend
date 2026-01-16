import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'logic/auth_provider.dart';
import 'logic/cycle_provider.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/home_screen.dart';

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
        ChangeNotifierProxyProvider<AuthProvider, CycleProvider>(
          create: (context) => CycleProvider(context.read<AuthProvider>().api),
          update: (context, auth, previous) => CycleProvider(auth.api),
        ),
      ],
      child: MaterialApp(
        title: 'CycleFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF06292), // Rose/Pink for the theme
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF06292),
            foregroundColor: Colors.white,
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
          },
        ),
      ),
    );
  }
}
