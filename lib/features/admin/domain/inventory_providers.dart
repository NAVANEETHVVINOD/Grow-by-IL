import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/repositories/supabase_client.dart';
import '../../../shared/models/inventory_item_model.dart';
import '../../../shared/models/inventory_transaction_model.dart';
import '../data/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(supabase);
});

final inventoryItemsProvider = FutureProvider.family<List<InventoryItemModel>, String?>((ref, category) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getInventoryItems(category: category);
});

final lowStockItemsProvider = FutureProvider<List<InventoryItemModel>>((ref) async {
  final items = await ref.watch(inventoryItemsProvider(null).future);
  return items.where((i) => i.isLowStock).toList();
});

final itemTransactionsProvider = FutureProvider.family<List<InventoryTransactionModel>, String>((ref, itemId) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getTransactionHistory(itemId: itemId);
});

final toolTransactionsProvider = FutureProvider.family<List<InventoryTransactionModel>, String>((ref, toolId) async {
  final repo = ref.watch(inventoryRepositoryProvider);
  return repo.getTransactionHistory(toolId: toolId);
});
