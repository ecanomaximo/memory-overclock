import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memory_overclock/main.dart';
import 'package:memory_overclock/services/progress_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App smoke test - carrega login ou dashboard', (WidgetTester tester) async {
    final progressService = ProgressService();
    await tester.pumpWidget(MemoryOverclockApp(progressService: progressService));
    await tester.pump();
  });
}
