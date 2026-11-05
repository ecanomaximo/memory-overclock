import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memory_overclock/models/user_progress.dart';
import 'package:memory_overclock/services/progress_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProgressService Tests', () {
    test('Inicializa com 3 desafios diários gratuitos para usuário Free', () {
      final initial = UserProgress(lastResetDate: '2026-11-05');
      final service = ProgressService(initialProgress: initial);

      expect(service.progress.dailyChallengesLeft, 3);
      expect(service.progress.isVip, false);
      expect(service.canPlay(), true);
    });

    test('Consome desafios e bloqueia ao zerar', () {
      final initial = UserProgress(lastResetDate: '2026-11-05');
      final service = ProgressService(initialProgress: initial);

      expect(service.consumeChallenge(), true);
      expect(service.progress.dailyChallengesLeft, 2);

      expect(service.consumeChallenge(), true);
      expect(service.progress.dailyChallengesLeft, 1);

      expect(service.consumeChallenge(), true);
      expect(service.progress.dailyChallengesLeft, 0);

      expect(service.canPlay(), false);
      expect(service.consumeChallenge(), false);
    });

    test('Reset diário à meia-noite restaura os desafios', () {
      final initial = UserProgress(
        lastResetDate: '2026-11-04',
        dailyChallengesLeft: 0,
      );
      final service = ProgressService(initialProgress: initial);

      service.checkDailyReset(DateTime(2026, 11, 5, 0, 1));
      expect(service.progress.dailyChallengesLeft, 3);
      expect(service.progress.lastResetDate, '2026-11-05');
    });

    test('Ativação VIP eleva o limite diário para 10 e concede bônus de 1.5x no XP', () async {
      final initial = UserProgress(lastResetDate: '2026-11-05');
      final service = ProgressService(initialProgress: initial);

      await service.toggleVip(true);
      expect(service.progress.isVip, true);
      expect(service.progress.dailyChallengesLeft, 10);

      // 100 XP base -> 150 XP para VIP
      await service.recordGameCompleted(
        levelCompleted: 1,
        earnedXp: 100,
        completionDate: DateTime(2026, 11, 5, 10, 0),
      );

      expect(service.progress.weeklyXp, 150);
      expect(service.progress.currentLevel, 2);
    });

    test('Streak incrementa em dias consecutivos e reseta após dias de inatividade', () async {
      final initial = UserProgress(lastResetDate: '2026-11-01');
      final service = ProgressService(initialProgress: initial);

      // Dia 1
      await service.recordGameCompleted(
        levelCompleted: 1,
        earnedXp: 50,
        completionDate: DateTime(2026, 11, 1, 10, 0),
      );
      expect(service.progress.streak, 1);

      // Dia 2 consecutivo
      await service.recordGameCompleted(
        levelCompleted: 2,
        earnedXp: 50,
        completionDate: DateTime(2026, 11, 2, 10, 0),
      );
      expect(service.progress.streak, 2);

      // Dia 2 novamente (mesmo dia não aumenta)
      await service.recordGameCompleted(
        levelCompleted: 2,
        earnedXp: 50,
        completionDate: DateTime(2026, 11, 2, 18, 0),
      );
      expect(service.progress.streak, 2);

      // Dia 5 (pulou 3 dias sem jogar -> reseta para 1)
      await service.recordGameCompleted(
        levelCompleted: 3,
        earnedXp: 50,
        completionDate: DateTime(2026, 11, 5, 10, 0),
      );
      expect(service.progress.streak, 1);
    });
  });
}
