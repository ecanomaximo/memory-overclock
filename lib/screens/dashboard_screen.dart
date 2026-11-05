import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'league_screen.dart';
import 'paywall_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ProgressService progressService;

  const DashboardScreen({super.key, required this.progressService});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(progressService: widget.progressService),
      LeagueScreen(progressService: widget.progressService),
      PaywallScreen(progressService: widget.progressService),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(color: AppTheme.surfaceElevated.withValues(alpha: 0.8)),
          ),
        ),
        child: NavigationBar(
          backgroundColor: AppTheme.surface,
          selectedIndex: _currentIndex,
          indicatorColor: AppTheme.neonCyan.withValues(alpha: 0.2),
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.map_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.map, color: AppTheme.neonCyan),
              label: 'Trilha',
            ),
            NavigationDestination(
              icon: Icon(Icons.military_tech_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.military_tech, color: AppTheme.gold),
              label: 'Ligas',
            ),
            NavigationDestination(
              icon: Icon(Icons.workspace_premium_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.workspace_premium, color: AppTheme.neonPurple),
              label: 'Clube VIP',
            ),
          ],
        ),
      ),
    );
  }
}
