import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';

class ProgressService extends ChangeNotifier {
  static const String _storageKey = 'user_memory_progress_v1';
  late UserProgress _progress;

  UserProgress get progress => _progress;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  ProgressService() {
    _init();
  }

  String _getTodayString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_storageKey);
    final today = _getTodayString();

    if (rawData != null) {
      try {
        final decoded = jsonDecode(rawData) as Map<String, dynamic>;
        _progress = UserProgress.fromJson(decoded);
      } catch (e) {
        _progress = UserProgress(lastResetDate: today);
      }
    } else {
      _progress = UserProgress(lastResetDate: today);
    }

    _checkDailyReset(today);
    _isInitialized = true;
    notifyListeners();
  }

  void _checkDailyReset(String today) {
    if (_progress.lastResetDate != today) {
      _progress.lastResetDate = today;
      _progress.dailyChallengesLeft = _progress.maxChallenges;
      _save();
    }
  }

  bool canPlay() {
    return _progress.isDevUnlimited || _progress.dailyChallengesLeft > 0;
  }

  Future<void> recordGameCompleted({
    required int levelCompleted,
    required int earnedXp,
  }) async {
    final now = DateTime.now();
    final today = _getTodayString();
    _checkDailyReset(today);

    if (!_progress.isDevUnlimited && _progress.dailyChallengesLeft > 0) {
      _progress.dailyChallengesLeft--;
    }

    final finalXp = _progress.isVip ? (earnedXp * 1.5).round() : earnedXp;
    _progress.weeklyXp += finalXp;

    if (levelCompleted >= _progress.currentLevel) {
      _progress.currentLevel = levelCompleted + 1;
    }

    if (_progress.lastPlayedDate == null) {
      _progress.streak = 1;
    } else {
      final lastDate = DateFormat('yyyy-MM-dd').format(_progress.lastPlayedDate!);
      final yesterday = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));

      if (lastDate == yesterday) {
        _progress.streak += 1;
      } else if (lastDate != today) {
        _progress.streak = 1;
      }
    }

    _progress.lastPlayedDate = now;
    await _save();
    notifyListeners();
  }

  Future<void> toggleVip(bool status) async {
    _progress.isVip = status;
    if (status && _progress.dailyChallengesLeft < UserProgress.vipDailyLimit) {
      _progress.dailyChallengesLeft = UserProgress.vipDailyLimit;
    }
    await _save();
    notifyListeners();
  }

  // --- FERRAMENTAS DE DESENVOLVIMENTO & TESTES ---
  Future<void> unlockAllLevels() async {
    _progress.currentLevel = 20;
    await _save();
    notifyListeners();
  }

  Future<void> refillChallenges() async {
    _progress.dailyChallengesLeft = _progress.maxChallenges;
    await _save();
    notifyListeners();
  }

  Future<void> toggleDevUnlimited() async {
    _progress.isDevUnlimited = !_progress.isDevUnlimited;
    if (_progress.isDevUnlimited) {
      _progress.dailyChallengesLeft = 999;
    } else {
      _progress.dailyChallengesLeft = _progress.maxChallenges;
    }
    await _save();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    _progress.currentLevel = 1;
    _progress.dailyChallengesLeft = UserProgress.freeDailyLimit;
    _progress.isVip = false;
    _progress.isDevUnlimited = false;
    _progress.weeklyXp = 0;
    _progress.streak = 0;
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = jsonEncode(_progress.toJson());
    await prefs.setString(_storageKey, rawData);
  }
}
