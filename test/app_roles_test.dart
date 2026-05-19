import 'package:flutter_test/flutter_test.dart';
import 'package:grow/core/constants/app_roles.dart';

void main() {
  group('AppRole enum', () {
    test('fromString parses all valid DB roles', () {
      expect(AppRole.fromString('student'), AppRole.student);
      expect(AppRole.fromString('lab_admin'), AppRole.labAdmin);
      expect(AppRole.fromString('super_admin'), AppRole.superAdmin);
    });

    test('fromString defaults to student for unknown roles', () {
      expect(AppRole.fromString('faculty'), AppRole.student);
      expect(AppRole.fromString('admin'), AppRole.student);
      expect(AppRole.fromString('operation_head'), AppRole.student);
      expect(AppRole.fromString(''), AppRole.student);
      expect(AppRole.fromString(null), AppRole.student);
    });

    test('value returns correct DB string', () {
      expect(AppRole.student.value, 'student');
      expect(AppRole.labAdmin.value, 'lab_admin');
      expect(AppRole.superAdmin.value, 'super_admin');
    });

    test('displayName returns human-readable label', () {
      expect(AppRole.student.displayName, 'Student');
      expect(AppRole.labAdmin.displayName, 'Lab Admin');
      expect(AppRole.superAdmin.displayName, 'Super Admin');
    });

    test('adminRoles contains only lab_admin and super_admin', () {
      expect(AppRole.adminRoles, contains(AppRole.labAdmin));
      expect(AppRole.adminRoles, contains(AppRole.superAdmin));
      expect(AppRole.adminRoles, isNot(contains(AppRole.student)));
      expect(AppRole.adminRoles.length, 2);
    });

    test('isAdminRole returns true only for admin roles', () {
      expect(AppRole.isAdminRole('lab_admin'), isTrue);
      expect(AppRole.isAdminRole('super_admin'), isTrue);
      expect(AppRole.isAdminRole('student'), isFalse);
      expect(AppRole.isAdminRole('faculty'), isFalse);
      expect(AppRole.isAdminRole(null), isFalse);
    });

    test('isSuperAdminRole returns true only for super_admin', () {
      expect(AppRole.isSuperAdminRole('super_admin'), isTrue);
      expect(AppRole.isSuperAdminRole('lab_admin'), isFalse);
      expect(AppRole.isSuperAdminRole('student'), isFalse);
    });

    test('selfAssignableRoles does not contain admin roles', () {
      for (final role in AppRole.selfAssignableRoles) {
        expect(AppRole.adminRoles, isNot(contains(role)));
      }
    });
  });
}
