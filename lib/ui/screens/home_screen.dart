import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../logic/cycle_provider.dart';
import '../../logic/auth_provider.dart';
import '../styles/app_theme.dart';
import '../widgets/period_logging_sheet.dart';
import '../widgets/cycle_ring.dart';
import '../widgets/glass_card.dart';
import '../widgets/story_view.dart';
import '../widgets/in_app_notification.dart';
import 'journal_screen.dart';
import 'explain_ai_metrics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CycleProvider>().refreshData();
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      await context.read<AuthProvider>().updateProfileImage(image.path);
    }
  }

  void _showPeriodLogging(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PeriodLoggingSheet(
        onSave: (date, intensity) async {
          final cycle = context.read<CycleProvider>();
          await cycle.startPeriod(date);
          if (context.mounted) {
            Navigator.pop(context);
            InAppNotification.show(
              context,
              title: "Cycle mis à jour",
              message: "Tes règles ont été enregistrées avec succès.",
              icon: Icons.check_circle_rounded,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final user = context.watch<AuthProvider>().user; // Watch for image updates
    final pred = cycle.prediction;
    final theme = Theme.of(context);

    // Dynamic Cycle Data
    final bool isPeriodMode = pred?.currentPhase == CyclePhase.menstrual;
    final Color phaseColor = isPeriodMode
        ? AppTheme.accentPeriod
        : AppTheme.primaryBrand;
    final String mainLabel = isPeriodMode ? "Jour de règles" : "Jours restants";
    final int mainValue = isPeriodMode
        ? (pred?.dayOfCycle ?? 1)
        : (pred?.daysUntilNext ?? 0);

    double progress = 0.0;
    if (pred != null) {
      if (isPeriodMode) {
        progress = (pred.dayOfCycle) / 5.0;
      } else {
        // Use dynamic cycle length for progress calculation
        progress =
            1.0 - (pred.daysUntilNext / (pred.avgCycleLength.toDouble()));
      }
    }
    progress = progress.clamp(0.05, 1.0);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async =>
              await context.read<CycleProvider>().refreshData(),
          color: AppTheme.primaryBrand,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user?.name, user?.profileImagePath),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      // THE HORMONAL COMPASS
                      CycleRing(
                        daysRemaining: mainValue,
                        label: mainLabel,
                        progress: progress,
                        color: phaseColor,
                        isPeriod: isPeriodMode,
                        phase: pred?.currentPhase ?? CyclePhase.follicular,
                        periodProbability: pred?.periodProbability ?? 0.0,
                      ),
                      
                      const SizedBox(height: 24), 
                      
                      // AI INSIGHT BUBBLE (New Feature)
                      if (pred != null)
                        _buildInsightBubble(context, pred),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Health Metrics (ML Inputs)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Signaux Corporels", style: theme.textTheme.titleMedium),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: () => context.read<CycleProvider>().refreshData(),
                      tooltip: "Actualiser les données Santé",
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildHealthMetricsRow(context),
                const SizedBox(height: 24),

                // Dashboard Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard(
                        title: isPeriodMode ? "Règles" : "Folliculaire",
                        value: isPeriodMode ? "Intense" : "Énergie Haute",
                        icon: isPeriodMode
                            ? Icons.water_drop_rounded
                            : Icons.bolt_rounded,
                        color: isPeriodMode
                            ? AppTheme.surfacePeriod
                            : AppTheme.surfaceFollicular,
                        iconColor: isPeriodMode
                            ? AppTheme.accentPeriod
                            : AppTheme.accentFollicular,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        title: isPeriodMode
                            ? "Fin des\nrègles"
                            : "J'ai mes\nrègles",
                        icon: isPeriodMode
                            ? Icons.stop_rounded
                            : Icons.water_drop_rounded,
                        color: isPeriodMode
                            ? AppTheme.surfacePeriod
                            : AppTheme.surfaceLight,
                        iconColor: isPeriodMode
                            ? AppTheme.accentPeriod
                            : AppTheme.primaryBrand,
                        onTap: () {
                          if (isPeriodMode) {
                            cycle.endPeriod(DateTime.now());
                          } else {
                            _showPeriodLogging(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        title: "Noter mes\nsymptômes",
                        icon: Icons.add_reaction_rounded,
                        color: AppTheme.surfaceLight,
                        iconColor: AppTheme.secondaryBrand,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const JournalScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        title: "Conseils\nIA",
                        icon: Icons.auto_awesome_rounded,
                        color: const Color(0xFFF0EFFF),
                        iconColor: AppTheme.primaryBrand,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ExplainAIMetricsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightBubble(BuildContext context, CyclePrediction pred) {
    bool isHighProb = pred.periodProbability > 0.6;
    String message = "Cycle stable basé sur l'historique.";
    IconData icon = Icons.calendar_today_rounded;
    Color color = Colors.grey;

    if (isHighProb) {
      message = "L'IA détecte une arrivée imminente (Symptômes + Température).";
      icon = Icons.auto_awesome;
      color = AppTheme.primaryBrand;
    } else if (pred.currentPhase == CyclePhase.luteal) {
      message = "Phase de repos. Écoute ton corps.";
      icon = Icons.bedtime_rounded;
      color = Colors.indigo;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String? userName, String? imagePath) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, ${userName?.toUpperCase() ?? "OULY"}',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontSize: 20,
                letterSpacing: 0.5,
                color: Theme.of(
                  context,
                ).textTheme.headlineSmall?.color, // Adapt to theme
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 24,
            backgroundImage: imagePath != null
                ? FileImage(File(imagePath))
                : const AssetImage('assets/icons/ic_nav_profile_filled.png')
                      as ImageProvider,
            backgroundColor: AppTheme.surfaceLight,
            child: imagePath == null
                ? const Icon(Icons.camera_alt, size: 16, color: Colors.grey)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    // Only use forced colors if light mode, else use theme card color
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      backgroundColor: isDark ? Theme.of(context).cardTheme.color! : color,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppTheme.textSub),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      onTap: onTap,
      backgroundColor: isDark
          ? Theme.of(context).cardTheme.color!
          : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }

  Widget _buildHealthMetricsRow(BuildContext context) {
    // Note: In a real app, these would come from the provider's state
    // For now, we show their status in the adaptation process
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            label: "Cœur (Repos)",
            value: "72 bpm",
            icon: Icons.favorite_rounded,
            color: Colors.red.shade50,
            iconColor: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            label: "Température",
            value: "36.6°C",
            icon: Icons.thermostat_rounded,
            color: Colors.orange.shade50,
            iconColor: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return GlassCard(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white10
          : color,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: AppTheme.textSub,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}