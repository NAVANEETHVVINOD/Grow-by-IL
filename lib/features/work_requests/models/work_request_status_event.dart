import '../models/work_request_summary.dart';

/// A single immutable entry in a Work Request's status history.
///
/// This is the historical audit trail. Current-state fields such as
/// rejection/cancellation reason live on [WorkRequestDetail] itself so the
/// timeline widget never needs to parse arbitrary event payloads just to
/// show the current terminal reason.
class WorkRequestStatusEvent {
  const WorkRequestStatusEvent({
    required this.status,
    required this.timestamp,
    this.note,
  });

  final WorkRequestStatus status;
  final DateTime timestamp;
  final String? note;

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      if (note != null) 'note': note,
    };
  }

  factory WorkRequestStatusEvent.fromJson(Map<String, dynamic> json) {
    return WorkRequestStatusEvent(
      status: WorkRequestStatusLabel.fromName(json['status'] as String?),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      note: json['note'] as String?,
    );
  }
}
