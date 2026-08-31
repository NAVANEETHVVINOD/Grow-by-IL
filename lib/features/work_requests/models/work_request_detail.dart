import '../constants/work_request_options.dart';
import 'work_request_status_event.dart';
import 'work_request_summary.dart';

enum WorkRequestRejectionType {
  resubmittable,
  permanent,
}

extension WorkRequestRejectionTypeLabel on WorkRequestRejectionType {
  String get label {
    return switch (this) {
      WorkRequestRejectionType.resubmittable => 'Resubmittable',
      WorkRequestRejectionType.permanent => 'Permanent',
    };
  }

  static WorkRequestRejectionType? fromName(String? value) {
    if (value == null) return null;
    for (final type in WorkRequestRejectionType.values) {
      if (type.name == value) return type;
    }
    return null;
  }
}

/// The full student-facing view of a single Work Request.
///
/// Kept separate from [WorkRequestSummary] (the lightweight card/list model)
/// rather than bloating it, since Detail needs description, quantity,
/// collaborators, links, design/material info, rejection/cancellation
/// state, and status history that the dashboard never renders.
class WorkRequestDetail {
  const WorkRequestDetail({
    required this.id,
    required this.title,
    required this.purpose,
    required this.description,
    required this.category,
    required this.subcategoryLabels,
    required this.quantity,
    required this.priority,
    required this.status,
    required this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
    this.leaderName,
    this.leaderAvatarUrl,
    this.collaboratorNames = const <String>[],
    this.preferredCompletionDate,
    this.externalLinks = const <String>[],
    this.needsDesignSupport = false,
    this.needsMaterialProcurement = false,
    this.materialNotes = '',
    this.rejectionType,
    this.rejectionReason,
    this.cancellationReason,
    this.coarseQueuePosition,
    this.paymentStateLabel,
    this.machineAssignmentLabel,
  });

  final String id;
  final String title;
  final String purpose;
  final String description;
  final String category;
  final List<String> subcategoryLabels;
  final int quantity;
  final WorkRequestPriority priority;
  final WorkRequestStatus status;

  /// Immutable historical timeline. The current terminal reason for a
  /// rejected/cancelled request lives on [rejectionReason]/
  /// [cancellationReason] below, not parsed out of this list.
  final List<WorkRequestStatusEvent> statusHistory;

  final String? leaderName;
  final String? leaderAvatarUrl;
  final List<String> collaboratorNames;
  final DateTime? preferredCompletionDate;
  final List<String> externalLinks;
  final bool needsDesignSupport;
  final bool needsMaterialProcurement;
  final String materialNotes;

  final WorkRequestRejectionType? rejectionType;
  final String? rejectionReason;
  final String? cancellationReason;

  /// Coarse, student-safe queue information only, e.g. "3 requests ahead"
  /// or "Currently being reviewed". Never the raw internal queue.
  final String? coarseQueuePosition;

  /// UI placeholder only - no payment backend exists yet.
  final String? paymentStateLabel;

  /// UI placeholder only - no machine/task persistence exists yet.
  final String? machineAssignmentLabel;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get canResubmit =>
      status == WorkRequestStatus.rejected &&
      rejectionType == WorkRequestRejectionType.resubmittable;

  bool get isPermanentlyRejected =>
      status == WorkRequestStatus.rejected &&
      rejectionType == WorkRequestRejectionType.permanent;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'purpose': purpose,
      'description': description,
      'category': category,
      'subcategoryLabels': subcategoryLabels,
      'quantity': quantity,
      'priority': priority.name,
      'status': status.name,
      'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (leaderName != null) 'leaderName': leaderName,
      if (leaderAvatarUrl != null) 'leaderAvatarUrl': leaderAvatarUrl,
      'collaboratorNames': collaboratorNames,
      if (preferredCompletionDate != null)
        'preferredCompletionDate': preferredCompletionDate!.toIso8601String(),
      'externalLinks': externalLinks,
      'needsDesignSupport': needsDesignSupport,
      'needsMaterialProcurement': needsMaterialProcurement,
      'materialNotes': materialNotes,
      if (rejectionType != null) 'rejectionType': rejectionType!.name,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      if (coarseQueuePosition != null)
        'coarseQueuePosition': coarseQueuePosition,
      if (paymentStateLabel != null) 'paymentStateLabel': paymentStateLabel,
      if (machineAssignmentLabel != null)
        'machineAssignmentLabel': machineAssignmentLabel,
    };
  }

  factory WorkRequestDetail.fromJson(Map<String, dynamic> json) {
    return WorkRequestDetail(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      subcategoryLabels: _stringList(json['subcategoryLabels']),
      quantity: json['quantity'] as int? ?? 1,
      priority: WorkRequestPriorityLabel.fromName(json['priority'] as String?),
      status: WorkRequestStatusLabel.fromName(json['status'] as String?),
      statusHistory: (json['statusHistory'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(WorkRequestStatusEvent.fromJson)
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      leaderName: json['leaderName'] as String?,
      leaderAvatarUrl: json['leaderAvatarUrl'] as String?,
      collaboratorNames: _stringList(json['collaboratorNames']),
      preferredCompletionDate:
          _parseDate(json['preferredCompletionDate'] as String?),
      externalLinks: _stringList(json['externalLinks']),
      needsDesignSupport: json['needsDesignSupport'] as bool? ?? false,
      needsMaterialProcurement:
          json['needsMaterialProcurement'] as bool? ?? false,
      materialNotes: json['materialNotes'] as String? ?? '',
      rejectionType: WorkRequestRejectionTypeLabel.fromName(
          json['rejectionType'] as String?),
      rejectionReason: json['rejectionReason'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      coarseQueuePosition: json['coarseQueuePosition'] as String?,
      paymentStateLabel: json['paymentStateLabel'] as String?,
      machineAssignmentLabel: json['machineAssignmentLabel'] as String?,
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const <String>[];
    return value.whereType<String>().toList();
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
