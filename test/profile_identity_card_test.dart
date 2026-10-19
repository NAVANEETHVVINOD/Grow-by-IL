import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grow/features/profile/presentation/widgets/digital_id_card.dart';
import 'package:grow/shared/models/user_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  const baseUser = UserModel(
    id: 'member-1',
    name: 'A Maker',
    email: 'maker@example.com',
  );

  testWidgets(
      'member card uses the account join year without claiming approval',
      (tester) async {
    final user = baseUser.copyWith(createdAt: DateTime.utc(2025, 4, 2));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: DigitalIdCard(user: user)),
    ));

    expect(find.text('MEMBER SINCE 2025'), findsOneWidget);
    expect(find.text('EST. 2024'), findsNothing);
    expect(find.text('VERIFIED MAKER'), findsNothing);
  });

  testWidgets('member card does not invent a QR when none was assigned',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: DigitalIdCard(user: baseUser)),
    ));

    expect(find.textContaining('MEMBER SINCE'), findsNothing);
    await tester.tap(find.byType(DigitalIdCard));
    await tester.pumpAndSettle();

    expect(find.text('No member QR is available for this account.'),
        findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);
  });

  testWidgets('member card uses only an assigned QR value', (tester) async {
    final user = baseUser.copyWith(qrCodeData: 'assigned-member-code');
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: DigitalIdCard(user: user)),
    ));

    await tester.tap(find.byType(DigitalIdCard));
    await tester.pumpAndSettle();

    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('This code is linked to your member profile.'),
        findsOneWidget);
  });
}
