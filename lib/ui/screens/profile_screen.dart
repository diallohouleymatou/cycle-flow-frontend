import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/auth_provider.dart';
import '../styles/app_theme.dart';
import '../widgets/in_app_notification.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      _nameController.text = user?.name ?? '';
    });
  }

  void _selectImage() {
    InAppNotification.show(
      context,
      title: "Image de profil",
      message: "Logique de sélection d'image à implémenter avec image_picker.",
      icon: Icons.image_rounded,
    );
  }

  void _saveProfile() {
    InAppNotification.show(
      context,
      title: "Profil sauvegardé",
      message: "Tes modifications ont été enregistrées avec succès.",
      icon: Icons.check_circle_rounded,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Mon Profil"),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text("OK"),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.surfaceLight,
                    backgroundImage: const AssetImage('assets/icons/ic_nav_profile_filled.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _selectImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBrand,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "PRÉNOM",
                hintText: "Ton prénom",
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: user?.email ?? "ouly@example.com"),
              decoration: InputDecoration(
                labelText: "EMAIL",
                fillColor: AppTheme.dividerColor.withOpacity(0.3),
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
