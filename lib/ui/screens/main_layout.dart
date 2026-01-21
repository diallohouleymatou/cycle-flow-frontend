import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'journal_screen.dart';
import 'settings_screen.dart';
import '../styles/app_theme.dart';
import '../widgets/blur_navigation_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const JournalScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: _screens[_currentIndex],
      bottomNavigationBar: BlurNavigationBar(
        selectedIndex: _currentIndex,
        onItemSelected: (idx) => setState(() => _currentIndex = idx),
        items: const [
          NavigationItem(
            icon: Icons.spa_outlined,
            activeIcon: Icons.spa_rounded,
            label: 'Accueil',
          ),
          NavigationItem(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_month_rounded,
            label: 'Calendrier',
          ),
          NavigationItem(
            icon: Icons.book_outlined,
            activeIcon: Icons.book_rounded,
            label: 'Journal',
          ),
          NavigationItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            label: 'Réglages',
          ),
        ],
      ),
    );
  }
}