import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/auth_provider.dart';
import '../styles/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthYearController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Créer un compte', style: theme.textTheme.titleLarge?.copyWith(color: AppTheme.textMain)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppTheme.textMain),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bienvenue',
                style: theme.textTheme.displaySmall?.copyWith(color: AppTheme.primaryBrand),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Configurez votre profil pour un suivi personnalisé.',
                style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSub),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              TextField(
                controller: _birthYearController,
                decoration: const InputDecoration(
                  labelText: 'Année de naissance',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(auth.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                ),
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        final success = await auth.register(
                          email: _emailController.text,
                          password: _passwordController.text,
                          name: _nameController.text,
                          birthYear: int.tryParse(_birthYearController.text),
                        );

                        if (!context.mounted) return;

                        if (success) {
                          Navigator.of(context).pop();
                        } else {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(auth.error ?? "Échec de l'inscription")),
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
                    : const Text('S\'inscrire'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
