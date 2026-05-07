import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:grow/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: GrowApp()),
    );
    await tester.pumpAndSettle();
    // Splash screen should be visible on launch
    expect(find.text('SplashScreen'), findsOneWidget);
  });
}
