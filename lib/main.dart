import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/progress_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final progressService = ProgressService();

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
      home: HomeScreen(progressService: progressService),
    );
  }
}
