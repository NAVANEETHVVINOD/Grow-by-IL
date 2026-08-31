import 'dart:async';
import 'package:uuid/uuid.dart';
import '../constants/work_request_options.dart';
import '../models/work_request_draft.dart';
import '../models/work_request_summary.dart';
import 'work_request_data_source.dart';

class MockWorkRequestDataSource implements WorkRequestDataSource {
  MockWorkRequestDataSource() {
    seed();
  }

  final _controller = StreamController<List<WorkRequestSummary>>.broadcast();
  final List<WorkRequestSummary> _items = [];
  static const _uuid = Uuid();

  @override
  Stream<List<WorkRequestSummary>> watchAll() {
    return Stream<List<WorkRequestSummary>>.multi((controller) {
      controller.add(List<WorkRequestSummary>.from(_items));

      final subscription = _controller.stream.listen(
        (items) {
          if (!controller.isClosed) {
            controller.add(List<WorkRequestSummary>.from(items));
          }
        },
        onError: controller.addError,
        onDone: () {
          if (!controller.isClosed) {
            controller.close();
          }
        },
      );

      controller.onCancel = () async {
        await subscription.cancel();
        if (!controller.isClosed) {
          await controller.close();
        }
      };
    }, isBroadcast: true);
  }

  @override
  Future<void> submit(WorkRequestDraft draft) async {
    final now = DateTime.now();

    // Convert draft subcategory IDs to labels.
    final subcategoryLabels = WorkRequestOptions.fabricationSubcategories
        .where((sub) => draft.subcategoryIds.contains(sub.id))
        .map((sub) => sub.label)
        .toList();

    final newRequest = WorkRequestSummary(
      id: _uuid.v4(),
      title: draft.title,
      purpose: draft.purpose,
      status: WorkRequestStatus.submitted,
      priority: draft.priority,
      subcategoryLabels: subcategoryLabels,
      createdAt: now,
      updatedAt: now,
      estimatedCompletionDate: draft.preferredCompletionDate,
    );

    _items.add(newRequest);
    _emit();
  }

  @override
  void seed() {
    _items.clear();
    final now = DateTime.now();

    _items.addAll([
      WorkRequestSummary(
        id: 'mock-1',
        title: 'Robotics chassis prototype',
        purpose: 'Robocon contest build',
        status: WorkRequestStatus.needsChanges,
        priority: WorkRequestPriority.high,
        subcategoryLabels: const ['Laser Cutting', 'Mechanical Assembly'],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 4)),
        leaderName: 'Prof. Rajesh K.',
        leaderAvatarUrl:
            'https://api.dicebear.com/7.x/avataaars/svg?seed=Rajesh',
        estimatedCompletionDate: now.add(const Duration(days: 2)),
      ),
      WorkRequestSummary(
        id: 'mock-2',
        title: 'PCB enclosure mockup',
        purpose: 'Mini project casing',
        status: WorkRequestStatus.queued,
        priority: WorkRequestPriority.normal,
        subcategoryLabels: const ['3D Printing'],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 12)),
        leaderName: 'Anjali Sharma',
        leaderAvatarUrl:
            'https://api.dicebear.com/7.x/avataaars/svg?seed=Anjali',
        estimatedCompletionDate: now.add(const Duration(days: 1)),
      ),
      WorkRequestSummary(
        id: 'mock-3',
        title: 'Workshop badge laser cut',
        purpose: 'Innovate2026 event',
        status: WorkRequestStatus.completed,
        priority: WorkRequestPriority.high,
        subcategoryLabels: const ['Laser Cutting'],
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
        leaderName: 'Manoj Kumar',
        leaderAvatarUrl:
            'https://api.dicebear.com/7.x/avataaars/svg?seed=Manoj',
        estimatedCompletionDate: now.subtract(const Duration(days: 1)),
      ),
      WorkRequestSummary(
        id: 'mock-4',
        title: 'Acrylic test stand',
        purpose: 'Lab test setup',
        status: WorkRequestStatus.approved,
        priority: WorkRequestPriority.low,
        subcategoryLabels: const ['Laser Cutting', 'CNC Routing'],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
        leaderName: 'Dr. Elizabeth',
        leaderAvatarUrl:
            'https://api.dicebear.com/7.x/avataaars/svg?seed=Elizabeth',
        estimatedCompletionDate: now.add(const Duration(days: 4)),
      ),
    ]);

    _emit();
  }

  @override
  void clear() {
    _items.clear();
    _emit();
  }

  @override
  void reset() {
    seed();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List<WorkRequestSummary>.from(_items));
    }
  }

  void dispose() {
    _controller.close();
  }
}
