import '../constants/work_request_options.dart';

// Canonical lifecycle per docs/01_Product/06_WORK_REQUEST_IMPLEMENTATION_CONTRACT.md
// (approved). `queued` is intentionally not a Work Request status — queueing
// belongs to the future Manufacturing Task / Machine Queue domain.
enum WorkRequestStatus {
  draft,
  submitted,
  reviewed,
  changesRequested,
  approved,
  inProgress,
  readyForPickup,
  completed,
  rejected,
  cancelled,
}

extension WorkRequestStatusLabel on WorkRequestStatus {
  String get label {
    return switch (this) {
      WorkRequestStatus.draft => 'Draft',
      WorkRequestStatus.submitted => 'Submitted',
      WorkRequestStatus.reviewed => 'Under Review',
      WorkRequestStatus.changesRequested => 'Changes Requested',
      WorkRequestStatus.approved => 'Approved',
      WorkRequestStatus.inProgress => 'In Progress',
      WorkRequestStatus.readyForPickup => 'Ready for Pickup',
      WorkRequestStatus.completed => 'Completed',
      WorkRequestStatus.rejected => 'Rejected',
      WorkRequestStatus.cancelled => 'Cancelled',
    };
  }

  static WorkRequestStatus fromName(String? value) {
    return WorkRequestStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => WorkRequestStatus.submitted,
    );
  }
}

class WorkRequestSummary {
  const WorkRequestSummary({
    required this.id,
    required this.title,
    required this.purpose,
    required this.status,
    required this.priority,
    required this.subcategoryLabels,
    required this.createdAt,
    required this.updatedAt,
    this.leaderName,
    this.leaderAvatarUrl,
    this.estimatedCompletionDate,
  });

  final String id;
  final String title;
  final String purpose;
  final WorkRequestStatus status;
  final WorkRequestPriority priority;
  final List<String> subcategoryLabels;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? leaderName;
  final String? leaderAvatarUrl;
  final DateTime? estimatedCompletionDate;

  WorkRequestSummary copyWith({
    String? id,
    String? title,
    String? purpose,
    WorkRequestStatus? status,
    WorkRequestPriority? priority,
    List<String>? subcategoryLabels,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? leaderName,
    String? leaderAvatarUrl,
    DateTime? estimatedCompletionDate,
    bool clearEstimatedCompletionDate = false,
  }) {
    return WorkRequestSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      subcategoryLabels: subcategoryLabels ?? this.subcategoryLabels,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      leaderName: leaderName ?? this.leaderName,
      leaderAvatarUrl: leaderAvatarUrl ?? this.leaderAvatarUrl,
      estimatedCompletionDate: clearEstimatedCompletionDate
          ? null
          : estimatedCompletionDate ?? this.estimatedCompletionDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'purpose': purpose,
      'status': status.name,
      'priority': priority.name,
      'subcategoryLabels': subcategoryLabels,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (leaderName != null) 'leaderName': leaderName,
      if (leaderAvatarUrl != null) 'leaderAvatarUrl': leaderAvatarUrl,
      if (estimatedCompletionDate != null)
        'estimatedCompletionDate': estimatedCompletionDate!.toIso8601String(),
    };
  }

  factory WorkRequestSummary.fromJson(Map<String, dynamic> json) {
    return WorkRequestSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      status: WorkRequestStatusLabel.fromName(json['status'] as String?),
      priority: WorkRequestPriorityLabel.fromName(json['priority'] as String?),
      subcategoryLabels: _stringList(json['subcategoryLabels']),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      leaderName: json['leaderName'] as String?,
      leaderAvatarUrl: json['leaderAvatarUrl'] as String?,
      estimatedCompletionDate:
          _parseDate(json['estimatedCompletionDate'] as String?),
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
