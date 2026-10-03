# Test Inventory

This document lists all automated unit, widget, and integration tests in the Grow~ codebase, with their categories and execution durations.

---

## 1. Summary Matrix

| Category | Count | Status | Description |
| :--- | :---: | :---: | :--- |
| **Unit Tests** | 85 | Pass | Verifies business logic, models serialization, and repository layers in isolation. |
| **Widget Tests** | 2 | Pass | Verifies UI components and screen layouts in the Flutter widget tree. |
| **Integration Tests** | 18 | Pass | Validates end-to-end user flows, offline synchronization, and chaos recovery on device. |
| **Grand Total** | **105** | **Pass** | **All tests running and passing green.** |

---

## 2. Test Inventory Table

| Test File | Category | Test Case Name | Duration (ms) | Status |
| :--- | :--- | :--- | :---: | :---: |
| `app_defaults_test.dart` | Unit Test | AppDefaults buildNewUserRow contains all required DB columns | 5391 | ✅ Pass |
| `app_defaults_test.dart` | Unit Test | AppDefaults buildNewUserRow excludes optional fields when null | 5409 | ✅ Pass |
| `app_defaults_test.dart` | Unit Test | AppDefaults buildNewUserRow includes optional fields when provided | 5404 | ✅ Pass |
| `app_defaults_test.dart` | Unit Test | AppDefaults buildNewUserRow uses defaultUserName for empty name | 5398 | ✅ Pass |
| `app_defaults_test.dart` | Unit Test | AppDefaults default values match DB schema defaults | 5385 | ✅ Pass |
| `app_qr_test.dart` | Unit Test | AppQr generateToolQr creates correct format | 5770 | ✅ Pass |
| `app_qr_test.dart` | Unit Test | AppQr generateUserQr creates correct format | 5763 | ✅ Pass |
| `app_qr_test.dart` | Unit Test | AppQr isToolQr returns true for valid tool QR | 5785 | ✅ Pass |
| `app_qr_test.dart` | Unit Test | AppQr isUserQr returns true for valid user QR | 5777 | ✅ Pass |
| `app_qr_test.dart` | Unit Test | AppQr parseToolId extracts tool ID correctly | 5815 | ✅ Pass |
| `app_qr_test.dart` | Unit Test | AppQr parseToolId returns null for empty ID | 5829 | ✅ Pass |
| `app_qr_test.dart` | Unit Test | AppQr parseToolId returns null for invalid format | 5822 | ✅ Pass |
| `app_qr_test.dart` | Unit Test | AppQr parseUserId extracts user ID correctly | 5792 | ✅ Pass |
| `app_qr_test.dart` | Unit Test | AppQr parseUserId returns null for empty ID | 5808 | ✅ Pass |
| `app_qr_test.dart` | Unit Test | AppQr parseUserId returns null for invalid format | 5800 | ✅ Pass |
| `app_qr_test.dart` | Unit Test | AppQr round-trip: generate then parse returns original ID | 5836 | ✅ Pass |
| `app_roles_test.dart` | Unit Test | AppRole enum adminRoles contains only lab_admin and super_admin | 6985 | ✅ Pass |
| `app_roles_test.dart` | Unit Test | AppRole enum displayName returns human-readable label | 6970 | ✅ Pass |
| `app_roles_test.dart` | Unit Test | AppRole enum fromString defaults to student for unknown roles | 6953 | ✅ Pass |
| `app_roles_test.dart` | Unit Test | AppRole enum fromString parses all valid DB roles | 6945 | ✅ Pass |
| `app_roles_test.dart` | Unit Test | AppRole enum isAdminRole returns true only for admin roles | 6991 | ✅ Pass |
| `app_roles_test.dart` | Unit Test | AppRole enum isSuperAdminRole returns true only for super_admin | 6999 | ✅ Pass |
| `app_roles_test.dart` | Unit Test | AppRole enum selfAssignableRoles does not contain admin roles | 7004 | ✅ Pass |
| `app_roles_test.dart` | Unit Test | AppRole enum value returns correct DB string | 6962 | ✅ Pass |
| `auth_flow_test.dart` | Unit Test | AuthFlow Unit & Integration Tests Sign-in failure throws error properly | 8380 | ✅ Pass |
| `auth_flow_test.dart` | Unit Test | AuthFlow Unit & Integration Tests Sign-in flow executes successfully | 8332 | ✅ Pass |
| `auth_flow_test.dart` | Unit Test | AuthFlow Unit & Integration Tests Sign-up flow creates auth user and public database entry | 8401 | ✅ Pass |
| `booking_flow_test.dart` | Unit Test | BookingFlow Unit & Integration Tests Booking fails due to overlapping slot | 9406 | ✅ Pass |
| `booking_flow_test.dart` | Unit Test | BookingFlow Unit & Integration Tests Successful booking creation | 9369 | ✅ Pass |
| `booking_model_test.dart` | Unit Test | BookingModel Serialization Tests copyWith copies fields correctly | 10095 | ✅ Pass |
| `booking_model_test.dart` | Unit Test | BookingModel Serialization Tests fromJson parses complete json correctly | 10030 | ✅ Pass |
| `booking_model_test.dart` | Unit Test | BookingModel Serialization Tests fromJson parses minimal json using defaults | 10039 | ✅ Pass |
| `booking_model_test.dart` | Unit Test | BookingModel Serialization Tests isOverdue returns false for non-active bookings | 10073 | ✅ Pass |
| `booking_model_test.dart` | Unit Test | BookingModel Serialization Tests isOverdue returns true for expired active bookings | 10066 | ✅ Pass |
| `booking_model_test.dart` | Unit Test | BookingModel Serialization Tests toJson serializes correctly | 10055 | ✅ Pass |
| `event_model_test.dart` | Unit Test | EventModel Serialization Tests copyWith copies fields correctly | 10821 | ✅ Pass |
| `event_model_test.dart` | Unit Test | EventModel Serialization Tests fromJson parses complete json correctly | 10777 | ✅ Pass |
| `event_model_test.dart` | Unit Test | EventModel Serialization Tests fromJson uses defaults for missing fields | 10783 | ✅ Pass |
| `event_model_test.dart` | Unit Test | EventModel Serialization Tests isCancelled returns true for cancelled events | 10811 | ✅ Pass |
| `event_model_test.dart` | Unit Test | EventModel Serialization Tests isFull returns false when no capacity limit | 10804 | ✅ Pass |
| `event_model_test.dart` | Unit Test | EventModel Serialization Tests isFull returns true when capacity reached | 10798 | ✅ Pass |
| `event_model_test.dart` | Unit Test | EventModel Serialization Tests toJson serializes correctly | 10792 | ✅ Pass |
| `notification_model_test.dart` | Unit Test | NotificationModel Serialization Tests copyWith preserves all fields except changed ones | 11246 | ✅ Pass |
| `notification_model_test.dart` | Unit Test | NotificationModel Serialization Tests fromJson defaults isRead to false when missing | 11236 | ✅ Pass |
| `notification_model_test.dart` | Unit Test | NotificationModel Serialization Tests fromJson parses complete json correctly | 11231 | ✅ Pass |
| `notification_model_test.dart` | Unit Test | NotificationModel Serialization Tests toJson serializes correctly | 11242 | ✅ Pass |
| `profile_security_and_migration_test.dart` | Unit Test | Ecosystem Repository Replay Tests Replay suspends sync when auth is expired / null session, keeping queue intact | 12743 | ✅ Pass |
| `profile_security_and_migration_test.dart` | Unit Test | Ecosystem Repository Replay Tests Stale write detection discards stale updates when remote is newer | 12781 | ✅ Pass |
| `profile_security_and_migration_test.dart` | Unit Test | Ecosystem Repository Replay Tests Successful replay of delete_by_name and delete_by_platform removes them from queue | 12814 | ✅ Pass |
| `profile_security_and_migration_test.dart` | Unit Test | Offline Queue Tests (PendingProfileMutationQueue) Deduplication collapses rapid writes on the same rowId | 12628 | ✅ Pass |
| `profile_security_and_migration_test.dart` | Unit Test | Offline Queue Tests (PendingProfileMutationQueue) Exponential backoff delay calculation | 12636 | ✅ Pass |
| `profile_security_and_migration_test.dart` | Unit Test | Offline Queue Tests (PendingProfileMutationQueue) Partial queue replay preservation and failure increment | 12659 | ✅ Pass |
| `profile_security_and_migration_test.dart` | Unit Test | Offline Queue Tests (PendingProfileMutationQueue) Retry cap marks permanently failed after 5 retries | 12669 | ✅ Pass |
| `profile_security_and_migration_test.dart` | Unit Test | Offline Queue Tests (PendingProfileMutationQueue) Stale write detection field propagation | 12645 | ✅ Pass |
| `profile_security_and_migration_test.dart` | Unit Test | ProfileMigrationCoordinator Mutex Tests Ensures mutual exclusion and duplicate start prevention | 12595 | ✅ Pass |
| `profile_security_and_migration_test.dart` | Unit Test | ProfileMigrationStorage Tests Checkpoint management | 12474 | ✅ Pass |
| `profile_security_and_migration_test.dart` | Unit Test | ProfileMigrationStorage Tests Default states and storage updates | 12456 | ✅ Pass |
| `profile_security_and_migration_test.dart` | Unit Test | ProfileMigrationStorage Tests Local cache data persistence | 12484 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Chaos Harness — Connectivity Flapping FakeConnectivityFlapper emits correct number of flaps | 15324 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Chaos Harness — Migration Timeout FakeMigrationTimeout acquires lock with timeout | 15462 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Chaos Harness — Migration Timeout FakeMigrationTimeout resets correctly | 15466 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Chaos Harness — Queue Corruption FakeQueueCorruptor generates valid corrupted payloads | 15355 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Chaos Harness — Replay Interruption FakeReplayInterruption resets correctly | 15343 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Chaos Harness — Replay Interruption FakeReplayInterruption throws after index | 15339 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Chaos Harness — Session Expiry FakeExpiredSession expires after threshold | 15327 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Chaos Harness — Session Expiry FakeExpiredSession resets correctly | 15331 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Profile Sync Queue — Failure Paths Clear queue removes all mutations | 13313 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Profile Sync Queue — Failure Paths Exponential backoff delay calculation | 13293 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Profile Sync Queue — Failure Paths Mutation marked permanently failed after 5 retries | 13267 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Profile Sync Queue — Failure Paths Replay paused flag prevents queue processing | 13282 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Profile Sync Queue — Failure Paths Retry count increments on failure report | 13243 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Profile Sync Queue — Happy Path Adding a mutation persists to queue | 13194 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Profile Sync Queue — Happy Path Deduplication collapses same (table, rowId) | 13206 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Profile Sync Queue — Happy Path Different rowIds create separate entries | 13215 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Profile Sync Queue — Happy Path Queue starts empty | 13143 | ✅ Pass |
| `profile_sync_queue_test.dart` | Unit Test | Profile Sync Queue — Happy Path Remove mutation clears from queue | 13228 | ✅ Pass |
| `smoke_test.dart` | Unit Test | Smoke test: 1 + 1 = 2 | 13342 | ✅ Pass |
| `tool_model_test.dart` | Unit Test | ToolModel Serialization Tests copyWith copies fields correctly | 14138 | ✅ Pass |
| `tool_model_test.dart` | Unit Test | ToolModel Serialization Tests fromJson parses complete json correctly | 14112 | ✅ Pass |
| `tool_model_test.dart` | Unit Test | ToolModel Serialization Tests fromJson parses minimal json using defaults | 14120 | ✅ Pass |
| `tool_model_test.dart` | Unit Test | ToolModel Serialization Tests toJson serializes correctly | 14129 | ✅ Pass |
| `user_model_test.dart` | Unit Test | UserModel Serialization Tests copyWith copies fields correctly | 14594 | ✅ Pass |
| `user_model_test.dart` | Unit Test | UserModel Serialization Tests fromJson parses complete json correctly | 14581 | ✅ Pass |
| `user_model_test.dart` | Unit Test | UserModel Serialization Tests fromJson parses minimal json using defaults | 14585 | ✅ Pass |
| `user_model_test.dart` | Unit Test | UserModel Serialization Tests toJson serializes correctly | 14590 | ✅ Pass |
| `widget_test.dart` | Widget Test | Grow~ Models Tests ProjectModel.fromJson parses successfully with default status | 15414 | ✅ Pass |
| `widget_test.dart` | Widget Test | Grow~ Models Tests UserModel.fromJson parses successfully | 15410 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Chaos Harness — Connectivity Flapping FakeConnectivityFlapper emits correct number of flaps | 152993 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Chaos Harness — Migration Timeout FakeMigrationTimeout acquires lock with timeout | 153446 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Chaos Harness — Migration Timeout FakeMigrationTimeout resets correctly | 153498 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Chaos Harness — Queue Corruption FakeQueueCorruptor generates valid corrupted payloads | 153290 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Chaos Harness — Replay Interruption FakeReplayInterruption resets correctly | 153234 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Chaos Harness — Replay Interruption FakeReplayInterruption throws after index | 153184 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Chaos Harness — Session Expiry FakeExpiredSession expires after threshold | 153062 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Chaos Harness — Session Expiry FakeExpiredSession resets correctly | 153123 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Profile Sync Queue — Failure Paths Clear queue removes all mutations | 150908 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Profile Sync Queue — Failure Paths Exponential backoff delay calculation | 150700 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Profile Sync Queue — Failure Paths Mutation marked permanently failed after 5 retries | 150576 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Profile Sync Queue — Failure Paths Replay paused flag prevents queue processing | 150641 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Profile Sync Queue — Failure Paths Retry count increments on failure report | 150487 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Profile Sync Queue — Happy Path Adding a mutation persists to queue | 150109 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Profile Sync Queue — Happy Path Deduplication collapses same (table, rowId) | 150182 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Profile Sync Queue — Happy Path Different rowIds create separate entries | 150281 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Profile Sync Queue — Happy Path Queue starts empty | 149885 | ✅ Pass |
| `widget_tester.dart` | Widget Test | Profile Sync Queue — Happy Path Remove mutation clears from queue | 150413 | ✅ Pass |
