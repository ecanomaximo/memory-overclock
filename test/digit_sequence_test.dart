import 'package:flutter_test/flutter_test.dart';
import 'package:memory_overclock/games/digit_sequence_game.dart';

void main() {
  group('DigitSequenceEngine Tests', () {
    test('generateSequence returns expected length with valid single digits', () {
      final seq = DigitSequenceEngine.generateSequence(length: 5);
      expect(seq.length, equals(5));
      for (final digit in seq) {
        expect(digit, inInclusiveRange(0, 9));
      }
    });

    test('getSequenceLengthForRound scales from 3 to 7 based on progression', () {
      final round1Length = DigitSequenceEngine.getSequenceLengthForRound(1, 5);
      final round5Length = DigitSequenceEngine.getSequenceLengthForRound(5, 5);

      expect(round1Length, equals(3));
      expect(round5Length, equals(7));
    });

    test('getDisplayDurationMs speeds up on higher rounds', () {
      final r1Speed = DigitSequenceEngine.getDisplayDurationMs(1);
      final r2Speed = DigitSequenceEngine.getDisplayDurationMs(2);
      final r4Speed = DigitSequenceEngine.getDisplayDurationMs(4);

      expect(r1Speed, equals(1200));
      expect(r2Speed, equals(900));
      expect(r4Speed, equals(700));
    });
  });
}
