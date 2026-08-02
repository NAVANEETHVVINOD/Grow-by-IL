import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/features/work_requests/models/work_request_draft.dart';
import 'package:grow/features/work_requests/presentation/screens/create_work_request_screen.dart';
import 'package:grow/features/work_requests/services/draft_storage/work_request_draft_storage.dart';
import 'package:grow/features/work_requests/utils/work_request_validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WorkRequestValidators', () {
    test('validates required basic fields', () {
      const draft = WorkRequestDraft(
        title: '',
        purpose: '',
        description: 'too short',
        quantity: 0,
      );

      final errors = WorkRequestValidators.validateBasics(draft);

      expect(errors, contains('Add a short request title.'));
      expect(errors, contains('Tell us why this work is needed.'));
      expect(errors, contains('Description must be at least 20 characters.'));
      expect(errors, contains('Quantity must be at least 1.'));
    });

    test('accepts multiple fabrication subcategories', () {
      const draft = WorkRequestDraft(
        subcategoryIds: ['laser_cutting', '3d_printing'],
      );

      final errors = WorkRequestValidators.validateFabrication(draft);

      expect(errors, isEmpty);
    });

    test('requires material notes only when procurement is selected', () {
      const draft = WorkRequestDraft(needsMaterialProcurement: true);

      final errors = WorkRequestValidators.validateDesignAndMaterial(draft);

      expect(errors, contains('Add material notes or requirements.'));
    });
  });

  group('WorkRequestDraftStorage', () {
    test('saves, restores, and clears a local draft', () async {
      SharedPreferences.setMockInitialValues({});
      const storage = WorkRequestDraftStorage();
      const draft = WorkRequestDraft(
        title: 'Laser chassis',
        purpose: 'Prototype work',
        description: 'Need a laser cut chassis for a robotics prototype.',
        quantity: 2,
        subcategoryIds: ['laser_cutting'],
      );

      await storage.saveDraft(draft);
      final restored = await storage.loadDraft();

      expect(restored?.title, 'Laser chassis');
      expect(restored?.quantity, 2);
      expect(restored?.subcategoryIds, ['laser_cutting']);

      await storage.clearDraft();
      expect(await storage.loadDraft(), isNull);
    });

    test('ignores corrupted local draft payloads', () async {
      SharedPreferences.setMockInitialValues({
        'work_request_create_draft_v1': '{not-json',
      });

      const storage = WorkRequestDraftStorage();

      expect(await storage.loadDraft(), isNull);
    });
  });

  group('CreateWorkRequestScreen', () {
    testWidgets('blocks continuing without fabrication subcategory',
        (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: CreateWorkRequestScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Tell us the basics'), findsNothing);
      expect(find.text('What kind of help do you need?'), findsOneWidget);
    });

    testWidgets('restores saved local draft into basics step fields',
        (tester) async {
      final savedDraft = const WorkRequestDraft(
        title: 'Saved prototype',
        purpose: 'Class project',
        description: 'This saved draft has enough detail to restore correctly.',
        quantity: 3,
        subcategoryIds: ['laser_cutting'],
      ).toJson();

      SharedPreferences.setMockInitialValues({
        'work_request_create_draft_v1': jsonEncode(savedDraft),
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: CreateWorkRequestScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Saved prototype'), findsOneWidget);
      expect(find.text('Class project'), findsOneWidget);
    });
  });
}
