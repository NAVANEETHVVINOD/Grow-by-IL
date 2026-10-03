# Storage Architecture & Drift/SQLite Roadmap

This document outlines the current SharedPreferences storage layout and defines the roadmap for migrating the local cache/queue layer to Drift (SQLite).

## CURRENT IMPLEMENTATION STATUS
* **Onboarding & Mutation Cache**: `Status: partially implemented` - Persisted in `SharedPreferences` as key-value JSON string list arrays.
* **SQLite/Drift Roadmap**: `Status: planned for Phase B` - Slated to replace SharedPreferences to avoid JSON parsing overhead.

---

## 1. Current Storage Constraints (SharedPreferences)

Currently, `SharedPreferences` is used for:
- Local onboarding drafts (pre-migration)
- The offline mutation queue (`PendingProfileMutationQueue`)
- Profile header caching (`ProfileMigrationStorage`)

### Risk Factors
1. **JSON Parser Bloat**: Large serialized lists read/written synchronously on the main thread can cause UI frame drops.
2. **No Relational Constraints**: No foreign keys or types are enforced at the local disk level, risking structural corruption.
3. **Memory Overheads**: SharedPreferences loads all keys into memory at once.

---

## 2. Drift/SQLite Roadmap (Phase B)

In Phase B, we will replace the SharedPreferences cache and queue layer with a relational SQLite database managed by Drift:

### 2.1 Proposed Tables in SQLite
```dart
@DataClassName('LocalMutation')
class LocalMutations extends Table {
  TextColumn get id => text()();
  TextColumn get tableName => text()();
  TextColumn get rowId => text()();
  TextColumn get payloadJson => text()();
  TextColumn get mutationType => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastKnownServerUpdatedAt => dateTime().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  BoolColumn get failedPermanently => boolean().withDefault(const Constant(false))();
}
```

### 2.2 Advantages of Drift
- **Type Safety**: Full compile-time query verification.
- **Relational Integrity**: Enforce local foreign keys and unique constraints.
- **Performance**: Asynchronous disk writes on a background isolate, avoiding UI thread jank.
- **SQL Queries**: Enable robust queries for conflict resolution and deduplication.
