import 'package:flutter/foundation.dart';
import '../models/activity_cadence.dart';

class CadenceService extends ChangeNotifier {
  ActivityCadence _cadence;
  bool _isVip;

  CadenceService({
    ActivityCadence? initialCadence,
    bool isVip = false,
  })  : _cadence = initialCadence ?? ActivityCadence.initial(),
        _isVip = isVip;

  ActivityCadence get cadence => _cadence;
  bool get isVip => _isVip;

  int get availableActivities => _isVip ? 999 : _cadence.availableActivities;
  int get maxActivities => _cadence.maxActivities;

  void updateVipStatus(bool isVip) {
    if (_isVip != isVip) {
      _isVip = isVip;
      notifyListeners();
    }
  }

  void checkCycleRefresh({DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now();
    if (_cadence.shouldRefresh(now)) {
      _cadence = ActivityCadence(
        availableActivities: _cadence.maxActivities,
        maxActivities: _cadence.maxActivities,
        cycleStartTime: now,
        cycleDuration: _cadence.cycleDuration,
      );
      notifyListeners();
    }
  }

  bool canStartActivity({DateTime? currentTime}) {
    checkCycleRefresh(currentTime: currentTime);
    if (_isVip) return true;
    return _cadence.hasAvailableActivity;
  }

  bool consumeActivity({DateTime? currentTime}) {
    checkCycleRefresh(currentTime: currentTime);
    if (_isVip) {
      notifyListeners();
      return true;
    }

    if (_cadence.hasAvailableActivity) {
      _cadence = _cadence.copyWith(
        availableActivities: _cadence.availableActivities - 1,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  Duration getTimeRemaining({DateTime? currentTime}) {
    checkCycleRefresh(currentTime: currentTime);
    final now = currentTime ?? DateTime.now();
    return _cadence.timeRemaining(now);
  }

  String formatTimeRemaining({DateTime? currentTime}) {
    final duration = getTimeRemaining(currentTime: currentTime);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void forceRefreshForTesting({DateTime? now}) {
    final current = now ?? DateTime.now();
    _cadence = ActivityCadence(
      availableActivities: _cadence.maxActivities,
      maxActivities: _cadence.maxActivities,
      cycleStartTime: current,
      cycleDuration: _cadence.cycleDuration,
    );
    notifyListeners();
  }
}
