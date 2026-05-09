import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/inventory_item_model.dart';
import '../../../shared/models/inventory_transaction_model.dart';

class InventoryRepository {
  InventoryRepository(this._client);
  final SupabaseClient _client;

  /// Fetch all inventory items (consumables, components, kits).
  Future<List<InventoryItemModel>> getInventoryItems({
    String? category,
    String? type,
  }) async {
    AppLogger.action(LogCategory.inventory, 'getInventoryItems', {
      'category': category,
      'type': type,
    });
    try {
      var query = _client.from('inventory_items').select();
      if (category != null && category != 'All') {
        query = query.eq('category', category);
      }
      if (type != null) {
        query = query.eq('item_type', type);
      }

      final data = await query.order('name', ascending: true);
      return (data as List)
          .map((row) => InventoryItemModel.fromJson(row))
          .toList();
    } catch (e, st) {
      AppLogger.error(
        LogCategory.inventory,
        'getInventoryItems failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Adjust stock for an inventory item and log transaction.
  Future<void> adjustStock({
    required String itemId,
    required String userId,
    required int change,
    required String transactionType,
    String? notes,
  }) async {
    AppLogger.action(LogCategory.inventory, 'adjustStock', {
      'itemId': itemId,
      'change': change,
    });
    try {
      // 1. Fetch current quantity to ensure no negative stock
      final item = await _client
          .from('inventory_items')
          .select('quantity')
          .eq('id', itemId)
          .single();
      final newQty = (item['quantity'] as int) + change;
      if (newQty < 0) throw Exception('Insufficient stock.');

      // 2. Update Inventory Item
      await _client
          .from('inventory_items')
          .update({
            'quantity': newQty,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', itemId);

      // 3. Log Transaction
      await _client.from('inventory_transactions').insert({
        'inventory_item_id': itemId,
        'user_id': userId,
        'transaction_type': transactionType,
        'quantity_change': change,
        'notes': notes,
      });

      AppLogger.info(
        LogCategory.inventory,
        'Stock adjusted for $itemId: $change',
      );
    } catch (e, st) {
      AppLogger.error(
        LogCategory.inventory,
        'adjustStock failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Log maintenance or damage for a Tool.
  Future<void> logToolStatus({
    required String toolId,
    required String userId,
    required String transactionType, // maintenance, damage_report
    required String newStatus,
    String? notes,
  }) async {
    AppLogger.action(LogCategory.inventory, 'logToolStatus', {
      'toolId': toolId,
      'type': transactionType,
    });
    try {
      // 1. Update Tool Status
      await _client
          .from('tools')
          .update({
            'health_status': newStatus,
            'last_maintained': transactionType == 'maintenance'
                ? DateTime.now().toUtc().toIso8601String()
                : null,
          })
          .eq('id', toolId);

      // 2. Log Transaction
      await _client.from('inventory_transactions').insert({
        'tool_id': toolId,
        'user_id': userId,
        'transaction_type': transactionType,
        'notes': notes,
      });

      AppLogger.info(
        LogCategory.inventory,
        'Tool $toolId status updated to $newStatus',
      );
    } catch (e, st) {
      AppLogger.error(
        LogCategory.inventory,
        'logToolStatus failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Fetch transaction history for an item.
  Future<List<InventoryTransactionModel>> getTransactionHistory({
    String? toolId,
    String? itemId,
  }) async {
    try {
      var query = _client
          .from('inventory_transactions')
          .select('*, users(full_name)');
      if (toolId != null) query = query.eq('tool_id', toolId);
      if (itemId != null) query = query.eq('inventory_item_id', itemId);

      final data = await query.order('created_at', ascending: false).limit(20);
      return (data as List)
          .map((row) => InventoryTransactionModel.fromJson(row))
          .toList();
    } catch (e, st) {
      AppLogger.error(
        LogCategory.inventory,
        'getTransactionHistory failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }
}
