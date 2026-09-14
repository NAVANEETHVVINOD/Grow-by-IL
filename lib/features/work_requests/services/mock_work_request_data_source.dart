import 'dart:async';
import 'package:uuid/uuid.dart';
import '../constants/work_request_options.dart';
import '../models/work_request_detail.dart';
import '../models/work_request_draft.dart';
import '../models/work_request_status_event.dart';
import '../models/work_request_summary.dart';
import 'work_request_data_source.dart';

class MockWorkRequestDataSource implements WorkRequestDataSource {
  MockWorkRequestDataSource() {
    seed();
  }

  final _controller = StreamController<List<WorkRequestSummary>>.broadcast();
  final List<WorkRequestSummary> _items = [];
  final Map<String, WorkRequestDetail> _details = {};
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

    final id = _uuid.v4();
    final newRequest = WorkRequestSummary(
      id: id,
      title: draft.title,
      purpose: draft.purpose,
      status: WorkRequestStatus.submitted,
      priority: draft.priority,
      subcategoryLabels: subcategoryLabels,
      createdAt: now,
      updatedAt: now,
      estimatedCompletionDate: draft.preferredCompletionDate,
    );

    _details[id] = WorkRequestDetail(
      id: id,
      title: draft.title,
      purpose: draft.purpose,
      description: draft.description,
      category: 'Fabrication',
      subcategoryLabels: subcategoryLabels,
      quantity: draft.quantity,
      priority: draft.priority,
      status: WorkRequestStatus.submitted,
      statusHistory: [
        WorkRequestStatusEvent(
            status: WorkRequestStatus.submitted, timestamp: now),
      ],
      createdAt: now,
      updatedAt: now,
      collaboratorNames: draft.memberNames,
      preferredCompletionDate: draft.preferredCompletionDate,
      externalLinks: draft.externalLinks,
      needsDesignSupport: draft.needsDesignSupport,
      needsMaterialProcurement: draft.needsMaterialProcurement,
      materialNotes: draft.materialNotes,
      coarseQueuePosition: 'Waiting for core-team review',
    );

