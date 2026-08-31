import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grow/shared/widgets/rc5/rc5_badge.dart';
import 'package:grow/shared/widgets/rc5/rc5_loading.dart';

void main() {
  testWidgets('RC5Badge renders its label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RC5Badge(label: 'New'),
        ),
      ),
    );

    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('RC5Loading renders a progress indicator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RC5Loading(label: 'Loading data'),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading data'), findsOneWidget);
  });
}
