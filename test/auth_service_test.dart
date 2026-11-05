import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memory_overclock/models/user_progress.dart';
import 'package:memory_overclock/services/auth_service.dart';
import 'package:memory_overclock/services/progress_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService & Progress Integration Tests', () {
    test('AuthService fallback mode returns valid Google user in test environment', () async {
      final authService = AuthService();
      final result = await authService.signInWithGoogle();

      expect(result.success, true);
      expect(result.provider, 'google');
      expect(result.displayName, contains('Google'));
      expect(result.email, contains('@gmail.com'));
    });

    test('AuthService fallback mode returns valid Apple user in test environment', () async {
      final authService = AuthService();
      final result = await authService.signInWithApple();

      expect(result.success, true);
      expect(result.provider, 'apple');
      expect(result.displayName, contains('Apple'));
      expect(result.email, contains('@privaterelay.appleid.com'));
    });

    test('ProgressService loginWithGoogle updates user state and marks logged in', () async {
      final progress = UserProgress(lastResetDate: '2026-11-05');
      final progressService = ProgressService(initialProgress: progress);

      expect(progressService.progress.isLoggedIn, false);

      final result = await progressService.loginWithGoogle();

      expect(result.success, true);
      expect(progressService.progress.isLoggedIn, true);
      expect(progressService.progress.authProvider, 'google');
      expect(progressService.progress.userName, contains('Google'));
    });

    test('ProgressService loginWithApple updates user state and marks logged in', () async {
      final progress = UserProgress(lastResetDate: '2026-11-05');
      final progressService = ProgressService(initialProgress: progress);

      final result = await progressService.loginWithApple();

      expect(result.success, true);
      expect(progressService.progress.isLoggedIn, true);
      expect(progressService.progress.authProvider, 'apple');
    });

    test('ProgressService logout revokes session and clears loggedIn state', () async {
      final progress = UserProgress(lastResetDate: '2026-11-05', isLoggedIn: true);
      final progressService = ProgressService(initialProgress: progress);

      expect(progressService.progress.isLoggedIn, true);

      await progressService.logout();

      expect(progressService.progress.isLoggedIn, false);
    });
  });
}
