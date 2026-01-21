import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/auth_provider.dart';
import 'register_screen.dart';
import '../styles/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.spa, size: 80, color: AppTheme.primaryBrand),
              const SizedBox(height: 16),
              Text(
                'CycleFlow',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium?.copyWith(
                  color: AppTheme.primaryBrand,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Écoutez votre corps',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSub),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(auth.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                ),
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        final success = await auth.login(_emailController.text, _passwordController.text);
                        if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(auth.error ?? "Échec de la connexion")),
                                ],
                              ),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                child: auth.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Se connecter'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: Text('Créer un compte', style: TextStyle(color: AppTheme.primaryBrand)),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
