# Architecture Principles

Status: Draft for Phase 2 planning
Last updated: 2026-08-07

## 1. Principles

- Prefer explicit, typed contracts over hidden coupling
- Keep the UI thin and push business rules into application/domain services
- Use feature flags to reduce rollout risk
- Separate read models from write models when workflows become complex
- Make repositories the boundary between Flutter and Supabase
- Preserve accessibility, performance, and resilience as first-class concerns

## 2. Implementation Guidelines

- Use Riverpod providers for dependency injection and state sharing
- Keep route definitions centralized and role-aware
- Use consistent folder structure for every new feature
- Document migrations and breaking changes before shipping
