# ADR-0003 - Work Requests Create Manufacturing Tasks

Date: 2026-07-29

Status: Approved

## Context

One student request may involve multiple activities: laser cutting, 3D printing,
PCB milling, CNC routing, assembly, design support, or testing.

## Decision

Model manufacturing execution as tasks under a Work Request.

## Rationale

Tasks let Machine Heads assign work to different machines or core members,
track progress independently, and calculate cost/runtime more accurately.

## Alternatives Considered

- Assign a Work Request directly to one machine.
- Create separate Work Requests for each machine operation.

## Consequences

Benefits:

- Better queue management.
- Better reporting.
- Supports multi-machine workflows.

Risks:

- Slightly more database and UI complexity than a single request table.

## Related Documents

- `../PROJECT_DECISIONS.md`
