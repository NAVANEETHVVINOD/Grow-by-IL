class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.organizationName,
    this.clubId,
    required this.eventDate,
    this.endDate,
    this.venue,
    this.capacity,
    this.rsvpCount = 0,
    this.imageUrl,
    required this.createdBy,
    this.status = 'published',
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final String type;
  final String? organizationName;
  final String? clubId;
  final DateTime eventDate;
  final DateTime? endDate;
  final String? venue;
  final int? capacity;
  final int rsvpCount;
  final String? imageUrl;
  final String createdBy;
  final String status;
  final DateTime? createdAt;

  bool get isFull => capacity != null && rsvpCount >= capacity!;
  bool get isCancelled => status == 'cancelled';
  bool get isPast => endDate != null
      ? DateTime.now().toUtc().isAfter(endDate!)
      : DateTime.now().toUtc().isAfter(eventDate.add(const Duration(hours: 3)));

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['event_type'] as String? ?? 'workshop',
      organizationName: json['organization_name'] as String?,
      clubId: json['club_id'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String).toUtc(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String).toUtc()
          : null,
      venue: json['venue'] as String?,
      capacity: json['capacity'] as int?,
      rsvpCount: json['rsvp_count'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
      createdBy: json['created_by'] as String,
      status: json['status'] as String? ?? 'published',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toUtc()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_type': type,
      'organization_name': organizationName,
      'club_id': clubId,
      'event_date': eventDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'venue': venue,
      'capacity': capacity,
      'rsvp_count': rsvpCount,
      'image_url': imageUrl,
      'created_by': createdBy,
      'status': status,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? organizationName,
    String? clubId,
    DateTime? eventDate,
    DateTime? endDate,
    String? venue,
    int? capacity,
    int? rsvpCount,
    String? imageUrl,
    String? createdBy,
    String? status,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      organizationName: organizationName ?? this.organizationName,
      clubId: clubId ?? this.clubId,
      eventDate: eventDate ?? this.eventDate,
      endDate: endDate ?? this.endDate,
      venue: venue ?? this.venue,
      capacity: capacity ?? this.capacity,
      rsvpCount: rsvpCount ?? this.rsvpCount,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
