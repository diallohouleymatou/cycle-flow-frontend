import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/theme_provider.dart';
import '../../logic/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Apparence", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 10),
          Card(
            child: SwitchListTile(
              title: const Text("Mode Sombre"),
              secondary: const Icon(Icons.dark_mode_outlined),
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.toggleTheme(val),
            ),
          ),

          const SizedBox(height: 30),
          const Text("Compte", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(authProvider.user?.name ?? 'Utilisateur'),
              subtitle: Text(authProvider.user?.email ?? ''),
            ),
          ),
          
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Se déconnecter", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () => authProvider.logout(),
            ),
          ),
          
          const SizedBox(height: 30),
          const Center(
            child: Text("CycleFlow v1.0.0", style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }
}
