class InventoryItemModel {
  const InventoryItemModel({
    required this.id,
    required this.name,
    this.description,
    this.category,
    required this.type,
    required this.quantity,
    this.minQuantity = 0,
    this.unit = 'unit',
    this.storageLocation,
    this.imageUrl,
    this.projectId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? category;
  final String type; // consumable, component, kit
  final int quantity;
  final int minQuantity;
  final String unit;
  final String? storageLocation;
  final String? imageUrl;
  final String? projectId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isLowStock => quantity <= minQuantity;
  bool get isConsumable => type == 'consumable';
  bool get isKit => type == 'kit';

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      type: json['item_type'] as String,
      quantity: json['quantity'] as int,
      minQuantity: json['min_quantity'] as int? ?? 0,
      unit: json['unit'] as String? ?? 'unit',
      storageLocation: json['storage_location'] as String?,
      imageUrl: json['image_url'] as String?,
      projectId: json['project_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toUtc()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toUtc()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'item_type': type,
      'quantity': quantity,
      'min_quantity': minQuantity,
      'unit': unit,
      'storage_location': storageLocation,
      'image_url': imageUrl,
      'project_id': projectId,
    };
  }

  InventoryItemModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? type,
    int? quantity,
    int? minQuantity,
    String? unit,
    String? storageLocation,
    String? imageUrl,
    String? projectId,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      minQuantity: minQuantity ?? this.minQuantity,
      unit: unit ?? this.unit,
      storageLocation: storageLocation ?? this.storageLocation,
      imageUrl: imageUrl ?? this.imageUrl,
      projectId: projectId ?? this.projectId,
    );
  }
}
