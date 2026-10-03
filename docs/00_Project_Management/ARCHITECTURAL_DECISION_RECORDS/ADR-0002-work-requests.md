# ADR-0002 - Use Work Requests Instead Of Orders

Date: 2026-07-29

Status: Approved

## Context

Students are not simply buying products. They ask the lab/core team to help
design, fabricate, assemble, or produce project-related output.

## Decision

Use the term Work Request for student/core-team fabrication and service
requests.

## Rationale

Work Request better represents collaboration, review, editing, quotation,
manufacturing tasks, payments, and pickup.

## Alternatives Considered

- Order
- Job
- Service Request

## Consequences

Benefits:

- More accurate language for a college innovation hub.
- Supports multiple tasks and collaborators.
- Avoids ecommerce-style assumptions.

Risks:

- Existing code and docs may still contain booking/order terminology until
  refactored in later implementation phases.

## Related Documents

- `../PROJECT_DECISIONS.md`