    _items.add(newRequest);
    _emit();
  }

  @override
  Future<WorkRequestDetail?> fetchDetail(String id) async {
    return _details[id];
  }

  @override
  void seed() {
    _items.clear();
    _details.clear();
    final now = DateTime.now();

    _items.addAll([
      WorkRequestSummary(
        id: 'mock-1',
        title: 'Robotics chassis prototype',
        purpose: 'Robocon contest build',
        status: WorkRequestStatus.changesRequested,
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
        status: WorkRequestStatus.approved,
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
      WorkRequestSummary(
        id: 'mock-5',
        title: 'Enclosure lid prototype',
        purpose: 'Final electronics housing',
        status: WorkRequestStatus.readyForPickup,
        priority: WorkRequestPriority.normal,
        subcategoryLabels: const ['3D Printing'],
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        leaderName: 'Sara Thomas',
        leaderAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sara',
        estimatedCompletionDate: now.subtract(const Duration(hours: 1)),
      ),
    ]);

    _seedDetails(now);
    _emit();
  }

  void _seedDetails(DateTime now) {
    // Detail records for the dashboard's own seed items, matching status.
    _details['mock-1'] = WorkRequestDetail(
      id: 'mock-1',
      title: 'Robotics chassis prototype',
      purpose: 'Robocon contest build',
      description:
          'Laser-cut aluminium chassis plates plus a bracket assembly for the '
          'drivetrain motors. Team needs a stiffer frame than last year\'s '
          'acrylic version.',
      category: 'Fabrication',
      subcategoryLabels: const ['Laser Cutting', 'Mechanical Assembly'],
      quantity: 2,
      priority: WorkRequestPriority.high,
      status: WorkRequestStatus.changesRequested,
      statusHistory: [
        WorkRequestStatusEvent(
          status: WorkRequestStatus.submitted,
          timestamp: now.subtract(const Duration(days: 3)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.reviewed,
          timestamp: now.subtract(const Duration(days: 2, hours: 6)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.changesRequested,
          timestamp: now.subtract(const Duration(hours: 4)),
          note: 'Please confirm the exact aluminium sheet thickness available.',
        ),
      ],
      createdAt: now.subtract(const Duration(days: 3)),
      updatedAt: now.subtract(const Duration(hours: 4)),
      leaderName: 'Prof. Rajesh K.',
      leaderAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Rajesh',
      collaboratorNames: const ['Ayaan Verma', 'Priya Nair'],
      preferredCompletionDate: now.add(const Duration(days: 2)),
      needsDesignSupport: true,
      needsMaterialProcurement: false,
      coarseQueuePosition: 'Waiting on your response to continue review',
    );

    _details['mock-2'] = WorkRequestDetail(
      id: 'mock-2',
      title: 'PCB enclosure mockup',
      purpose: 'Mini project casing',
      description:
          'A snap-fit enclosure to house a small PCB and battery for a mini '
          'project demo.',
      category: 'Fabrication',
      subcategoryLabels: const ['3D Printing'],
      quantity: 1,
      priority: WorkRequestPriority.normal,
      status: WorkRequestStatus.approved,
      statusHistory: [
        WorkRequestStatusEvent(
          status: WorkRequestStatus.submitted,
          timestamp: now.subtract(const Duration(days: 2)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.reviewed,
          timestamp: now.subtract(const Duration(days: 1, hours: 10)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.approved,
          timestamp: now.subtract(const Duration(hours: 12)),
        ),
      ],
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(hours: 12)),
      leaderName: 'Anjali Sharma',
      leaderAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Anjali',
      preferredCompletionDate: now.add(const Duration(days: 1)),
      coarseQueuePosition: '2 requests ahead',
      machineAssignmentLabel: 'Machine assignment pending',
    );

    _details['mock-3'] = WorkRequestDetail(
      id: 'mock-3',
      title: 'Workshop badge laser cut',
      purpose: 'Innovate2026 event',
      description:
          'Acrylic badges engraved with the event logo for 40 attendees.',
      category: 'Fabrication',
      subcategoryLabels: const ['Laser Cutting'],
      quantity: 40,
      priority: WorkRequestPriority.high,
      status: WorkRequestStatus.completed,
      statusHistory: [
        WorkRequestStatusEvent(
          status: WorkRequestStatus.submitted,
          timestamp: now.subtract(const Duration(days: 5)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.approved,
          timestamp: now.subtract(const Duration(days: 4)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.inProgress,
          timestamp: now.subtract(const Duration(days: 2)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.readyForPickup,
          timestamp: now.subtract(const Duration(days: 1, hours: 6)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.completed,
          timestamp: now.subtract(const Duration(days: 1)),
        ),
      ],
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(days: 1)),
      leaderName: 'Manoj Kumar',
      leaderAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Manoj',
      paymentStateLabel: 'Paid in full',
    );

    _details['mock-4'] = WorkRequestDetail(
      id: 'mock-4',
      title: 'Acrylic test stand',
      purpose: 'Lab test setup',
      description:
          'A small test rig stand cut from 5mm acrylic and CNC-routed feet.',
      category: 'Fabrication',
      subcategoryLabels: const ['Laser Cutting', 'CNC Routing'],
      quantity: 1,
      priority: WorkRequestPriority.low,
      status: WorkRequestStatus.approved,
      statusHistory: [
        WorkRequestStatusEvent(
          status: WorkRequestStatus.submitted,
          timestamp: now.subtract(const Duration(days: 1)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.approved,
          timestamp: now.subtract(const Duration(minutes: 30)),
        ),
      ],
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(minutes: 30)),
      leaderName: 'Dr. Elizabeth',
      leaderAvatarUrl:
          'https://api.dicebear.com/7.x/avataaars/svg?seed=Elizabeth',
      preferredCompletionDate: now.add(const Duration(days: 4)),
      coarseQueuePosition: '5 requests ahead',
    );

    _details['mock-5'] = WorkRequestDetail(
      id: 'mock-5',
      title: 'Enclosure lid prototype',
      purpose: 'Final electronics housing',
      description:
          'Final-fit lid print for the electronics housing, ready to collect.',
      category: 'Fabrication',
      subcategoryLabels: const ['3D Printing'],
      quantity: 1,
      priority: WorkRequestPriority.normal,
      status: WorkRequestStatus.readyForPickup,
      statusHistory: [
        WorkRequestStatusEvent(
          status: WorkRequestStatus.submitted,
          timestamp: now.subtract(const Duration(days: 4)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.approved,
          timestamp: now.subtract(const Duration(days: 3)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.inProgress,
          timestamp: now.subtract(const Duration(days: 1)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.readyForPickup,
          timestamp: now.subtract(const Duration(hours: 2)),
        ),
      ],
      createdAt: now.subtract(const Duration(days: 4)),
      updatedAt: now.subtract(const Duration(hours: 2)),
      leaderName: 'Sara Thomas',
      leaderAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sara',
      machineAssignmentLabel: 'Printed on Bambu Lab printer',
    );

    // Additional records purely for lifecycle/status coverage that the
    // dashboard's own 5 seed items don't otherwise reach.
    _details['detail-submitted'] = WorkRequestDetail(
      id: 'detail-submitted',
      title: 'Sensor mount bracket',
      purpose: 'IoT demo project',
      description:
          'Small L-bracket to mount an ultrasonic sensor on a robot chassis.',
      category: 'Fabrication',
      subcategoryLabels: const ['3D Printing'],
      quantity: 3,
      priority: WorkRequestPriority.normal,
      status: WorkRequestStatus.submitted,
      statusHistory: [
        WorkRequestStatusEvent(
          status: WorkRequestStatus.submitted,
          timestamp: now.subtract(const Duration(hours: 3)),
        ),
      ],
      createdAt: now.subtract(const Duration(hours: 3)),
      updatedAt: now.subtract(const Duration(hours: 3)),
      leaderName: 'Devika Menon',
      coarseQueuePosition: 'Waiting for core-team review',
    );

    _details['detail-reviewed'] = WorkRequestDetail(
      id: 'detail-reviewed',
      title: 'Nameplate engraving set',
      purpose: 'Lab desk nameplates',
      description: 'Engraved wooden nameplates for 6 core-team desks.',
      category: 'Fabrication',
      subcategoryLabels: const ['Laser Cutting'],
      quantity: 6,
      priority: WorkRequestPriority.low,
      status: WorkRequestStatus.reviewed,
      statusHistory: [
        WorkRequestStatusEvent(
          status: WorkRequestStatus.submitted,
          timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.reviewed,
          timestamp: now.subtract(const Duration(hours: 1)),
        ),
      ],
      createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      updatedAt: now.subtract(const Duration(hours: 1)),
      leaderName: 'Devika Menon',
      coarseQueuePosition: 'Currently being reviewed',
    );

    _details['detail-in-progress'] = WorkRequestDetail(
      id: 'detail-in-progress',
      title: 'CNC name badge fixture',
      purpose: 'Event prep',
      description: 'A routed fixture jig for holding badges during engraving.',
      category: 'Fabrication',
      subcategoryLabels: const ['CNC Routing'],
      quantity: 1,
      priority: WorkRequestPriority.normal,
      status: WorkRequestStatus.inProgress,
      statusHistory: [
        WorkRequestStatusEvent(
          status: WorkRequestStatus.submitted,
          timestamp: now.subtract(const Duration(days: 2)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.approved,
          timestamp: now.subtract(const Duration(days: 1, hours: 12)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.inProgress,
          timestamp: now.subtract(const Duration(hours: 5)),
        ),
      ],
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(hours: 5)),
      leaderName: 'Devika Menon',
      coarseQueuePosition: 'Currently being processed',
      machineAssignmentLabel: 'Assigned to a CNC router',
    );

    _details['detail-cancelled'] = WorkRequestDetail(
      id: 'detail-cancelled',
      title: 'Trophy base engraving',
      purpose: 'Cancelled club event',
      description: 'Engraved wooden trophy bases for a club event.',
      category: 'Fabrication',
      subcategoryLabels: const ['Laser Cutting'],
      quantity: 5,
      priority: WorkRequestPriority.low,
      status: WorkRequestStatus.cancelled,
      cancellationReason:
          'The event this was needed for was cancelled by the club.',
      statusHistory: [
        WorkRequestStatusEvent(
          status: WorkRequestStatus.submitted,
          timestamp: now.subtract(const Duration(days: 6)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.approved,
          timestamp: now.subtract(const Duration(days: 5)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.cancelled,
          timestamp: now.subtract(const Duration(days: 4)),
          note: 'Cancelled by student leader before work started.',
        ),
      ],
      createdAt: now.subtract(const Duration(days: 6)),
      updatedAt: now.subtract(const Duration(days: 4)),
      leaderName: 'Devika Menon',
    );

    _details['detail-rejected-resubmittable'] = WorkRequestDetail(
      id: 'detail-rejected-resubmittable',
      title: 'Oversized poster frame',
      purpose: 'Exhibition display',
      description: 'A large poster frame cut from MDF sheets.',
      category: 'Fabrication',
      subcategoryLabels: const ['CNC Routing'],
      quantity: 1,
      priority: WorkRequestPriority.normal,
      status: WorkRequestStatus.rejected,
      rejectionType: WorkRequestRejectionType.resubmittable,
      rejectionReason:
          'Requested size exceeds the CNC router bed. Please split into panels '
          'or reduce the dimensions and resubmit.',
      statusHistory: [
        WorkRequestStatusEvent(
          status: WorkRequestStatus.submitted,
          timestamp: now.subtract(const Duration(days: 3)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.reviewed,
          timestamp: now.subtract(const Duration(days: 2)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.rejected,
          timestamp: now.subtract(const Duration(days: 2)),
          note: 'Dimensions exceed available machine bed size.',
        ),
      ],
      createdAt: now.subtract(const Duration(days: 3)),
      updatedAt: now.subtract(const Duration(days: 2)),
      leaderName: 'Devika Menon',
    );

    _details['detail-rejected-permanent'] = WorkRequestDetail(
      id: 'detail-rejected-permanent',
      title: 'Metal knife blank',
      purpose: 'Personal project',
      description: 'Requested cutting of a bladed metal knife blank.',
      category: 'Fabrication',
      subcategoryLabels: const ['CNC Routing'],
      quantity: 1,
      priority: WorkRequestPriority.normal,
      status: WorkRequestStatus.rejected,
      rejectionType: WorkRequestRejectionType.permanent,
      rejectionReason:
          'Fabricating bladed weapons is a policy violation and is not permitted '
          'under lab safety policy.',
      statusHistory: [
        WorkRequestStatusEvent(
          status: WorkRequestStatus.submitted,
          timestamp: now.subtract(const Duration(days: 7)),
        ),
        WorkRequestStatusEvent(
          status: WorkRequestStatus.rejected,
          timestamp: now.subtract(const Duration(days: 7)),
          note: 'Safety policy violation - bladed weapon fabrication.',
        ),
      ],
      createdAt: now.subtract(const Duration(days: 7)),
      updatedAt: now.subtract(const Duration(days: 7)),
      leaderName: 'Devika Menon',
    );
  }

  @override
  void clear() {
    _items.clear();
    _details.clear();
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
