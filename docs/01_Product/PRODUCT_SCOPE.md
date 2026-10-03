# Grow~ Product Scope: User Outcomes And Non-Goals

Status: Draft (Pending Review)
Owner: Product Owner / Lead Architect
Version: 1.0
Last updated: 2026-09-01
Depends on: `docs/01_Product/00_PRODUCT_CHARTER.md`, `docs/01_Product/02_PRODUCT_VISION.md`, `/SYSTEM_BOUNDARIES.md`
Referenced by: `docs/00_Project_Management/MASTER_INDEX.md`

> **Authoritative Version Pointer**: This doc restates the Charter's scope
> section (`docs/01_Product/00_PRODUCT_CHARTER.md` Section 6) and
> `/SYSTEM_BOUNDARIES.md` as user-outcome language for people who need "what
> can a user actually do" rather than the full charter. Where this disagrees
> with the Charter or System Boundaries, those two win.

## 1. Who Grow Is For

Students, Core Team members (Machine Head, Operation Head, Student
Ambassador, Events/Tech/Design/Media/Documentation Heads), Faculty, and (V1,
read-mostly) Alumni at the Model Engineering College Innovation Hub (IDEA Lab
+ Fab Lab).

## 2. User Outcomes (what V1 must let people actually do)

- A student can sign up with their college identity and reach a role-aware
  dashboard without manual account setup.
- A student can submit a Work Request (with collaborators, reason, links to
  external design files) and track its status from submission to pickup.
- A Machine Head can review a Work Request, request changes, and see it
  reflected back once the student leader re-approves edited terms.
- A student or core team member can borrow/return a tracked item and see
  overdue status.
- An Operation Head can inspect inventory, borrowing, and visitor records and
  export a report.
- Anyone can see events/workshops and RSVP; core team can track attendance.
- A quotation and manual UPI payment can be recorded and verified, with an
  audit trail, without a payment gateway integration.
- Every critical action (status change, payment verification, role change,
  inventory movement, visitor check-in/out) leaves an audit record.

## 3. Explicit Non-Goals For V1

Taken directly from `/SYSTEM_BOUNDARIES.md` "Outside Grow For V1" and
`docs/01_Product/00_PRODUCT_CHARTER.md` Section 6 "Out Of Scope For V1" —
listed here so a reader doesn't have to cross-reference two docs to know
what NOT to build:

- CAD editing or design-tool hosting inside the app.
- Large fabrication file storage as the primary source of truth (external
  links to Drive/GitHub/Dropbox/OneDrive remain the source of truth).
- Direct messaging/chat (no WhatsApp replacement).
- External customer ordering inside the mobile app (deferred to a future
  website/portal — external customers are explicitly out of mobile V1,
  `ARCHITECTURE_DECISIONS.md` ADR-006).
- Full online payment gateway integration (manual UPI verification only,
  `ARCHITECTURE_DECISIONS.md` ADR-005).
- AI cost estimation or AI design validation.
- IoT machine telemetry.
- Multi-institution UI or public marketplace.
- Automatic machine/material consumption without human review.

## 4. Deferred, Not Cancelled

Manufacturing Tasks and Machine Queue are in the Charter's architecture
scope and already have ADRs (ADR-002, ADR-003) and ERDs
(`docs/03_Database/MACHINE_QUEUE_ERD.md`), but have no shipped implementation
yet as of this writing (2026-09-01) — the only shipped feature module beyond
the RC5 foundation is Work Requests (PRs #56, #61, #62, #63, #64). Don't
treat "in scope for architecture" as "already built."

## 5. Open Questions (unresolved, carried from the Charter)

See `docs/01_Product/00_PRODUCT_CHARTER.md` Section "Open Questions" — most
relevant to scope: the rejected Work Request lifecycle variant (permanent
rejection vs. resubmission vs. conversion) is still not fully settled at the
business-rule level; see the reconciliation note in
`docs/01_Product/04_BUSINESS_RULE_MATRIX.md` BRULE-020/021.
