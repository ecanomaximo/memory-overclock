import 'package:flutter_test/flutter_test.dart';
import 'package:memory_overclock/games/flash_matrix_game.dart';

void main() {
  group('FlashMatrixConfig Tests', () {
    test('Nível 1 e 2 geram grade 3x3 com tempo calmo (1800ms)', () {
      final config1 = FlashMatrixConfig.forLevel(1);
      expect(config1.dimension, 3);
      expect(config1.targetCount, 3);
      expect(config1.durationMs, 1800);

      final config2 = FlashMatrixConfig.forLevel(2);
      expect(config2.dimension, 3);
      expect(config2.targetCount, 4);
      expect(config2.durationMs, 1800);
    });

    test('Nível 3 a 5 geram grade 4x4 com tempo moderado (1400ms)', () {
      final config = FlashMatrixConfig.forLevel(4);
      expect(config.dimension, 4);
      expect(config.targetCount, 5);
      expect(config.durationMs, 1400);
    });

    test('Nível 9+ gera grade 5x5 com tempo acelerado (800ms)', () {
      final config = FlashMatrixConfig.forLevel(10);
      expect(config.dimension, 5);
      expect(config.durationMs, 800);
      expect(config.targetCount, greaterThanOrEqualTo(7));
    });

    test('Cálculo de XP base vs bônus VIP 1.5x', () {
      // Nível 1: Base = 40 + (1 * 10) = 50 XP
      expect(FlashMatrixConfig.calculateXp(1, isVip: false), 50);
      // Nível 1 VIP: 50 * 1.5 = 75 XP
      expect(FlashMatrixConfig.calculateXp(1, isVip: true), 75);

      // Nível 5: Base = 40 + (5 * 10) = 90 XP
      expect(FlashMatrixConfig.calculateXp(5, isVip: false), 90);
      // Nível 5 VIP: 90 * 1.5 = 135 XP
      expect(FlashMatrixConfig.calculateXp(5, isVip: true), 135);
    });
  });
}
