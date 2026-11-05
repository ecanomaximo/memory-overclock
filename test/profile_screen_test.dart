import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memory_overclock/models/user_progress.dart';
import 'package:memory_overclock/screens/profile_screen.dart';
import 'package:memory_overclock/services/progress_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ProfileScreen exibe métricas do usuário e responde ao clique na trilha', (WidgetTester tester) async {
    final progress = UserProgress(
      userName: 'Testador Cognitivo',
      lastResetDate: '2026-11-05',
      currentLevel: 3,
      dailyChallengesLeft: 2,
      weeklyXp: 150,
      streak: 5,
    );

    final service = ProgressService(initialProgress: progress);
    bool goToTrackCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(
          progressService: service,
          onGoToTrack: () => goToTrackCalled = true,
        ),
      ),
    );

    expect(find.text('Testador Cognitivo'), findsOneWidget);
    expect(find.text('Fase 3 • Neuroplasticidade Ativa'), findsOneWidget);
    expect(find.text('2 / 3 hoje'), findsOneWidget);
    expect(find.text('5 dias'), findsOneWidget);
    expect(find.text('150'), findsOneWidget);

    final button = find.text('CONTINUAR NA TRILHA');
    expect(button, findsOneWidget);

    await tester.tap(button);
    await tester.pump();

    expect(goToTrackCalled, true);
  });
}
