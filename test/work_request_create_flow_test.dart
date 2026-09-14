import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/features/work_requests/application/providers/work_request_create_controller.dart';
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

      // The 'Continue' button may be off-screen in the 600px test viewport.
      // Scroll it into view before tapping.
      final continueButton = find.text('Continue');
      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();

      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Should still show the category step because validation fails
      // (no subcategoryIds selected in empty draft).
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

      // Scroll the Continue button into view and tap to advance past category.
      final continueButton = find.text('Continue');
      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();

      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // The basics step should show the restored draft fields.
      expect(find.text('Saved prototype'), findsOneWidget);
      expect(find.text('Class project'), findsOneWidget);
    });
  });

  group('WorkRequestCreateController Debounce', () {
    test('debounces draft saves and flushes pending write', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final subscription = container.listen(
        workRequestCreateControllerProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      final controller =
          container.read(workRequestCreateControllerProvider.notifier);

      // Wait for restoreDraft to complete
      await Future.delayed(Duration.zero);

      final draft1 = const WorkRequestDraft(title: 'T');
      final draft2 = const WorkRequestDraft(title: 'Te');
      final draft3 = const WorkRequestDraft(title: 'Test');

      await controller.updateDraft(draft1);
      await controller.updateDraft(draft2);
      await controller.updateDraft(draft3);

      // Verify that nothing is written to SharedPreferences yet
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('work_request_create_draft_v1'), isNull);

      // Wait 500ms (debounce is 400ms)
      await Future.delayed(const Duration(milliseconds: 500));

      // Now verify it has been written
      final raw = prefs.getString('work_request_create_draft_v1');
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded['title'], 'Test');
    });

    test('flushes pending write on dispose', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      final subscription = container.listen(
        workRequestCreateControllerProvider,
        (previous, next) {},
      );

      final controller =
          container.read(workRequestCreateControllerProvider.notifier);

      await Future.delayed(Duration.zero);

      final draft = const WorkRequestDraft(title: 'Typing done');
      await controller.updateDraft(draft);

      // Immediately dispose before 400ms
      subscription.close();
      container.dispose();

      // Verify that the final state was still flushed to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('work_request_create_draft_v1');
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded['title'], 'Typing done');
    });
  });
}
