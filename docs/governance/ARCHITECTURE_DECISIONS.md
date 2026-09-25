# Grow~ Architecture Decisions

This file is the tracked repo-level index of important architecture decisions.
Detailed local ADRs may exist under ignored architecture docs, but accepted
decisions that affect contributors must be visible here.

## ADR-001: Use Work Request Instead Of Order

Status: Accepted

Reason: Lab work is collaborative, review-based, and may split into multiple
Manufacturing Tasks. "Order" implies a transactional external-commerce model,
which is not the V1 mobile app model.

Consequence: UI, requirements, and future schema should use Work Request.

## ADR-002: Students Request, Core Team Executes

Status: Accepted

Reason: Students should not directly operate fabrication machines by default.
Core team and Machine Heads own execution.

Consequence: Student screens show request status and coarse queue information;
Machine Head screens own operational queue controls.

## ADR-003: Separate Work Requests And Manufacturing Tasks

Status: Accepted

Reason: One student request may require laser cutting, 3D printing, PCB milling,
assembly, or testing. These must be independently assignable and trackable.

Consequence: Future schema and UI must not collapse all work into one flat
request row.

## ADR-004: Separate Consumables, Borrowables, And Assets

Status: Accepted

Reason: Stock, borrowable items, and fixed assets have different lifecycles,
reporting needs, and audit requirements.

Consequence: Inventory architecture must preserve these distinctions.

## ADR-005: Manual UPI Verification For V1

Status: Accepted

Reason: Payment gateway integration is unnecessary for V1 and adds operational
and compliance complexity.

Consequence: V1 payment records should support manual verification and audit
history.

## ADR-006: External Customer Flow Is Outside Mobile App V1

Status: Accepted

Reason: External ordering has different identity, payment, support, and public
UX requirements.

Consequence: External customers may be handled by a future website/portal.

## ADR-007: Phase-Gated Architecture Before Persistence

Status: Accepted

Reason: Work Requests, inventory, payments, and roles are complex enough that
schema-first guessing will cause rework.

Consequence: No Supabase schema, migration, repository, or persistence logic for
new operational modules before PRD/SRS and architecture approval.
