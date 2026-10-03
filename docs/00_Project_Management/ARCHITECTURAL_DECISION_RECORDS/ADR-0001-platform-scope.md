# ADR-0001 - Grow Is An Innovation Hub Management Platform

Date: 2026-07-29

Status: Approved

## Context

Grow began as a Flutter + Supabase app for lab booking, projects, events,
notifications, and student workflows. Discovery expanded the product scope to
Fab Lab + IDEA Lab operations, manufacturing, inventory, borrowing, visitors,
payments, reports, and audit logs.

## Decision

Architect Grow as an Innovation Hub Management Platform, not only a lab utility
or community app.

## Rationale

The platform must support operational workflows and accountability. Treating it
as a simple app would create repeated schema and UI rewrites.

## Alternatives Considered

- Keep Grow as a student/community mobile app and build operations separately.
- Build only a manufacturing/order module.

## Consequences

Benefits:

- Clear long-term module boundaries.
- Better database planning.
- Stronger fit for Fab Lab + IDEA Lab operations.

Risks:

- Scope can become too large without phase gates.
- MVP must be carefully controlled.

## Related Documents

- `../PROJECT_DECISIONS.md`
- `../../01_Product/00_PRODUCT_CHARTER.md`
