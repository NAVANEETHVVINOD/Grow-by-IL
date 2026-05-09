class InventoryTransactionModel {
  const InventoryTransactionModel({
    required this.id,
    this.toolId,
    this.inventoryItemId,
    required this.userId,
    required this.type,
    this.quantityChange = 0,
    this.notes,
    this.createdAt,
    this.userName, // Join data
  });

  final String id;
  final String? toolId;
  final String? inventoryItemId;
  final String userId;
  final String
      type; // stock_in, stock_out, maintenance, damage_report, adjustment, assignment
  final int quantityChange;
  final String? notes;
  final DateTime? createdAt;
  final String? userName;

  factory InventoryTransactionModel.fromJson(Map<String, dynamic> json) {
    return InventoryTransactionModel(
      id: json['id'] as String,
      toolId: json['tool_id'] as String?,
      inventoryItemId: json['inventory_item_id'] as String?,
      userId: json['user_id'] as String,
      type: json['transaction_type'] as String,
      quantityChange: json['quantity_change'] as int? ?? 0,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toUtc()
          : null,
      userName: json['users']?['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tool_id': toolId,
      'inventory_item_id': inventoryItemId,
      'user_id': userId,
      'transaction_type': type,
      'quantity_change': quantityChange,
      'notes': notes,
    };
  }
}
