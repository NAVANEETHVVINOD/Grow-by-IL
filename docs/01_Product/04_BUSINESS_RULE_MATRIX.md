# Grow Platform Business Rule Matrix

Status: Draft - Phase 1A Amendment  
Owner: Product Owner / Lead Architect  
Last updated: 2026-08-02

## Purpose

This matrix consolidates approved business rules into stable identifiers that
future PRD, SRS, workflows, UI screens, database design, tests, and audit logic
can reference.

## Rule Priority

- Mandatory: required for MVP/V1 correctness.
- Recommended: should be included when practical.
- Future: useful later, not a V1 blocker.

## Work Request Rules

| Rule ID | Priority | Rule |
| --- | --- | --- |
| BRULE-001 | Mandatory | A Work Request has exactly one student leader. |
| BRULE-002 | Mandatory | A Work Request can have multiple members/collaborators. |
| BRULE-003 | Mandatory | A Work Request must preserve status history. |
| BRULE-004 | Mandatory | Work Request default review outcome should be Needs Changes, not Rejected, when the request can be corrected. |
| BRULE-005 | Mandatory | Permanent rejection is reserved for safety violations, prohibited work, policy violations, or duplicate requests. |
| BRULE-006 | Mandatory | Rejected Work Requests must include a reason. |
| BRULE-007 | Mandatory | Student leader may resubmit a Work Request after Needs Changes. |
| BRULE-008 | Mandatory | If core team materially edits a Work Request, the student leader must approve the edited request before execution. |
| BRULE-009 | Recommended | Work Requests should support priority levels: Low, Normal, High, Urgent. |
| BRULE-010 | Recommended | Work Requests should support preferred completion, required-before, and optional event-date fields. |
| BRULE-011 | Mandatory | Large design or source files should normally be represented as external links, not mandatory Supabase uploads. |
| BRULE-012 | Mandatory | Work Request categories are master data. |

## Work Request Lifecycle Rules

