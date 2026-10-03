# Offline Synchronization, Deduplication, & Backoff Architecture

This document describes the synchronization mechanics used to support offline-first profile edits in the Grow~ mobile client.

## CURRENT IMPLEMENTATION STATUS
* **Offline Queue**: `Status: production validated` - Queues mutations to SharedPreferences and handles serialization/deserialization.
* **Deduplication Engine**: `Status: production validated` - Collapses multiple edits on the same row key.
* **Backoff Strategy**: `Status: production validated` - Implements exponential backoff capped at 60s.
* **Stale Write Detection**: `Status: production validated` - Discards stale mutations using `lastKnownServerUpdatedAt`.

---

## 1. The Offline Mutation Queue

When the device is offline, any write operation in `ProfileEcosystemRepository` throws an `OfflineQueueException` after appending the change to `PendingProfileMutationQueue`.

### Serialized Payload Structure
Mutations are stored in SharedPreferences as JSON strings:
```json
{
  "id": "mutation-uuid",
  "table": "user_skills",
  "rowId": "skill_user123_Dart",
  "payload": {"user_id": "user123", "name": "Dart", "level": 3},
  "type": "upsert",
  "createdAt": "2026-05-26T22:49:13.000Z",
  "lastKnownServerUpdatedAt": "2026-05-26T22:40:00.000Z",
  "retryCount": 0,
  "failedPermanently": false
}
```

---

## 2. Deduplication Engine

To prevent queue bloating and redundant write operations:
- When a new mutation is added, the queue checks if a mutation on the same `table` and `rowId` already exists.
- If it exists, the new mutation overwrites the older mutation's payload, maintaining order while collapsing updates.

---

## 3. Exponential Backoff & Retry Logic

When network connectivity resumes, the replay scheduler triggers:
1. Replays are run sequentially to maintain transaction order.
2. If a network error occurs, replay is aborted to preserve order.
3. The retry delay scales exponentially:
   - Attempt 1: 2s
   - Attempt 2: 4s
   - Attempt 3: 8s
   - Attempt 4: 16s
   - Attempt 5: 32s
   - Attempt 6+: 60s (Capped)
4. If a mutation fails 5 times with non-network errors, it is marked `failedPermanently` to prevent blockages.

---

## 4. Conflict Resolution (Stale Write Detection)

Before replaying any mutation:
- The engine fetches the remote `updated_at` timestamp for that row.
- If `serverUpdatedAt` is newer than the mutation's `lastKnownServerUpdatedAt`, it means remote changes occurred after the local edit started.
- The local write is discarded, logging a warning to prevent silent remote overwrite corruption.
- Otherwise, the write proceeds and overwrites the remote value safely.
