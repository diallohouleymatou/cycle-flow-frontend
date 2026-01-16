import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/auth_provider.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte'), backgroundColor: Colors.transparent, foregroundColor: Colors.pink),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bienvenue sur CycleFlow',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink),
            ),
            const SizedBox(height: 8),
            const Text('Commençons par configurer votre profil pour des prédictions précises.'),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Prénom', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _birthYearController,
              decoration: const InputDecoration(labelText: 'Année de naissance', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            if (auth.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(auth.error!, style: const TextStyle(color: Colors.red)))
              ,
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
                      if (success && mounted) {
                        Navigator.of(context).pop(); // Back to login or directly home depends on auth state
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF06292),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: auth.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('S\'inscrire', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}