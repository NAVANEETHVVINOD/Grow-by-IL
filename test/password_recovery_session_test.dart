import 'package:flutter_test/flutter_test.dart';
import 'package:grow/features/auth/data/password_recovery_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('recovery routing state only matches the verified user', () async {
    await PasswordRecoverySession.markPendingFor('recovery-user-123');

    expect(await PasswordRecoverySession.isPendingFor('recovery-user-123'),
        isTrue);
    expect(await PasswordRecoverySession.isPendingFor('another-user-456'),
        isFalse);
  });

  test('recovery routing state clears after completion or cancellation',
      () async {
    await PasswordRecoverySession.markPendingFor('recovery-user-123');
    await PasswordRecoverySession.clear();

    expect(await PasswordRecoverySession.isPendingFor('recovery-user-123'),
        isFalse);
  });
}
