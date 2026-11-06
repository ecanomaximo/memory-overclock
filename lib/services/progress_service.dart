import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_survey.dart';
import '../models/user_progress.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

class ProgressService extends ChangeNotifier {
  static const String _storageKey = 'user_memory_progress_v1';
  late UserProgress _progress;
  final AuthService _authService;

  UserProgress get progress => _progress;
  AuthService get authService => _authService;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  ProgressService({
    UserProgress? initialProgress,
    AuthService? authService,
  }) : _authService = authService ?? AuthService() {
    if (initialProgress != null) {
      _progress = initialProgress;
      _isInitialized = true;
    } else {
      _init();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_storageKey);
    final today = _formatDate(DateTime.now());

    if (rawData != null) {
      try {
        final decoded = jsonDecode(rawData) as Map<String, dynamic>;
        _progress = UserProgress.fromJson(decoded);
      } catch (_) {
        _progress = UserProgress(lastResetDate: today);
      }
    } else {
      _progress = UserProgress(lastResetDate: today);
    }

    // Se o Firebase estiver inicializado, garante que a sessão local corresponde a uma conta real.
    // Se o usuário não estiver autenticado no Firebase (ou se o login salvo era um mock antigo),
    // força a exibição da tela de login para autenticação oficial.
    if (AuthService.isFirebaseInitialized) {
      final user = AuthService.currentUser;
      if (user == null) {
        _progress.isLoggedIn = false;
        await _save();
      } else {
        _progress.isLoggedIn = true;
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          _progress.userName = user.displayName!;
        }
        if (user.email != null && user.email!.isNotEmpty) {
          _progress.userEmail = user.email!;
        }
        if (user.photoURL != null) {
          _progress.userPhotoUrl = user.photoURL;
        }
      }
    }

    checkDailyReset();
    _isInitialized = true;
    notifyListeners();
  }

  void checkDailyReset([DateTime? now]) {
    final current = now ?? DateTime.now();
    final today = _formatDate(current);

    if (_progress.lastResetDate != today) {
      _progress.lastResetDate = today;
      _progress.dailyChallengesLeft = _progress.maxChallenges;
      _save();
    }
  }

  bool canPlay() {
    return _progress.isDevUnlimited || _progress.dailyChallengesLeft > 0;
  }

  bool consumeChallenge() {
    if (!canPlay()) return false;
    if (!_progress.isDevUnlimited && _progress.dailyChallengesLeft > 0) {
      _progress.dailyChallengesLeft--;
      _save();
      notifyListeners();
    }
    return true;
  }

  Future<void> recordGameCompleted({
    required int levelCompleted,
    required int earnedXp,
    DateTime? completionDate,
  }) async {
    final now = completionDate ?? DateTime.now();
    final today = _formatDate(now);
    checkDailyReset(now);

    // Bônus VIP de 1.5x no XP
    final multiplier = _progress.isVip ? 1.5 : 1.0;
    final finalXp = (earnedXp * multiplier).round();
    _progress.weeklyXp += finalXp;

    // Desbloqueio progressivo de fases
    if (levelCompleted >= _progress.currentLevel) {
      _progress.currentLevel = levelCompleted + 1;
    }

    // Atualização de Streak (Dias Seguidos)
    if (_progress.lastPlayedDate == null) {
      _progress.streak = 1;
    } else {
      final lastDate = _formatDate(_progress.lastPlayedDate!);
      final yesterday = _formatDate(now.subtract(const Duration(days: 1)));

      if (lastDate == yesterday) {
        _progress.streak += 1;
      } else if (lastDate != today) {
        // Se ficou mais de 1 dia sem jogar, reseta streak para 1
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
    } else if (!status && _progress.dailyChallengesLeft > UserProgress.freeDailyLimit) {
      _progress.dailyChallengesLeft = UserProgress.freeDailyLimit;
    }
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

  Future<void> refillChallenges() async {
    _progress.dailyChallengesLeft = _progress.maxChallenges;
    await _save();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    _progress = UserProgress(
      lastResetDate: _formatDate(DateTime.now()),
      currentLevel: 1,
      dailyChallengesLeft: UserProgress.freeDailyLimit,
      isVip: false,
      isDevUnlimited: false,
      weeklyXp: 0,
      streak: 0,
      isLoggedIn: false,
      hasCompletedOnboarding: false,
      surveyData: null,
    );
    await _save();
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    _progress.hasCompletedOnboarding = false;
    _progress.surveyData = null;
    await _save();
    notifyListeners();
  }

  Future<void> completeOnboarding(OnboardingSurveyData surveyData) async {
    _progress.hasCompletedOnboarding = true;
    _progress.surveyData = surveyData;
    await _save();
    notifyListeners();

    // Sincroniza respostas no Cloud Firestore
    await FirestoreService.saveSurveyResponse(
      userId: _progress.userEmail.isNotEmpty ? _progress.userEmail : null,
      userName: _progress.userName,
      userEmail: _progress.userEmail,
      authProvider: _progress.authProvider,
      surveyData: surveyData,
    );
  }

  // Autenticação integrada (Firebase Auth com suporte a Fallback)
  Future<void> loginAsGuest() async {
    _progress.isLoggedIn = true;
    _progress.userName = 'Operador Convidado';
    _progress.authProvider = 'guest';
    await _save();
    notifyListeners();
  }

  Future<AuthResult> loginWithGoogle() async {
    final result = await _authService.signInWithGoogle();
    if (result.success) {
      _progress.isLoggedIn = true;
      if (result.displayName != null && result.displayName!.isNotEmpty) {
        _progress.userName = result.displayName!;
      }
      if (result.email != null) {
        _progress.userEmail = result.email!;
      }
      if (result.photoUrl != null) {
        _progress.userPhotoUrl = result.photoUrl!;
      }
      _progress.authProvider = 'google';
      await _save();
      notifyListeners();
    }
    return result;
  }

  Future<AuthResult> loginWithApple() async {
    final result = await _authService.signInWithApple();
    if (result.success) {
      _progress.isLoggedIn = true;
      if (result.displayName != null && result.displayName!.isNotEmpty) {
        _progress.userName = result.displayName!;
      }
      if (result.email != null) {
        _progress.userEmail = result.email!;
      }
      _progress.authProvider = 'apple';
      await _save();
      notifyListeners();
    }
    return result;
  }

  Future<AuthResult> loginWithGithub() async {
    final result = await _authService.signInWithGithub();
    if (result.success) {
      _progress.isLoggedIn = true;
      if (result.displayName != null && result.displayName!.isNotEmpty) {
        _progress.userName = result.displayName!;
      }
      if (result.email != null) {
        _progress.userEmail = result.email!;
      }
      if (result.photoUrl != null) {
        _progress.userPhotoUrl = result.photoUrl!;
      }
      _progress.authProvider = 'github';
      await _save();
      notifyListeners();
    }
    return result;
  }

  Future<void> logout() async {
    await _authService.signOut();
    _progress.isLoggedIn = false;
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_progress.toJson()));
    } catch (_) {}
  }
}
