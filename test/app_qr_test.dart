import 'package:flutter_test/flutter_test.dart';
import 'package:grow/core/constants/app_qr.dart';

void main() {
  group('AppQr', () {
    test('generateUserQr creates correct format', () {
      expect(
        AppQr.generateUserQr('abc-123'),
        'GROWLAB-USER-abc-123',
      );
    });

    test('generateToolQr creates correct format', () {
      expect(
        AppQr.generateToolQr('tool-456'),
        'GROWLAB-TOOL-tool-456',
      );
    });

    test('isUserQr returns true for valid user QR', () {
      expect(AppQr.isUserQr('GROWLAB-USER-abc'), isTrue);
      expect(AppQr.isUserQr('GROWLAB-TOOL-abc'), isFalse);
      expect(AppQr.isUserQr('random-string'), isFalse);
    });

    test('isToolQr returns true for valid tool QR', () {
      expect(AppQr.isToolQr('GROWLAB-TOOL-abc'), isTrue);
      expect(AppQr.isToolQr('GROWLAB-USER-abc'), isFalse);
      expect(AppQr.isToolQr('random-string'), isFalse);
    });

    test('parseUserId extracts user ID correctly', () {
      expect(AppQr.parseUserId('GROWLAB-USER-abc-123'), 'abc-123');
    });

    test('parseUserId returns null for invalid format', () {
      expect(AppQr.parseUserId('GROWLAB-TOOL-abc'), isNull);
      expect(AppQr.parseUserId('random'), isNull);
    });

    test('parseUserId returns null for empty ID', () {
      expect(AppQr.parseUserId('GROWLAB-USER-'), isNull);
    });

    test('parseToolId extracts tool ID correctly', () {
      expect(AppQr.parseToolId('GROWLAB-TOOL-tool-456'), 'tool-456');
    });

    test('parseToolId returns null for invalid format', () {
      expect(AppQr.parseToolId('GROWLAB-USER-abc'), isNull);
      expect(AppQr.parseToolId('random'), isNull);
    });

    test('parseToolId returns null for empty ID', () {
      expect(AppQr.parseToolId('GROWLAB-TOOL-'), isNull);
    });

    test('round-trip: generate then parse returns original ID', () {
      const userId = 'uuid-1234-5678';
      final qr = AppQr.generateUserQr(userId);
      expect(AppQr.parseUserId(qr), userId);

      const toolId = 'tool-abcd';
      final toolQr = AppQr.generateToolQr(toolId);
      expect(AppQr.parseToolId(toolQr), toolId);
    });
  });
}
