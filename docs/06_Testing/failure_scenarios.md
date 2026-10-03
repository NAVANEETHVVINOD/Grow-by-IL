# Failure Scenarios & Recovery Procedures

This document lists the simulated recovery scenarios and tests validating sync engine resilience.

## CURRENT IMPLEMENTATION STATUS
* **Failure Simulation Tests**: `Status: production validated` - Covered by 12 comprehensive unit tests in `test/profile_security_and_migration_test.dart`.

---

## 1. Scenario 1: Authentication Expiry During Replay
- **Description**: The mutation queue contains multiple items. During replay, the user's auth session expires (or becomes null).
- **Behavior**: The sync scheduler halts replay immediately upon detecting `client.auth.currentSession == null`. It preserves all remaining mutations in SharedPreferences, preventing data loss or API unauthorized rejections.
- **Recovery**: Replay resumes automatically on the next launch or reconnect when a valid session becomes active.

---

## 2. Scenario 2: Duplicate App Launch / Provider Conflict
- **Description**: The app initializes twice rapidly, prompting concurrent migration triggers.
- **Behavior**: `ProfileMigrationCoordinator` wraps the migration function in a global static mutex. The second invocation awaits the active completer rather than triggering a duplicate migration run.
- **Recovery**: Prevents database constraint conflicts (`unique_user_profile` violations) and recursive provider loops.

---

## 3. Scenario 3: Interrupted Migration Checkpoint Auto-Resume
- **Description**: The migration process is interrupted (e.g. process terminated by OS or crash) after migrating `profile` but before migrating `skills`.
- **Behavior**: The coordinator saves progress checkpoints (`{'profile': true, 'skills': false}`).
- **Recovery**: On resume, it skips the `profile` checkpoint and begins directly with `skills`, achieving transaction idempotency.
