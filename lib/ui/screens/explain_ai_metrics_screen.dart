import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/glass_card.dart';

class ExplainAIMetricsScreen extends StatelessWidget {
  const ExplainAIMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Comprendre votre IA"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.textTheme.titleLarge?.color),
        titleTextStyle: theme.textTheme.titleLarge,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(theme),
            const SizedBox(height: 32),
            _buildSectionTitle("Comment ça marche ?", theme),
            const SizedBox(height: 16),
            _buildExplanationCard(
              context,
              icon: Icons.favorite_rounded,
              color: Colors.red,
              title: "Votre Cœur vous parle",
              content:
                  "Saviez-vous que votre rythme cardiaque au repos (RHR) augmente légèrement après l'ovulation ?\n\nL'application analyse ces micro-variations (2-3 battements/min) pour détecter que vous êtes en phase lutéale, même si vos règles sont en retard.",
            ),
            const SizedBox(height: 16),
            _buildExplanationCard(
              context,
              icon: Icons.thermostat_rounded,
              color: Colors.orange,
              title: "La Température Basale",
              content:
                  "Votre température corporelle augmente d'environ 0.3°C à 0.5°C juste après l'ovulation. Si vous portez une montre connectée ou utilisez un thermomètre connecté, nous détectons ce 'saut' thermique pour confirmer l'ovulation avec précision.",
            ),
            const SizedBox(height: 32),
            _buildSectionTitle("D'où viennent les données ?", theme),
            const SizedBox(height: 16),
            _buildDataSourceCard(context, isDark),
            const SizedBox(height: 32),
            _buildPrivacyNote(theme),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBrand.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 48,
              color: AppTheme.primaryBrand,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Intelligence Hybride",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBrand,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Mathématiques + Biologie = Précision",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildExplanationCard(
    BuildContext context,
    {
    required IconData icon,
    required Color color,
    required String title,
    required String content,
  }  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      backgroundColor: isDark ? Colors.white10 : Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: AppTheme.textSub,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourceCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSourceIcon(Icons.health_and_safety, "Santé (Apple)"),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.withOpacity(0.3),
              ),
              _buildSourceIcon(Icons.fitness_center, "Google Fit"),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Nous nous connectons sécuritairement aux applications Santé déjà installées sur votre téléphone. Aucune montre spéciale n'est requise si vous utilisez déjà votre téléphone pour compter vos pas.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSub,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.grey.shade600),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBrand.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: AppTheme.primaryBrand),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Vos données de santé restent sur votre appareil. L'analyse IA est effectuée localement (Edge Computing) pour garantir votre vie privée.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryBrand,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
