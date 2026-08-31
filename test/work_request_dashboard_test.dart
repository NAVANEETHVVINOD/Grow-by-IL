import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/features/work_requests/application/providers/work_request_dashboard_controller.dart';
import 'package:grow/features/work_requests/constants/work_request_options.dart';
import 'package:grow/features/work_requests/models/work_request_draft.dart';
import 'package:grow/features/work_requests/models/work_request_summary.dart';
import 'package:grow/features/work_requests/services/work_request_data_source.dart';
import 'package:grow/features/work_requests/services/mock_work_request_data_source.dart';
import 'package:grow/features/work_requests/presentation/screens/work_requests_screen.dart';
import 'package:grow/features/work_requests/presentation/widgets/work_request_card.dart';

/// Avatar URLs in the seed data are real network images. Widget tests must
/// not depend on network availability, so every HTTP request is failed
/// immediately instead of being attempted for real.
class _NoNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _NoNetworkHttpClient();
  }
}

class _NoNetworkHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      Future.error(const SocketException('Network disabled in tests'));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      Future.error(const SocketException('Network disabled in tests'));
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _NoNetworkHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('MockWorkRequestDataSource & Summary model', () {
    test('initializes with seed mock data', () async {
      final dataSource = MockWorkRequestDataSource();
      final list = await dataSource.watchAll().first;
      expect(list.length, 4);
      expect(list.any((r) => r.title == 'Robotics chassis prototype'), isTrue);
      expect(list.any((r) => r.status == WorkRequestStatus.completed), isTrue);
    });

    test('supports submit draft, reset, and clear', () async {
      final dataSource = MockWorkRequestDataSource();

      const draft = WorkRequestDraft(
        title: 'New custom draft',
        purpose: 'Testing submit',
        priority: WorkRequestPriority.high,
        subcategoryIds: ['laser_cutting'],
      );

      await dataSource.submit(draft);
      var list = await dataSource.watchAll().first;
      expect(list.length, 5);
      expect(list.any((r) => r.title == 'New custom draft'), isTrue);
      expect(list.firstWhere((r) => r.title == 'New custom draft').status,
          WorkRequestStatus.submitted);

      dataSource.clear();
      list = await dataSource.watchAll().first;
      expect(list, isEmpty);

      dataSource.reset();
      list = await dataSource.watchAll().first;
      expect(list.length, 4);
    });

    test('emits an initial snapshot from watchAll', () async {
      final dataSource = MockWorkRequestDataSource();

      final initialSnapshot = await dataSource.watchAll().first;

      expect(initialSnapshot.length, 4);
      expect(
          initialSnapshot.any((r) => r.title == 'Robotics chassis prototype'),
          isTrue);
    });
  });

  group('WorkRequestDashboardController logic', () {
    late ProviderContainer container;
    late MockWorkRequestDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockWorkRequestDataSource();
      container = ProviderContainer(
        overrides: [
          workRequestDataSourceProvider.overrideWithValue(mockDataSource),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('derives metrics correctly from mock data', () async {
      container.listen(workRequestDashboardControllerProvider, (_, __) {});

      // Wait for microtask (scheduleMicrotask in watchAll) + stream listener
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);
      final state = container.read(workRequestDashboardControllerProvider);

      expect(state.requests.length, 4);
      expect(state.draftCount, 0); // Seed data does not have draft status
      expect(state.submittedCount,
          0); // No seed data has submitted or underReview status
      // Seed: needsChanges(1), queued(1), completed(1), approved(1)
      expect(state.approvedCount, 2);
      expect(state.completedCount, 1);
    });

    test('filters search query across title, purpose, and subcategories',
        () async {
      container.listen(workRequestDashboardControllerProvider, (_, __) {});
      final controller =
          container.read(workRequestDashboardControllerProvider.notifier);
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      // Search matching title
      controller.setSearchQuery('chassis');
      expect(
          container
              .read(workRequestDashboardControllerProvider)
              .requests
              .length,
          1);
      expect(
          container
              .read(workRequestDashboardControllerProvider)
              .requests
              .first
              .title,
          'Robotics chassis prototype');

      // Search matching purpose
      controller.setSearchQuery('Innovate2026');
      expect(
          container
              .read(workRequestDashboardControllerProvider)
              .requests
              .length,
          1);
      expect(
          container
              .read(workRequestDashboardControllerProvider)
              .requests
              .first
              .title,
          'Workshop badge laser cut');

      // Search matching subcategory
      controller.setSearchQuery('CNC Routing');
      expect(
          container
              .read(workRequestDashboardControllerProvider)
              .requests
              .length,
          1);
      expect(
          container
              .read(workRequestDashboardControllerProvider)
              .requests
              .first
              .title,
          'Acrylic test stand');
    });

    test('filters status and priority combination', () async {
      container.listen(workRequestDashboardControllerProvider, (_, __) {});
      final controller =
          container.read(workRequestDashboardControllerProvider.notifier);
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      // Filter by status approved
      controller.setStatusFilter(WorkRequestStatus.approved);
      expect(
          container
              .read(workRequestDashboardControllerProvider)
              .requests
              .length,
          1);

      // Filter by priority low (acrylic test stand is approved + low)
      controller.setPriorityFilter(WorkRequestPriority.low);
      expect(
          container
              .read(workRequestDashboardControllerProvider)
              .requests
              .length,
          1);

      // Filter by priority high (no approved requests have high priority)
      controller.setPriorityFilter(WorkRequestPriority.high);
      expect(container.read(workRequestDashboardControllerProvider).requests,
          isEmpty);
    });

    test('sorts list by newest, oldest, priority, and alphabetical', () async {
      container.listen(workRequestDashboardControllerProvider, (_, __) {});
      final controller =
          container.read(workRequestDashboardControllerProvider.notifier);
      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      // Alphabetical sort
      controller.setSortBy(WorkRequestSortBy.alphabetical);
      var requests =
          container.read(workRequestDashboardControllerProvider).requests;
      expect(requests.first.title, 'Acrylic test stand');
      expect(requests.last.title, 'Workshop badge laser cut');

      // Priority descending (high, then normal, then low); ties break newest-first.
      controller.setSortBy(WorkRequestSortBy.priorityDescending);
      requests =
          container.read(workRequestDashboardControllerProvider).requests;
      expect(requests[0].title,
          'Robotics chassis prototype'); // high, created 3 days ago
      expect(
          requests[1].title, 'Workshop badge laser cut'); // high, 5 days ago
      expect(requests.last.priority, WorkRequestPriority.low); // Acrylic
    });
  });

  group('WorkRequestsScreen Widget Tests', () {
    testWidgets('renders search field, filters, and seed request cards',
        (tester) async {
      final mockDataSource = MockWorkRequestDataSource();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workRequestDataSourceProvider.overrideWithValue(mockDataSource),
          ],
          child: const MaterialApp(
            home: WorkRequestsScreen(),
          ),
        ),
      );

      // Pump to process scheduleMicrotask in watchAll(), then settle animations.
      await tester.pump();
      await tester.idle();
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(WorkRequestsScreen)),
      );
      final state = container.read(workRequestDashboardControllerProvider);
      expect(state.requests.length, greaterThan(0),
          reason: 'Controller state should have seeded requests.');

      expect(find.text('Work Requests'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      final verticalScrollable = find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
        description: 'vertical Scrollable',
      );

      await tester.scrollUntilVisible(
        find.text('Robotics chassis prototype'),
        200,
        scrollable: verticalScrollable,
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('PCB enclosure mockup'),
        200,
        scrollable: verticalScrollable,
      );
      await tester.pumpAndSettle();

      expect(find.byType(WorkRequestCard), findsWidgets,
          reason:
              'Request cards should be built when state.requests is non-empty.');
      expect(find.text('Robotics chassis prototype'), findsOneWidget);
      expect(find.text('PCB enclosure mockup'), findsOneWidget);
    });

    testWidgets('shows empty state and clears filters correctly',
        (tester) async {
      final mockDataSource = MockWorkRequestDataSource();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workRequestDataSourceProvider.overrideWithValue(mockDataSource),
          ],
          child: const MaterialApp(
            home: WorkRequestsScreen(),
          ),
        ),
      );

      // Pump to process scheduleMicrotask in watchAll(), then settle animations.
      await tester.pump();
      await tester.idle();
      await tester.pumpAndSettle();

      // Enter search query that will not match anything
      await tester.enterText(find.byType(TextField), 'Nonexistent Query');
      await tester.pump();
      await tester.idle();
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(WorkRequestsScreen)),
      );
      final stateAfterSearch =
          container.read(workRequestDashboardControllerProvider);
      debugPrint(
          'Dashboard state after search: ${stateAfterSearch.requests.length} requests');

      final verticalScrollable = find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
        description: 'vertical Scrollable',
      );
      await tester.scrollUntilVisible(
        find.text('No requests found'),
        200,
        scrollable: verticalScrollable,
      );
      await tester.pumpAndSettle();

      // Verify empty state is displayed
      expect(find.text('No requests found'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);

      // Tap clear action on empty state
      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();

      // Verify requests are restored
      expect(find.text('Robotics chassis prototype'), findsOneWidget);
    });
  });
}
