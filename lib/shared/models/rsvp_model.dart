class RsvpModel {
  const RsvpModel({
    required this.id,
    required this.eventId,
    required this.userId,
    this.qrTicketData,
    this.status = 'going',
    this.checkedInAt,
    this.createdAt,
  });

  final String id;
  final String eventId;
  final String userId;
  final String? qrTicketData;
  final String status;
  final DateTime? checkedInAt;
  final DateTime? createdAt;

  factory RsvpModel.fromJson(Map<String, dynamic> json) {
    return RsvpModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      qrTicketData: json['qr_ticket_data'] as String?,
      status: json['status'] as String? ?? 'going',
      checkedInAt: json['checked_in_at'] != null 
          ? DateTime.parse(json['checked_in_at'] as String).toUtc() 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String).toUtc() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'qr_ticket_data': qrTicketData,
      'status': status,
      'checked_in_at': checkedInAt?.toIso8601String(),
    };
  }
}
