import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memory_overclock/main.dart';
import 'package:memory_overclock/models/user_progress.dart';
import 'package:memory_overclock/services/progress_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Roteamento: novo usuário logado abre OnboardingSurveyScreen', (tester) async {
    final progress = UserProgress(
      lastResetDate: '2026-11-05',
      isLoggedIn: true,
      hasCompletedOnboarding: false,
    );
    final service = ProgressService(initialProgress: progress);

    await tester.pumpWidget(MemoryOverclockApp(progressService: service));
    await tester.pumpAndSettle();

    expect(find.text('ANAMNESE NEURAL'), findsOneWidget);
    expect(find.text('O que te motivou a baixar o Memory Overclock?'), findsOneWidget);
  });

  testWidgets('Roteamento: usuário já onboarded vai direto ao DashboardScreen', (tester) async {
    final progress = UserProgress(
      lastResetDate: '2026-11-05',
      isLoggedIn: true,
      hasCompletedOnboarding: true,
    );
    final service = ProgressService(initialProgress: progress);

    await tester.pumpWidget(MemoryOverclockApp(progressService: service));
    await tester.pumpAndSettle();

    expect(find.text('PAINEL COGNITIVO'), findsOneWidget);
    expect(find.text('ANAMNESE NEURAL'), findsNothing);
  });
}
