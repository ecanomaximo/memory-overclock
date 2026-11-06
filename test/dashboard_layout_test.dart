import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memory_overclock/models/user_progress.dart';
import 'package:memory_overclock/screens/dashboard_screen.dart';
import 'package:memory_overclock/services/progress_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('DashboardScreen layout at 1920x1080', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final progress = UserProgress(
      userName: 'Testador Cognitivo',
      lastResetDate: '2026-11-05',
      currentLevel: 1,
      dailyChallengesLeft: 5,
      isLoggedIn: true,
    );
    final service = ProgressService(initialProgress: progress);

    await tester.pumpWidget(MaterialApp(home: DashboardScreen(progressService: service)));
    await tester.pumpAndSettle();

    expect(find.text('PAINEL COGNITIVO'), findsOneWidget);
    
    // Check vertical position of bottom navigation
    final navFinder = find.byType(NavigationBar);
    expect(navFinder, findsOneWidget);
    final navTop = tester.getTopLeft(navFinder).dy;
    expect(navTop, greaterThan(950)); // Should be at y >= 1000 near the bottom of 1080!
  });
}
