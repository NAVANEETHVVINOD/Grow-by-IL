/// Represents a tool booking / time-slot reservation.
class BookingModel {
  const BookingModel({
    required this.id,
    required this.toolId,
    required this.userId,
    this.projectId,
    required this.slotStart,
    required this.slotEnd,
    required this.durationMinutes,
    this.status = 'pending',
    this.approvedBy,
    this.approvedAt,
    this.checkoutAt,
    this.returnedAt,
    this.returnReminderSent = false,
    this.notes,
    this.createdAt,
    this.toolName,
    this.userName,
  });

  final String id;
  final String toolId;
  final String userId;
  final String? projectId;
  final DateTime slotStart;
  final DateTime slotEnd;
  final int durationMinutes;
  final String status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime? checkoutAt;
  final DateTime? returnedAt;
  final bool returnReminderSent;
  final String? notes;
  final DateTime? createdAt;
  final String? toolName;
  final String? userName;

  bool get isOverdue =>
      status == 'active' && DateTime.now().toUtc().isAfter(slotEnd.toUtc());

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      toolId: json['tool_id'] as String,
      userId: json['user_id'] as String,
      projectId: json['project_id'] as String?,
      slotStart: DateTime.parse(json['slot_start'] as String).toUtc(),
      slotEnd: DateTime.parse(json['slot_end'] as String).toUtc(),
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      status: json['status'] as String? ?? 'pending',
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String).toUtc()
          : null,
      checkoutAt: json['checkout_at'] != null
          ? DateTime.parse(json['checkout_at'] as String).toUtc()
          : null,
      returnedAt: json['returned_at'] != null
          ? DateTime.parse(json['returned_at'] as String).toUtc()
          : null,
      returnReminderSent: json['return_reminder_sent'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toUtc()
          : null,
      toolName: json['tools'] is Map ? json['tools']['name'] as String? : null,
      userName: json['users'] is Map ? json['users']['full_name'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tool_id': toolId,
      'user_id': userId,
      'project_id': projectId,
      'slot_start': slotStart.toIso8601String(),
      'slot_end': slotEnd.toIso8601String(),
      'duration_minutes': durationMinutes,
      'status': status,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'checkout_at': checkoutAt?.toIso8601String(),
      'returned_at': returnedAt?.toIso8601String(),
      'return_reminder_sent': returnReminderSent,
      'notes': notes,
    };
  }

  BookingModel copyWith({
    String? id,
    String? toolId,
    String? userId,
    String? projectId,
    DateTime? slotStart,
    DateTime? slotEnd,
    int? durationMinutes,
    String? status,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? checkoutAt,
    DateTime? returnedAt,
    bool? returnReminderSent,
    String? notes,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      toolId: toolId ?? this.toolId,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      slotStart: slotStart ?? this.slotStart,
      slotEnd: slotEnd ?? this.slotEnd,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      checkoutAt: checkoutAt ?? this.checkoutAt,
      returnedAt: returnedAt ?? this.returnedAt,
      returnReminderSent: returnReminderSent ?? this.returnReminderSent,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
