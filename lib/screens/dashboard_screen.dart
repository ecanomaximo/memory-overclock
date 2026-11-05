import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'league_screen.dart';
import 'paywall_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ProgressService progressService;

  const DashboardScreen({super.key, required this.progressService});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0; // Inicia na aba de Perfil / Painel Cognitivo

  void _switchTab(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ProfileScreen(
        progressService: widget.progressService,
        onGoToTrack: () => _switchTab(1),
      ),
      HomeScreen(
        progressService: widget.progressService,
        onOpenProfile: () => _switchTab(0),
      ),
      LeagueScreen(progressService: widget.progressService),
      PaywallScreen(progressService: widget.progressService),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(color: AppTheme.surfaceBorder, width: 1),
          ),
        ),
        child: NavigationBar(
          backgroundColor: AppTheme.surface,
          selectedIndex: _currentIndex,
          indicatorColor: AppTheme.focusCyan.withValues(alpha: 0.18),
          elevation: 0,
          onDestinationSelected: _switchTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.person_rounded, color: AppTheme.focusCyan),
              label: 'Perfil',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.map_rounded, color: AppTheme.focusCyan),
              label: 'Trilha',
            ),
            NavigationDestination(
              icon: Icon(Icons.military_tech_outlined, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.military_tech_rounded, color: AppTheme.prestigeGold),
              label: 'Ligas',
            ),
            NavigationDestination(
              icon: Icon(Icons.workspace_premium_outlined, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.workspace_premium_rounded, color: AppTheme.calmIndigo),
              label: 'Clube VIP',
            ),
          ],
        ),
      ),
    );
  }
}
