# Grow Feature Module Structural Template

Status: Approved  
Owner: Lead Architect  
Version: 1.0  
Last updated: 2026-08-04  
Depends on: `docs/02_Architecture/REPOSITORY_ARCHITECTURE.md`  

---

## 1. Overview

This document specifies the exact directory layout, placeholder templates, and structural rules required when scaffolding a new feature module in `lib/features/<module_name>/`.

---

## 2. Directory Tree Template

```text
lib/features/<module_name>/
├── application/
│   └── providers/
│       ├── <module_name>_controller.dart
│       └── <module_name>_state.dart
├── constants/
│   └── <module_name>_options.dart
├── models/
│   └── <module_name>_draft.dart
├── presentation/
│   ├── screens/
│   │   ├── <module_name>_screen.dart
│   │   └── <module_name>_create_screen.dart
│   └── widgets/
│       ├── <module_name>_header.dart
│       ├── <module_name>_bottom_actions.dart
│       └── <module_name>_step_tile.dart
├── services/
│   └── draft_storage/
│       └── <module_name>_draft_storage.dart
└── utils/
    └── <module_name>_validators.dart
```

---

## 3. Required File Responsibilities

| Sub-path | Layer Role | Strict Constraints |
| --- | --- | --- |
| `application/providers/` | Riverpod StateNotifiers / Notifiers | State must be immutable (`copyWith`). Provider must use `autoDispose` unless application-scoped. |
| `constants/` | UI and Master Data constants | Pure static data only. No state. |
| `models/` | Data Transfer Objects / Pure State | Json-serializable (`fromJson`, `toJson`), immutable state DTOs. No business logic. |
| `presentation/screens/` | Top-level scaffold screens | Registered in `app_router.dart`. Must be guarded by `FeatureFlags`. |
| `presentation/widgets/` | Component sub-widgets | Small, focused widgets under 200 lines each. Prefer section-level `ConsumerWidget`s. |
| `services/draft_storage/` | Local persistence | `SharedPreferences` only during Phase 1. No Supabase/network imports. |
| `utils/` | Validation & string formatting | Pure stateless static functions. 100% unit-tested. |

---

## 4. Phase 2 Gated Layers (DO NOT SCAFFOLD IN PHASE 1)

The following directories MUST NOT be created during Phase 1:

```text
lib/features/<module_name>/
├── data/                      # FORBIDDEN IN PHASE 1 (Blocked by CI Guard)
│   ├── datasources/
│   ├── mappers/
│   └── repositories/
└── domain/                    # FORBIDDEN IN PHASE 1 (Blocked by CI Guard)
    ├── entities/
    ├── usecases/
    └── repository_interfaces/
```

Attempting to add `data/` or `domain/` before Phase 2 database architecture approval will cause CI build failures via `.github/ci/architecture_guard_paths.txt`.
