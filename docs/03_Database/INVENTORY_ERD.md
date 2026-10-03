# Inventory ERD Planning

Status: Draft
Last updated: 2026-08-07

## 1. Entities

### inventory_items
- id (uuid, pk)
- name
- category
- sku
- quantity_on_hand
- unit_of_measure
- location
- status
- created_at
- updated_at

### inventory_movements
- id (uuid, pk)
- item_id (uuid, fk -> inventory_items.id)
- movement_type
- quantity
- actor_id (uuid, fk -> users.id)
- note
- created_at

### inventory_reservations
- id (uuid, pk)
- item_id (uuid, fk -> inventory_items.id)
- reserved_by (uuid, fk -> users.id)
- reserved_until
- status

## 2. Relationships

- inventory_items 1:N inventory_movements
- inventory_items 1:N inventory_reservations

## 3. Suggested Indexes

- idx_inventory_items_category_status
- idx_inventory_movements_item_id
- idx_inventory_reservations_item_id_status

## 4. RLS Planning

- Members can view shared inventory catalog
- Reservation owners can manage their own reservations
- Admins can update stock and movement records

## 5. Repository Interface

```text
interface InventoryRepository {
  Future<List<InventoryItem>> list();
  Future<InventoryItem> create(CreateInventoryItemInput input);
  Future<InventoryItem> update(String id, UpdateInventoryItemInput input);
  Future<void> reserve(String id, String userId, DateTime until);
}
```
