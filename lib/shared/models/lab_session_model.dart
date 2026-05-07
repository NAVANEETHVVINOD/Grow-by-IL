/// Represents a lab check-in / check-out session.
class LabSessionModel {
  const LabSessionModel({
    required this.id,
    required this.userId,
    this.checkinTime,
    this.checkoutTime,
    this.purpose,
    this.createdAt,
  });

  final String id;
  final String userId;
  final DateTime? checkinTime;
  final DateTime? checkoutTime;
  final String? purpose;
  final DateTime? createdAt;

  bool get isActive => checkoutTime == null;

  Duration? get duration {
    if (checkinTime == null) return null;
    final end = checkoutTime ?? DateTime.now().toUtc();
    return end.difference(checkinTime!);
  }

  factory LabSessionModel.fromJson(Map<String, dynamic> json) {
    return LabSessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      checkinTime: json['checkin_time'] != null
          ? DateTime.parse(json['checkin_time'] as String).toUtc()
          : null,
      checkoutTime: json['checkout_time'] != null
          ? DateTime.parse(json['checkout_time'] as String).toUtc()
          : null,
      purpose: json['purpose'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toUtc()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'checkin_time': checkinTime?.toIso8601String(),
      'checkout_time': checkoutTime?.toIso8601String(),
      'purpose': purpose,
    };
  }

  LabSessionModel copyWith({
    String? id,
    String? userId,
    DateTime? checkinTime,
    DateTime? checkoutTime,
    String? purpose,
    DateTime? createdAt,
  }) {
    return LabSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkinTime: checkinTime ?? this.checkinTime,
      checkoutTime: checkoutTime ?? this.checkoutTime,
      purpose: purpose ?? this.purpose,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
