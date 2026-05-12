/// Represents a tool / machine in the IdeaLab inventory.
class ToolModel {
  const ToolModel({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.imageUrl,
    this.sopUrl,
    this.totalQty = 1,
    this.availableQty = 1,
    this.healthStatus = 'available',
    this.lastMaintained,
    this.qrCodeData,
    this.createdAt,
  });

  final String id;
  final String name;
  final String category;
  final String? description;
  final String? imageUrl;
  final String? sopUrl;
  final int totalQty;
  final int availableQty;
  final String healthStatus;
  final DateTime? lastMaintained;
  final String? qrCodeData;
  final DateTime? createdAt;

  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      sopUrl: json['sop_url'] as String?,
      totalQty: json['total_qty'] as int? ?? 1,
      availableQty: json['available_qty'] as int? ?? 1,
      healthStatus: json['health_status'] as String? ?? 'available',
      lastMaintained: json['last_maintained'] != null
          ? DateTime.parse(json['last_maintained'] as String)
          : null,
      qrCodeData: json['qr_code_data'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'image_url': imageUrl,
      'sop_url': sopUrl,
      'total_qty': totalQty,
      'available_qty': availableQty,
      'health_status': healthStatus,
      'last_maintained': lastMaintained?.toIso8601String(),
      'qr_code_data': qrCodeData,
    };
  }

  ToolModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? imageUrl,
    String? sopUrl,
    int? totalQty,
    int? availableQty,
    String? healthStatus,
    DateTime? lastMaintained,
    String? qrCodeData,
    DateTime? createdAt,
  }) {
    return ToolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      sopUrl: sopUrl ?? this.sopUrl,
      totalQty: totalQty ?? this.totalQty,
      availableQty: availableQty ?? this.availableQty,
      healthStatus: healthStatus ?? this.healthStatus,
      lastMaintained: lastMaintained ?? this.lastMaintained,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
