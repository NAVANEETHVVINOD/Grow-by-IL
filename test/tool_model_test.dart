import 'package:flutter_test/flutter_test.dart';
import 'package:grow/shared/models/tool_model.dart';

void main() {
  group('ToolModel Serialization Tests', () {
    test('fromJson parses complete json correctly', () {
      final json = {
        'id': 'tool-123',
        'name': '3D Printer',
        'category': 'additive_manufacturing',
        'description': 'Ender 3 Pro 3D Printer',
        'image_url': 'https://image.url',
        'sop_url': 'https://sop.url',
        'total_qty': 3,
        'available_qty': 2,
        'health_status': 'maintenance',
        'last_maintained': '2026-05-10T12:00:00.000Z',
        'qr_code_data': 'tool-qr-123',
        'created_at': '2026-05-01T08:00:00.000Z',
      };

      final tool = ToolModel.fromJson(json);

      expect(tool.id, 'tool-123');
      expect(tool.name, '3D Printer');
      expect(tool.category, 'additive_manufacturing');
      expect(tool.description, 'Ender 3 Pro 3D Printer');
      expect(tool.imageUrl, 'https://image.url');
      expect(tool.sopUrl, 'https://sop.url');
      expect(tool.totalQty, 3);
      expect(tool.availableQty, 2);
      expect(tool.healthStatus, 'maintenance');
      expect(tool.lastMaintained, DateTime.parse('2026-05-10T12:00:00.000Z'));
      expect(tool.qrCodeData, 'tool-qr-123');
      expect(tool.createdAt, DateTime.parse('2026-05-01T08:00:00.000Z'));
    });

    test('fromJson parses minimal json using defaults', () {
      final json = {
        'id': 'tool-123',
        'name': '3D Printer',
        'category': 'additive_manufacturing',
      };

      final tool = ToolModel.fromJson(json);

      expect(tool.id, 'tool-123');
      expect(tool.name, '3D Printer');
      expect(tool.category, 'additive_manufacturing');
      expect(tool.description, isNull);
      expect(tool.imageUrl, isNull);
      expect(tool.sopUrl, isNull);
      expect(tool.totalQty, 1);
      expect(tool.availableQty, 1);
      expect(tool.healthStatus, 'available');
      expect(tool.lastMaintained, isNull);
      expect(tool.qrCodeData, isNull);
      expect(tool.createdAt, isNull);
    });

    test('toJson serializes correctly', () {
      final tool = ToolModel(
        id: 'tool-123',
        name: '3D Printer',
        category: 'additive_manufacturing',
        description: 'Ender 3 Pro 3D Printer',
        imageUrl: 'https://image.url',
        sopUrl: 'https://sop.url',
        totalQty: 3,
        availableQty: 2,
        healthStatus: 'maintenance',
        lastMaintained: DateTime.parse('2026-05-10T12:00:00.000Z'),
        qrCodeData: 'tool-qr-123',
      );

      final json = tool.toJson();

      expect(json['id'], 'tool-123');
      expect(json['name'], '3D Printer');
      expect(json['category'], 'additive_manufacturing');
      expect(json['description'], 'Ender 3 Pro 3D Printer');
      expect(json['image_url'], 'https://image.url');
      expect(json['sop_url'], 'https://sop.url');
      expect(json['total_qty'], 3);
      expect(json['available_qty'], 2);
      expect(json['health_status'], 'maintenance');
      expect(json['last_maintained'], '2026-05-10T12:00:00.000Z');
      expect(json['qr_code_data'], 'tool-qr-123');
    });

    test('copyWith copies fields correctly', () {
      final tool = ToolModel(
        id: 'tool-123',
        name: '3D Printer',
        category: 'additive_manufacturing',
      );

      final updated = tool.copyWith(
        name: 'Laser Cutter',
        availableQty: 4,
      );

      expect(updated.id, 'tool-123');
      expect(updated.name, 'Laser Cutter');
      expect(updated.category, 'additive_manufacturing');
      expect(updated.availableQty, 4);
    });
  });
}
