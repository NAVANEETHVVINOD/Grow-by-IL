# Grow Authorization Model

Status: Proposal. No database policy, migration, or Flutter authorization code is changed by this document.

## Principle

Authorization is a capability decision, not a widget visibility decision and not a direct comparison to a position name.

Authenticated user + account type + active position assignment + assignment lab scope + approved permission policy = allowed capability.

The Flutter client may use the result to guide navigation, but the repository and database must enforce the same decision for every protected operation.

## Compatibility Boundary

Current code uses AppRole values student, lab_admin, and super_admin. The approved target account types are student, faculty, and super_admin. No code may silently reinterpret an existing lab_admin row as a new position. The transition is a future approved migration and compatibility release.

## Capability Vocabulary

This is an initial vocabulary for review. A module PRD must define exact actions, states, and scope before its capabilities are implemented.

| Capability | Candidate actors | Scope | Required enforcement |
| --- | --- | --- | --- |
| profile.read_self, profile.update_self | Authenticated account | Own account | RLS ownership policy. |
| position.assign, position.revoke | Super Admin | Platform | Database policy or server interface plus audit. |
| organization.manage | Super Admin | Platform | Database policy or server interface plus audit. |
| lab.manage | Super Admin | Platform | Database policy or server interface plus audit. |
| machine_request.review | Active Machine Head | Assigned lab | Approved Manufacturing Task policy. |
| machine.assign, machine.execution.update | Active Machine Head | Assigned lab | Approved Machine and Task policy. |
| machine.maintenance.manage | Active Machine Head | Assigned lab | Approved Machines policy. |
| inventory.manage, equipment_request.review | Active Operation Head | Assigned lab | Approved Inventory policy. |
| borrowing.manage | Active Operation Head | Assigned lab | Approved Borrowing policy. |
| quotation.manage, billing.manage, payment.manage | Active Operation Head | Assigned lab | Approved payment and quotation policy. |
| work_request.create | To be defined by Work Request contract | To be defined | Do not infer from this proposal. |
| event.manage, media.manage, documentation.manage | To be defined by their module requirements | To be defined | No implementation from position titles alone. |

## Separate Operational Request Paths

Machine Work Requests and Component/Equipment Requests are distinct workflows.
The authorization system must not model them as one record requiring a Machine
Head and Operation Head to negotiate ownership.

| Workflow | Review authority | Future module gate |
| --- | --- | --- |
| Machine Work Request | Active Machine Head for the assigned lab | Manufacturing/Machines requirements and schema approval. |
| Component/Equipment Request | Active Operation Head for the assigned lab | Inventory/Borrowing/Payments requirements and schema approval. |

Shared UI patterns or notifications do not imply shared domain ownership.

## Enforcement Layers

1. Flutter presentation hides irrelevant routes and actions for usability only.
2. The application and repository layer requests capabilities and handles denial safely; it does not become the authority source.
3. The database and RLS layer enforces user, position, lab, and operation scope.
4. Auditing records Super Admin assignments/revocations and all elevated operational actions.

No sensitive operation may rely solely on a Flutter role comparison.

## Permission Resolution Requirements

- Resolve permissions from a server-authoritative active assignment.
- Scope every operational permission to the assignment lab.
- Do not cache an authorization decision past session refresh or a relevant permission-change event without revalidation.
- Return a safe permission-denied result rather than an ambiguous empty state.
- Do not expose an unaudited administrative mutation through a direct table update from the UI.

## Admin Organization Screen Concept

These are conceptual surfaces for a later approved Admin module, not Figma screens or implementation scope.

| Surface | Primary job | Guard |
| --- | --- | --- |
| Organization overview | Show current active positions by lab and year | Super Admin. |
| Positions | Maintain position master data, not individual app roles | Super Admin with audit. |
| Assignments | Assign, end, revoke, and inspect historical assignments | Super Admin with audit. |
| Labs | Maintain lab master data and active scope | Super Admin with audit. |
| Permission policy | Review approved position-to-capability policy | Super Admin; editing policy needs a separate governance decision. |
| Audit log | Inspect elevated organization actions | Super Admin, read-only. |

## Required Tests When Implemented

- Super Admin can assign and revoke an eligible assignment.
- A user cannot hold two active assignments at once.
- Multiple users can hold the same position.
- An active Machine Head is restricted to the assigned lab.
- An active Operation Head cannot perform machine-approval actions.
- Position revocation removes capability after authorization refresh.
- Direct database writes by unauthorized accounts are rejected by RLS.
- UI denied states do not imply that database enforcement was bypassed.

## Deferred Decisions

- Detailed permissions for Tech, Documentation, Event, Media, Web, Design, Patent and Paper Presentation, and coordinator positions.
- Whether faculty positions gain operational capability beyond oversight.
- Trainee assignments and any capacity guidance.
- Public visibility of the current team roster.
