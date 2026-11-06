import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_survey_screen.dart';
import 'services/auth_service.dart';
import 'services/progress_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initialize();
  final progressService = ProgressService();

  // Força logout se a URL tiver ?logout=true ou #logout
  if (Uri.base.queryParameters['logout'] == 'true' || Uri.base.fragment == 'logout') {
    await progressService.logout();
  }

  runApp(MemoryOverclockApp(progressService: progressService));
}

class MemoryOverclockApp extends StatelessWidget {
  final ProgressService progressService;

  const MemoryOverclockApp({super.key, required this.progressService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Overclock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: ListenableBuilder(
        listenable: progressService,
        builder: (context, _) {
          if (!progressService.isInitialized) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.neonCyan),
              ),
            );
          }

          if (progressService.progress.isLoggedIn) {
            if (!progressService.progress.hasCompletedOnboarding) {
              return OnboardingSurveyScreen(
                progressService: progressService,
                onFinished: () {},
              );
            }
            return DashboardScreen(progressService: progressService);
          } else {
            return LoginScreen(progressService: progressService);
          }
        },
      ),
    );
  }
}
