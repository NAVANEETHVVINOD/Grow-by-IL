# Profile Migration & Sync Test Matrix

This matrix defines the expected system behavior and state transition validations across different environment, authentication, network, and queue states for the Grow~ profile synchronization architecture.

---

## 1. State Transition Matrix

| Case ID | Online | Local Draft | Server Data | Queue State | Expected Result | Verification Procedure |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-01** | Yes | Yes (New) | No | Empty | Migrate local draft to Supabase. State -> `migrated`. | 1. Initialize fresh local draft.<br>2. Run migration. Verify data exists in Supabase. Check state in storage is `migrated`. |
| **TC-02** | Yes | Yes (New) | Yes | Empty | Safe merge (Scalar: server wins; Array: union; Ordered: newer wins). State -> `migrated`. | 1. Initialize local draft and pre-populate conflicting server data.<br>2. Run migration. Verify merged schema in Supabase. Check state in storage is `migrated`. |
| **TC-03** | No | Yes (New) | No | Empty | Local fallback. Keep local draft. Cache loaded. State -> `localOnly`. | 1. Enable flight mode (mock SocketException).<br>2. Load profile. Verify local draft is shown. State remains `localOnly`. |
| **TC-04** | No | Yes (Edited) | Yes | Queued | Optimistic cache update. Changes written to cache and mutation queue. State -> `migrated` (from cache perspective). | 1. Offline edit profile. Verify Toast message/banner displays queue status.<br>2. Verify local cache is updated and queue contains mutation. |
| **TC-05** | Yes | Interrupted | Partial | Queued | Resume checkpoint. Only upload missing tables, drain queue. State -> `migrated`. | 1. Mock partial migration crash (e.g. checkpoint profile=true, skills=false).<br>2. Restart app with internet. Verify migration picks up from checkpoints. |
| **TC-06** | Yes | Duplicate Edits | Existing | Queued | Queue deduplication. Rapid edits collapse to 1 mutation on the same row. State -> `migrated`. | 1. Offline, save edits to the same subpage 3 times rapidly.<br>2. Verify mutation queue list count is exactly 1. Check replay drains the single collapsed mutation. |
| **TC-07** | Auth Expired | Yes | Yes | Queued | Suspend sync. Prevent API writes. Save to offline queue. Prompt login. | 1. Simulate expired session / null auth token.<br>2. Save edits. Verify write fails gracefully, queued offline, and user is redirected to `/login` or prompted. |
| **TC-08** | Yes | Conflict | Newer | Queued | `updated_at` reconciliation. Server newer timestamp wins; local discarded. State -> `migrated`. | 1. Push a newer update to Supabase manually.<br>2. Trigger sync of an older queued mutation. Verify database ignores/rejects or merges older data correctly. |

---

## 2. Core Correctness Constraints (Hard Rules)

1. **Idempotent Upserts:** All writes to database tables must use Supabase `upsert` with explicit `onConflict` clauses (`user_id` for profiles, `user_id,name` for skills, `user_id,platform` for social links) to prevent primary key/unique constraint failures.
2. **Server-Generated Timestamps:** Do NOT pass device timestamps to database fields; let Postgres set `updated_at = now()` via trigger.
3. **Queue Collapse:** Mutations targeting the exact same record (e.g., updating a bio multiple times) must collapse on `(table, rowId)` in the queue.
4. **Mutex Coordinator:** The `ProfileMigrationCoordinator` must block concurrent migration execution, returning the active future to late arrivals.
