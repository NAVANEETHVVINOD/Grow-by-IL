# Grow Platform Technical Debt Register

Status: Approved  
Owner: Lead Architect  
Version: 1.0  
Last updated: 2026-08-04  
Depends on: `docs/00_Project_Management/FEATURE_INVENTORY.md`  

---

## 1. Executive Summary

This register tracks all deferred refactorings, architectural improvements, schema cleanup items, performance optimizations, and test gaps. No item is forgotten or left unassigned.

---

## 2. Technical Debt Master Log

| ID | Module | Category | Description | Priority | Effort | Target Milestone | Blocked By | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **TD-001** | Work Requests | Refactoring | Split 1,272-line `create_work_request_screen.dart` into modular step-widget files | P2 (High) | Small (2h) | Post-PR #56 (`chore/`) | PR #56 Merge | Open |
| **TD-002** | Work Requests | Accessibility | Add `Semantics(selected: ...)` wrappers to `_SelectableTile` & `_DateTile` | P3 (Medium) | Small (1h) | Post-PR #56 (`chore/`) | PR #56 Merge | Open |
| **TD-003** | Work Requests | Performance | Optimize Riverpod screen rebuilds with `ref.watch(provider.select(...))` | P3 (Medium) | Small (1h) | Post-PR #56 (`chore/`) | PR #56 Merge | Open |
| **TD-004** | Work Requests | Testing | Add golden tests for wizard steps and verification screens | P3 (Medium) | Medium (3h) | Post-PR #56 (`chore/`) | PR #56 Merge | Open |
| **TD-005** | Work Requests | Testing | Test wizard text scaling under 2x+ accessibility font scale factors | P4 (Low) | Small (1h) | Post-PR #56 (`chore/`) | None | Open |
| **TD-006** | Work Requests | Accessibility | Audit keyboard focus order across wizard steps on physical device | P4 (Low) | Small (1h) | Post-PR #56 (`chore/`) | Physical Device QA | Open |
| **TD-007** | Profile | Schema Drift | Resolve `interests` usage in profile Dart code vs DB schema baseline | P2 (High) | Medium (2h) | Schema Cleanup Slice | None | Open |
| **TD-008** | Profile | Schema Drift | Resolve `full_name` usage in auth/profile Dart code vs DB schema baseline | P2 (High) | Medium (2h) | Schema Cleanup Slice | None | Open |
| **TD-009** | Work Requests | Code Quality | Rename validator methods to `validateTitle()` / `validatePurpose()` pattern | P4 (Low) | Small (1h) | Future Refactor | None | Open |
| **TD-010** | Work Requests | Validation | Enhance URL validator with `uri.hasScheme` & `uri.hasAuthority` checks | P4 (Low) | Small (30m) | Future Refactor | None | Open |
| **TD-011** | Home | Performance | Complete section-level isolation on older Home screen to prevent rebuild storms | P3 (Medium) | Medium (4h) | RC5 Theme Sprint | None | Open |
| **TD-012** | Admin | Testing | Increase test coverage for Admin maintenance UI (currently ~40%) | P3 (Medium) | Medium (4h) | Testing Sprint | None | Open |