> **Reconciled 2026-09-01** (was: "Reconciliation needed"): rewritten below to
> match `docs/01_Product/06_WORK_REQUEST_IMPLEMENTATION_CONTRACT.md` (Status:
> Approved) and the shipped `WorkRequestStatus` enum
> (`lib/features/work_requests/models/work_request_summary.dart`), landed in
> PR #63 (`fix/work-request-lifecycle-alignment`). Canonical states:
> `draft, submitted, reviewed, changesRequested, approved, inProgress,
> readyForPickup, completed, rejected, cancelled`.
>
> Two things dropped from the old wording, on purpose:
> - **"Task Planning"** is not a Work Request state in the approved contract
>   or the enum — it belongs to the future Manufacturing Task / Machine Queue
>   domain, same reasoning as why `queued` was removed from this enum (see
>   PR #61 history). Not modeled here.
> - **"Archived"** is not a terminal state in the enum either; the only
>   terminal states are `completed`, `rejected`, and `cancelled`.
>
> **Still open, not yet decided by a human:** whether `changesRequested`
> loops back to `reviewed` (core-team re-check) or `submitted` (full
> re-triage). Documented as a proposal in the PR #63 body, not enforced in
> code — nothing enforces transitions yet, it's all local/mock. Whoever
> answers this should update both this row and the PR body.

| Rule ID | Priority | Rule |
| --- | --- | --- |
| BRULE-020 | Mandatory | Default lifecycle is `draft` -> `submitted` -> `reviewed` -> `changesRequested` -> (loops back to `reviewed` or `submitted` — open question above) -> `approved` -> `inProgress` -> `readyForPickup` -> `completed`. |
| BRULE-021 | Mandatory | Permanent rejection lifecycle is `submitted` -> `reviewed` -> `rejected`. (`cancelled` is a separate terminal state reachable from most non-terminal states, per BRULE-023.) |
| BRULE-022 | Mandatory | A Work Request cannot enter In Progress until required review and payment gates are satisfied. |
| BRULE-023 | Mandatory | Cancelled or permanently rejected Work Requests must cascade unfinished Manufacturing Tasks into Cancelled while preserving task history. |

## Manufacturing Task Rules

| Rule ID | Priority | Rule |
| --- | --- | --- |
| BRULE-030 | Mandatory | A Work Request may have one or more Manufacturing Tasks. |
| BRULE-031 | Mandatory | Each Manufacturing Task belongs to exactly one Work Request. |
| BRULE-032 | Mandatory | Each Manufacturing Task must have a type, status, and responsible owner/role. |
| BRULE-033 | Recommended | Manufacturing Tasks should support estimated duration. |
| BRULE-034 | Recommended | Manufacturing Tasks should support dependencies between tasks. |
| BRULE-035 | Mandatory | Manufacturing Task history must be preserved when status changes. |

## Machine And Queue Rules

| Rule ID | Priority | Rule |
| --- | --- | --- |
| BRULE-040 | Mandatory | Students do not directly operate fabrication machines by default. |
| BRULE-041 | Mandatory | Machine Head owns queue decisions. |
| BRULE-042 | Mandatory | Machines are associated with a lab. |
| BRULE-043 | Recommended | Machine queues should show priority, due date, estimated duration, task type, and status. |
| BRULE-044 | Recommended | Multiple jobs may run in parallel when Machine Head decides it is operationally safe. |

## Machine Runtime And Maintenance Rules

| Rule ID | Priority | Rule |
| --- | --- | --- |
| BRULE-050 | Mandatory | Machine usage must be manually recordable. |
| BRULE-051 | Recommended | Runtime record should capture start, stop, hours, operator, material used, and remarks. |
| BRULE-052 | Mandatory | Machines must support availability and maintenance states. |
| BRULE-053 | Recommended | Runtime and usage records should support costing and maintenance reports. |

## Inventory, Asset, And Borrowing Rules

| Rule ID | Priority | Rule |
| --- | --- | --- |
| BRULE-060 | Mandatory | Consumables, borrowable items, and assets are separate concepts. |
| BRULE-061 | Mandatory | Inventory changes must create history/movement records. |
| BRULE-062 | Mandatory | Inventory import must support CSV or Excel. |
| BRULE-063 | Mandatory | Inventory records should include lab and physical location such as shelf, rack, or drawer. |
| BRULE-064 | Mandatory | Borrowing statuses include Reserved, Issued, Returned, Overdue, Lost, and Damaged. |
| BRULE-065 | Mandatory | Overdue borrowing can block future borrowing until cleared. |
| BRULE-066 | Recommended | Operation Head should be notified about overdue borrowing. |
| BRULE-067 | Mandatory | Asset lifecycle statuses include Available, In Use, Maintenance, Broken, and Disposed. |
| BRULE-068 | Mandatory | Inventory movement types include Purchase, Import, Adjustment, Consumption, Borrowed, Returned, Damaged, Lost, Transfer, and Correction. |

## Visitor Rules

| Rule ID | Priority | Rule |
| --- | --- | --- |
| BRULE-080 | Mandatory | Visitor check-in must record lab, reason, check-in time, and checkout time. |
| BRULE-081 | Mandatory | Visitor reasons are master data. |
| BRULE-082 | Recommended | Visitor reason should support event, workshop, component borrowing, tool borrowing, return item, maintenance, documentation, photography, meeting, and personal project. |

## Event And Workshop Rules

| Rule ID | Priority | Rule |
| --- | --- | --- |
| BRULE-090 | Mandatory | Events Head/admin can create and publish events/workshops. |
| BRULE-091 | Mandatory | Events/workshops can support registration and attendance. |
| BRULE-092 | Recommended | Some events/workshops may support certificate eligibility. |

## Payment And Quotation Rules

| Rule ID | Priority | Rule |
| --- | --- | --- |
| BRULE-100 | Mandatory | V1 uses UPI/manual payment verification, not a payment gateway. |
| BRULE-101 | Recommended | Default payment model supports 50 percent before completion and 50 percent after completion where required. |
| BRULE-102 | Mandatory | Payment records must include verification status and verifier. |
| BRULE-103 | Mandatory | Payment history must be auditable. |

## Notification, Report, And Audit Rules

| Rule ID | Priority | Rule |
| --- | --- | --- |
| BRULE-110 | Mandatory | Important operational status changes must notify affected users. |
| BRULE-111 | Recommended | Push notifications are future work after in-app notification flows are stable. |
| BRULE-120 | Mandatory | Operational reports must be exportable. |
| BRULE-121 | Recommended | Reports should be grouped into Daily, Weekly, Monthly, Revenue, Machine Usage, Inventory Value, Borrowing, Visitors, Events, Machine Runtime, and Payments. |
| BRULE-130 | Mandatory | Critical operational actions must create audit history. |
| BRULE-131 | Mandatory | Audit logs should include actor, action, target entity, timestamp, and metadata. |

## Master Data Sets

### Work Request Categories

- Fabrication
- Laser Cutting
- 3D Printing
- PCB Milling
- CNC Routing
- Electronics Assembly
- Mechanical Assembly
- Design Assistance
- Technical Consultation
- Project Guidance
- Inventory Purchase Request
- Maintenance Request
- General Inquiry

### Visitor Reasons

- Project Discussion
- Machine Work
- Machine Pickup
- Workshop
- Event
- Component Borrowing
- Tool Borrowing
- Return Item
- Faculty Visit
- Meeting
- Maintenance
- Personal Project
- Documentation
- Photography
- Other

### Machine Types

- Laser Cutter
- 3D Printer
- PCB Milling
- CNC Router
- Electronics Station
- Soldering Station
- Testing Equipment
- Computer Workstation
- Other

### Inventory Categories

- Electronic Components
- Mechanical Components
- Raw Materials
- Filaments
- PCB Materials
- Hardware
- Tools
- Borrowable Equipment
- Consumables
- Safety Equipment
- Stationery
- Miscellaneous

### Priority Levels

- Low
- Normal
- High
- Urgent

### Borrowing Statuses

- Reserved
- Issued
- Returned
- Overdue
- Lost
- Damaged

### Asset Statuses

- Available
- In Use
- Maintenance
- Broken
- Disposed

## Dependencies

- Product Charter v1.0.
- Business Glossary.
- Business Requirements Document.

## Risks

- Rule volume will grow; duplicate rules must be avoided.
- Future PRD/SRS must reference rule IDs instead of rewriting rule language.

## Open Questions

1. Which rules are MVP blockers versus V1 blockers after core team review?
2. Which Work Request categories should be enabled first?
3. Which reports are required for the first internal release?

## Future Enhancements

- Add traceability from every PRD/SRS requirement to rule IDs.
- Add automated test references to rule IDs.
- Add Supabase policy references to rule IDs.

## Approval Checklist

- [ ] Work Request lifecycle approved
- [ ] Business rules reviewed
- [ ] Master data sets reviewed
- [ ] Priorities accepted
- [ ] Approved to proceed to Phase 1B PRD/SRS
