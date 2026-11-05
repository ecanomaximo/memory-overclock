import 'package:flutter_test/flutter_test.dart';
import 'package:memory_overclock/games/stroop_reflex_game.dart';

void main() {
  group('StroopEngine Tests', () {
    test('generateStimulus produces valid stimulus matching color list', () {
      final stimulus = StroopEngine.generateStimulus(round: 1);
      expect(stimulus.word, isNotEmpty);
      expect(stimulus.displayColor, isNotNull);

      if (stimulus.isMatch) {
        expect(stimulus.word, equals(stimulus.actualColorName));
      } else {
        expect(stimulus.word, isNot(equals(stimulus.actualColorName)));
      }
    });

    test('getDurationMsForRound scales down as rounds increase', () {
      final round1Duration = StroopEngine.getDurationMsForRound(1, 5);
      final round3Duration = StroopEngine.getDurationMsForRound(3, 5);
      final round5Duration = StroopEngine.getDurationMsForRound(5, 5);

      expect(round1Duration, equals(90000));
      expect(round3Duration, lessThan(round1Duration));
      expect(round5Duration, lessThan(round3Duration));
      expect(round5Duration, equals(60000));
    });
  });
}
