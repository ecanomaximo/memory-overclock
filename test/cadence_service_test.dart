import 'package:flutter_test/flutter_test.dart';
import 'package:memory_overclock/models/activity_cadence.dart';
import 'package:memory_overclock/services/cadence_service.dart';

void main() {
  group('CadenceService Tests', () {
    test('Initial state provides 5 activities with 5 hour cycle duration', () {
      final startTime = DateTime(2026, 11, 5, 10, 0, 0);
      final initialCadence = ActivityCadence(
        availableActivities: 5,
        maxActivities: 5,
        cycleStartTime: startTime,
      );

      final service = CadenceService(initialCadence: initialCadence);

      expect(service.availableActivities, 5);
      expect(service.canStartActivity(currentTime: startTime), isTrue);
      expect(service.formatTimeRemaining(currentTime: startTime), '05:00:00');
    });

    test('Consuming activities reduces available tokens until exhausted', () {
      final startTime = DateTime(2026, 11, 5, 10, 0, 0);
      final service = CadenceService(
        initialCadence: ActivityCadence(
          availableActivities: 2,
          cycleStartTime: startTime,
        ),
      );

      expect(service.consumeActivity(currentTime: startTime), isTrue);
      expect(service.availableActivities, 1);
      expect(service.consumeActivity(currentTime: startTime), isTrue);
      expect(service.availableActivities, 0);
      expect(service.canStartActivity(currentTime: startTime), isFalse);
      expect(service.consumeActivity(currentTime: startTime), isFalse);
    });

    test('Cycle refreshes to 5 activities when 5 hours elapse', () {
      final startTime = DateTime(2026, 11, 5, 10, 0, 0);
      final service = CadenceService(
        initialCadence: ActivityCadence(
          availableActivities: 0,
          cycleStartTime: startTime,
        ),
      );

      // 4 hours later: still 0
      final fourHoursLater = DateTime(2026, 11, 5, 14, 0, 0);
      expect(service.canStartActivity(currentTime: fourHoursLater), isFalse);
      expect(service.formatTimeRemaining(currentTime: fourHoursLater), '01:00:00');

      // 5 hours and 1 minute later: refreshed!
      final fiveHoursLater = DateTime(2026, 11, 5, 15, 1, 0);
      expect(service.canStartActivity(currentTime: fiveHoursLater), isTrue);
      expect(service.availableActivities, 5);
    });

    test('VIP user has unlimited activities regardless of remaining free tokens', () {
      final startTime = DateTime(2026, 11, 5, 10, 0, 0);
      final service = CadenceService(
        initialCadence: ActivityCadence(
          availableActivities: 0,
          cycleStartTime: startTime,
        ),
        isVip: true,
      );

      expect(service.canStartActivity(currentTime: startTime), isTrue);
      expect(service.consumeActivity(currentTime: startTime), isTrue);
      expect(service.availableActivities, 999);
    });
  });
}
