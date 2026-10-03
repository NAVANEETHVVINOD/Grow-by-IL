# Machine Queue ERD Planning

Status: Draft
Last updated: 2026-08-07

## 1. Entities

### machine_queue_entries
- id (uuid, pk)
- machine_id (uuid, fk -> inventory_items.id)
- user_id (uuid, fk -> users.id)
- queue_status
- requested_at
- started_at
- completed_at
- notes

### machine_queue_events
- id (uuid, pk)
- queue_entry_id (uuid, fk -> machine_queue_entries.id)
- event_type
- payload
- created_at

## 2. Relationships

- inventory_items 1:N machine_queue_entries
- machine_queue_entries 1:N machine_queue_events
- users 1:N machine_queue_entries

## 3. Suggested Indexes

- idx_machine_queue_entries_status_machine_id
- idx_machine_queue_entries_user_id

## 4. RLS Planning

- Users can view and manage their own queue entries
- Operators and admins can manage shared queue state
- Queue events remain append-only for auditability

## 5. Repository Interface

```text
interface MachineQueueRepository {
  Future<List<MachineQueueEntry>> listActive();
  Future<MachineQueueEntry> enqueue(EnqueueInput input);
  Future<MachineQueueEntry> advance(String id, QueueTransitionInput input);
}
```
