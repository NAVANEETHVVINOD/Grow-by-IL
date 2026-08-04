import '../constants/work_request_options.dart';

class WorkRequestDraft {
  const WorkRequestDraft({
    this.title = '',
    this.purpose = '',
    this.description = '',
    this.quantity = 1,
    this.priority = WorkRequestPriority.normal,
    this.labPreference = WorkRequestLabPreference.noPreference,
    this.preferredCompletionDate,
    this.subcategoryIds = const <String>[],
    this.memberNames = const <String>[],
    this.externalLinks = const <String>[],
    this.needsDesignSupport = false,
    this.needsMaterialProcurement = false,
    this.materialNotes = '',
    this.safetyAcknowledged = false,
    this.editApprovalAcknowledged = false,
    this.reviewSummaryConfirmed = false,
  });

  final String title;
  final String purpose;
  final String description;
  final int quantity;
  final WorkRequestPriority priority;
  final WorkRequestLabPreference labPreference;
  final DateTime? preferredCompletionDate;
  final List<String> subcategoryIds;
  final List<String> memberNames;
  final List<String> externalLinks;
  final bool needsDesignSupport;
  final bool needsMaterialProcurement;
  final String materialNotes;
  final bool safetyAcknowledged;
  final bool editApprovalAcknowledged;
  final bool reviewSummaryConfirmed;

  bool get hasAnyInput {
    return title.trim().isNotEmpty ||
        purpose.trim().isNotEmpty ||
        description.trim().isNotEmpty ||
        subcategoryIds.isNotEmpty ||
        memberNames.isNotEmpty ||
        externalLinks.isNotEmpty ||
        materialNotes.trim().isNotEmpty ||
        quantity != 1 ||
        priority != WorkRequestPriority.normal ||
        labPreference != WorkRequestLabPreference.noPreference ||
        preferredCompletionDate != null ||
        needsDesignSupport ||
        needsMaterialProcurement;
  }

  WorkRequestDraft copyWith({
    String? title,
    String? purpose,
    String? description,
    int? quantity,
    WorkRequestPriority? priority,
    WorkRequestLabPreference? labPreference,
    DateTime? preferredCompletionDate,
    bool clearPreferredCompletionDate = false,
    List<String>? subcategoryIds,
    List<String>? memberNames,
    List<String>? externalLinks,
    bool? needsDesignSupport,
    bool? needsMaterialProcurement,
    String? materialNotes,
    bool? safetyAcknowledged,
    bool? editApprovalAcknowledged,
    bool? reviewSummaryConfirmed,
  }) {
    return WorkRequestDraft(
      title: title ?? this.title,
      purpose: purpose ?? this.purpose,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      priority: priority ?? this.priority,
      labPreference: labPreference ?? this.labPreference,
      preferredCompletionDate: clearPreferredCompletionDate
          ? null
          : preferredCompletionDate ?? this.preferredCompletionDate,
      subcategoryIds: subcategoryIds ?? this.subcategoryIds,
      memberNames: memberNames ?? this.memberNames,
      externalLinks: externalLinks ?? this.externalLinks,
      needsDesignSupport: needsDesignSupport ?? this.needsDesignSupport,
      needsMaterialProcurement:
          needsMaterialProcurement ?? this.needsMaterialProcurement,
      materialNotes: materialNotes ?? this.materialNotes,
      safetyAcknowledged: safetyAcknowledged ?? this.safetyAcknowledged,
      editApprovalAcknowledged:
          editApprovalAcknowledged ?? this.editApprovalAcknowledged,
      reviewSummaryConfirmed:
          reviewSummaryConfirmed ?? this.reviewSummaryConfirmed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'purpose': purpose,
      'description': description,
      'quantity': quantity,
      'priority': priority.name,
      'labPreference': labPreference.name,
      'preferredCompletionDate': preferredCompletionDate?.toIso8601String(),
      'subcategoryIds': subcategoryIds,
      'memberNames': memberNames,
      'externalLinks': externalLinks,
      'needsDesignSupport': needsDesignSupport,
      'needsMaterialProcurement': needsMaterialProcurement,
      'materialNotes': materialNotes,
      'safetyAcknowledged': safetyAcknowledged,
      'editApprovalAcknowledged': editApprovalAcknowledged,
      'reviewSummaryConfirmed': reviewSummaryConfirmed,
    };
  }

  factory WorkRequestDraft.fromJson(Map<String, dynamic> json) {
    return WorkRequestDraft(
      title: json['title'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      description: json['description'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      priority: WorkRequestPriorityLabel.fromName(json['priority'] as String?),
      labPreference: WorkRequestLabPreferenceLabel.fromName(
        json['labPreference'] as String?,
      ),
      preferredCompletionDate: _parseDate(
        json['preferredCompletionDate'] as String?,
      ),
      subcategoryIds: _stringList(json['subcategoryIds']),
      memberNames: _stringList(json['memberNames']),
      externalLinks: _stringList(json['externalLinks']),
      needsDesignSupport: json['needsDesignSupport'] as bool? ?? false,
      needsMaterialProcurement:
          json['needsMaterialProcurement'] as bool? ?? false,
      materialNotes: json['materialNotes'] as String? ?? '',
      safetyAcknowledged: json['safetyAcknowledged'] as bool? ?? false,
      editApprovalAcknowledged:
          json['editApprovalAcknowledged'] as bool? ?? false,
      reviewSummaryConfirmed: json['reviewSummaryConfirmed'] as bool? ?? false,
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const <String>[];
    return value.whereType<String>().toList(growable: false);
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
