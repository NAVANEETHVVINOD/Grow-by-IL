# Module Dependency Graph

Status: Draft for Phase 2 planning
Last updated: 2026-08-07

## 1. Core Dependency Layers

```text
Auth
  -> Profile
  -> Router / Shell
  -> Home / Akathalam / Notifications

Profile
  -> Projects
  -> Events
  -> Work Requests

Work Requests
  -> Inventory
  -> Machine Queue
  -> Notifications

Inventory
  -> Borrowing
  -> Payments

Machine Queue
  -> Lab Operations
  -> Notifications
```

## 2. Dependency Notes

- Auth is the root dependency for access control and onboarding state
- Profile data supplies identity and public visibility for later modules
- Work requests are the bridge between maker needs and operational workflows
- Inventory and machine queue introduce the first shared operational domain dependencies

## 3. Recommended Dependency Rules

- Feature modules should depend on shared services and repositories, not on sibling screens
- Cross-feature composition should occur through application services or controllers
- Avoid circular dependencies by keeping domain contracts stable and narrow
