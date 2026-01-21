import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../logic/auth_provider.dart';
import '../../logic/cycle_provider.dart';
import '../widgets/primary_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glass_card.dart';
import '../styles/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  // Data State
  double _cycleLength = 28;
  String? _selectedGoal;
  final List<String> _goals = [
    "Suivre mon cycle",
    "Prédire mes règles",
    "Gérer mes symptômes",
    "Comprendre mon corps",
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    // Save relevant data
    final auth = context.read<AuthProvider>();
    final cycle = context.read<CycleProvider>();

    // Save cycle length
    await cycle.setCycleLength(_cycleLength.toInt());

    // Mark as completed
    await auth.completeOnboarding();

    if (mounted) {
      // Navigate to Register or Login (or Home if we treat them as registered implicitly locally)
      // For now, let's go to register to create account, or home.
      // The router redirect should handle it if we are consistent.
      context.go('/register');
    }
  }

  void _nextPage() {
    HapticFeedback.mediumImpact();
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppTheme.primaryBrand
                            : AppTheme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildWelcomeStep(),
                  _buildNameStep(),
                  _buildCycleStep(),
                  _buildGoalStep(),
                  _buildNotificationsStep(),
                ],
              ),
            ),

            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContainer({
    required String title,
    required String subtitle,
    required Widget content,
    Widget? topWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topWidget != null) ...[
            Center(child: topWidget),
            const SizedBox(height: 40),
          ],
          Text(title, style: AppTheme.lightTheme.textTheme.headlineLarge),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSub,
            ),
          ),
          const SizedBox(height: 40),
          content,
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return _buildStepContainer(
      topWidget: Image.asset('assets/icons/phase_follicular.png', height: 180),
      title: "Bienvenue sur CycleFlow",
      subtitle:
          "Ton compagnon de cycle intelligent, conçu pour t'accompagner chaque jour avec douceur.",
      content: const SizedBox.shrink(),
    );
  }

  Widget _buildNameStep() {
    return _buildStepContainer(
      title: "Faisons connaissance",
      subtitle:
          "Comment t'appelles-tu ? Ton prénom sera affiché avec fierté dans ton tableau de bord.",
      content: CustomTextField(
        label: "TON PRÉNOM",
        controller: _nameController,
        hintText: "Ouly",
      ),
    );
  }

  Widget _buildCycleStep() {
    return _buildStepContainer(
      title: "Ton cycle",
      subtitle:
          "Quelle est la durée moyenne de ton cycle ? Si tu ne sais pas, on partira sur 28 jours.",
      content: Column(
        children: [
          Text(
            "${_cycleLength.toInt()} jours",
            style: AppTheme.lightTheme.textTheme.displayMedium?.copyWith(
              color: AppTheme.primaryBrand,
            ),
          ),
          const SizedBox(height: 24),
          Slider(
            value: _cycleLength,
            min: 21,
            max: 35,
            divisions: 14,
            activeColor: AppTheme.primaryBrand,
            inactiveColor: AppTheme.dividerColor,
            onChanged: (value) {
              setState(() => _cycleLength = value);
              HapticFeedback.selectionClick();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    return _buildStepContainer(
      title: "Ton objectif",
      subtitle: "Qu'est-ce qui t'amène parmi nous aujourd'hui ?",
      content: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _goals.map((goal) {
          final isSelected = _selectedGoal == goal;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedGoal = goal);
              HapticFeedback.selectionClick();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBrand : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryBrand
                      : AppTheme.dividerColor,
                  width: 1.5,
                ),
              ),
              child: Text(
                goal,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textMain,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationsStep() {
    return _buildStepContainer(
      topWidget: const Icon(
        Icons.notifications_active_outlined,
        size: 80,
        color: AppTheme.primaryBrand,
      ),
      title: "Reste informée",
      subtitle:
          "Active les notifications pour ne jamais être surprise par tes règles ou ton ovulation.",
      content: GlassCard(
        backgroundColor: AppTheme.surfaceLight,
        child: Row(
          children: [
            const Icon(Icons.security_rounded, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Privé et discret. Nous ne vendons jamais tes données.",
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: PrimaryButton(
        label: _currentPage == 4 ? "COMMENCER" : "CONTINUER",
        onPressed: _currentPage == 1 && _nameController.text.isEmpty
            ? null
            : _nextPage,
      ),
    );
  }
}
