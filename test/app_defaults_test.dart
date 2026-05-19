import 'package:flutter_test/flutter_test.dart';
import 'package:grow/core/constants/app_defaults.dart';
import 'package:grow/core/constants/app_qr.dart';
import 'package:grow/core/constants/app_roles.dart';

void main() {
  group('AppDefaults', () {
    test('default values match DB schema defaults', () {
      expect(AppDefaults.defaultRole, AppRole.student);
      expect(AppDefaults.defaultXp, 0);
      expect(AppDefaults.defaultLevel, 1);
      expect(AppDefaults.defaultReputationScore, 100);
      expect(AppDefaults.defaultProfileCompleted, false);
      expect(AppDefaults.defaultUserName, 'Maker');
    });

    test('buildNewUserRow contains all required DB columns', () {
      final row = AppDefaults.buildNewUserRow(
        userId: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
      );

      expect(row['id'], 'test-id');
      expect(row['name'], 'Test User');
      expect(row['email'], 'test@example.com');
      expect(row['role'], AppRole.student.value);
      expect(row['profile_completed'], false);
      expect(row['xp'], 0);
      expect(row['level'], 1);
      expect(row['reputation_score'], 100);
      expect(row['qr_code_data'], AppQr.generateUserQr('test-id'));
    });

    test('buildNewUserRow uses defaultUserName for empty name', () {
      final row = AppDefaults.buildNewUserRow(
        userId: 'test-id',
        name: '',
        email: 'test@example.com',
      );

      expect(row['name'], AppDefaults.defaultUserName);
    });

    test('buildNewUserRow includes optional fields when provided', () {
      final row = AppDefaults.buildNewUserRow(
        userId: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        phone: '+91-9999999999',
        collegeRoll: 'CSE-001',
      );

      expect(row['phone'], '+91-9999999999');
      expect(row['college_roll'], 'CSE-001');
    });

    test('buildNewUserRow excludes optional fields when null', () {
      final row = AppDefaults.buildNewUserRow(
        userId: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
      );

      expect(row.containsKey('phone'), isFalse);
      expect(row.containsKey('college_roll'), isFalse);
    });
  });
}
