import 'package:flutter_test/flutter_test.dart';
import 'package:memory_overclock/main.dart';
import 'package:memory_overclock/services/progress_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final progressService = ProgressService();
    await tester.pumpWidget(MemoryOverclockApp(progressService: progressService));
  });
}
