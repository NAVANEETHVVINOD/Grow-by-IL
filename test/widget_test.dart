import 'package:flutter_test/flutter_test.dart';
import 'package:grow/shared/models/user_model.dart';
import 'package:grow/shared/models/project_model.dart';

void main() {
  group('Grow~ Models Tests', () {
    test('UserModel.fromJson parses successfully', () {
      final json = {
        'id': 'd61b34b1-8408-410a-bf4c-c081977e2311',
        'name': 'Test User',
        'email': 'test@example.com',
        'role': 'student',
        'profile_completed': true,
        'xp': 100,
        'level': 2,
      };
      
      final user = UserModel.fromJson(json);
      expect(user.id, 'd61b34b1-8408-410a-bf4c-c081977e2311');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.role, 'student');
      expect(user.profileCompleted, true);
    });

    test('ProjectModel.fromJson parses successfully with default status', () {
      final json = {
        'id': 'project-id-123',
        'title': 'Test Project',
        'created_by': 'creator-uuid',
      };
      
      final project = ProjectModel.fromJson(json);
      expect(project.id, 'project-id-123');
      expect(project.title, 'Test Project');
      expect(project.status, 'ideation'); // Default should be ideation per RC2 rules
    });
  });
}
