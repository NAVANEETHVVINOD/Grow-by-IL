# Grow Platform System Blueprint

Status: Draft for Phase 2 planning
Owner: Platform Architecture
Last updated: 2026-08-07

## 1. Platform Overview

Grow is a multi-surface community platform for IDEA Lab operations, student identity, events, volunteering, projects, tooling, and maker workflows. The app is currently structured as a Flutter client connected to Supabase-backed services, with Riverpod for state management and GoRouter for navigation.

## 2. Architectural Layers

### 2.1 Presentation Layer
- Flutter screens and widgets under lib/features/*/presentation
- Shared UI primitives under lib/shared/widgets/rc5
- Theme and design tokens under lib/core/theme

### 2.2 Application Layer
- Controllers and providers under lib/features/*/application
- Feature-flag controlled navigation and rollout strategy

### 2.3 Domain Layer
- Feature-specific models, repository interfaces, and business rules
- Cross-feature orchestration remains lightweight and explicit

### 2.4 Data Layer
- Supabase as primary backend and persistence layer
- Repository abstractions hide schema-specific details from the UI
- Local caching and offline queueing are treated as supporting infrastructure rather than core domain logic

## 3. Module Interaction Model

- Auth and onboarding establish identity and profile completion state
- Home aggregates contextual dashboards from labs, events, projects, and notifications
- Akathalam acts as the operational hub for live lab state and bookings
- Profile is the maker identity layer, with public/private data boundaries
- Work requests and future modules plug into shared repository and permissions patterns

## 4. Feature Lifecycle

1. Feature flag is introduced
2. Provider and repository scaffold are created
3. Screen and widget layer is built
4. Supabase schema and RLS are planned
5. Tests and rollout validation follow

## 5. Folder and Coding Standards

- Features use a consistent structure: data, domain, application, presentation
- Shared primitives stay under lib/shared and avoid feature-specific coupling
- DTOs and repository contracts remain explicit and typed
- Prefer Riverpod providers over direct service calls inside widgets

## 6. Provider Architecture

- top-level app providers for router and auth state
- feature providers for repositories and controllers
- screen-level providers for UI state and loading indicators
- avoid provider proliferation; keep one source of truth per feature

## 7. State Management

- Use AsyncNotifier or FutureProvider for async data sources
- Prefer scoped providers for screen-local state
- Keep mutation logic in controllers or repositories, not directly inside widgets

## 8. Routing Strategy

- Central router configuration in lib/core/router/app_router.dart
- Public routes remain minimal and explicit
- Feature flags control gradual rollout of new screens
- Profile setup and onboarding remain part of auth redirection flow

## 9. Feature Flags

- enableAkathalam: rollout of operational lab shell
- enableNewProfile: new profile experience
- enableWorkRequests: work request and queue workflows
- kEnableProfileMigration and kEnableDebugSyncDashboard remain controlled toggles for transition safety

## 10. Database Roadmap

- Phase 1: stabilize existing profile and lab-focused tables
- Phase 2: introduce work request, inventory, borrowing, machine queue, and payment domains
- Phase 3: add stronger indexing, RLS policies, and repository abstractions

## 11. Release Roadmap

- RC5 stabilization and polish
- Phase 2 API and repository foundation
- Phase 3 multi-module expansion and operational workflows
