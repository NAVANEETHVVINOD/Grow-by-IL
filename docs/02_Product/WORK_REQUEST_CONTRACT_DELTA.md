# Work Request Contract Delta

Status: decision record for review. This document does not authorize a schema,
database migration, pricing rule, stock import, payment integration or role
assignment.

## Purpose

Work Request is the request-intake workflow for help that the IDEA Lab can
review. It is not a Manufacturing Task, a Machine Queue entry, an inventory
reservation, or a payment record. Those are separate workflows and must not
be collapsed into one client-controlled status field.

The current Flutter provider constructs `MockWorkRequestDataSource`, so the
dashboard records and counts are simulated. Issue #85 tracks their removal.
They must not be presented as a member's live requests, lab workload, queue
position, payment state, assigned head, or estimated completion date.

## Decisions already supplied

| Area | Agreed direction |
| --- | --- |
| Entry point | Expose one primary **Start a Work Request** action; do not duplicate it with a second New Request action. |
| Routing | Machine-related work is routed to Machine responsibility; operation-related work is routed to Operations responsibility. The assignment is workflow data, not a client-writable account role. |
| Scope | Work Request, Manufacturing Task, and Machine Queue remain separate modules. |
| Data honesty | Use loading, empty, unavailable and permission-denied states until the backend can return a real record. |
| Stock and price | Do not seed quantities or prices. The product owner will supply the updated stock and official price rules later. |
| Storage | Request attachments cannot be enabled until the storage access contract is approved and implemented. |

## Current local-client surface to reconcile

The local model contains a useful UI draft, but it is not a backend contract.
The following fields need an approved source of truth before they can be
persisted or shown as live operational data:

| Local field or concept | Why it is not launch-ready | Required decision/evidence |
| --- | --- | --- |
| Fabrication subcategories | The current labels include machine claims not yet approved against the lab catalog. | Canonical service/machine catalog with stable identifiers and operational owner. |
| `labPreference` | IDEA Lab/Fab Lab selection assumes a room model that is not reconciled. | One-lab/two-room policy and permitted request destinations. |
| Priority | A requester-selected value is not an approval decision. | Who can set/override priority, allowed values, reason/audit requirement. |
| `leaderName` and assignment | A display name is neither authority nor proof of responsibility. | Scoped position assignments and read policy; no client-selected head. |
| Estimated completion and coarse queue position | Both can mislead users if generated from mock data. | Manufacturing Task/Machine Queue handoff contract and safe disclosure rules. |
| Payment state | The app explicitly labels it a placeholder. | Quote/deposit/payment/refund ownership, verified-payment source, and no-seat/no-work reservation rule. |
| Material procurement | It does not prove availability or purchase authorization. | Inventory/procurement workflow, stock provenance, and approver authority. |
| Collaborators | Plain names are not authenticated member references. | Member-selection/privacy policy and project relationship rule. |
| External links and attachments | Links/files can expose data and require validation. | Allowed domains/file types, retention, malware scanning and storage RLS. |
| Cancellation/rejection | Reasons need an auditable actor and transition rules. | Who may cancel, reject, resubmit or reopen, and whether a reason is mandatory. |

## Minimal lifecycle to approve

The local status enum may be used only as a UI draft until the following
transition matrix is approved and enforced on the server:

```text
Draft (private) -> Submitted -> Under Review
Under Review -> Changes Requested | Approved | Rejected
Approved -> Manufacturing Task handoff (separate record) | Cancelled
Changes Requested -> Submitted | Cancelled
Rejected -> resubmit only when the reviewer explicitly marks it resubmittable
```

`In Progress`, `Ready for Pickup`, machine assignment, queue position, and
payment labels belong to the downstream workflow unless a reviewed contract
defines the exact synchronized source. A submitted request must never become
approved, paid, assigned, or completed from a client-only update.

## Required implementation gates

1. Resolve #93 and #95 product/eligibility conflicts and approve the decisions
   in the table above. The owner must supply the actual catalog, stock and
   official price policy when those flows are in scope.
2. Close the authorization foundation gate: current roles remain compatibility
   labels, and position assignments need their own reviewed scope/RLS matrix.
3. Approve an API/schema contract with immutable request history, server-side
   transition authorization, audit events, RLS negative tests and rollback
   plan. Do not derive permission from a client-provided role, position or
   assignee.
4. Implement a real repository/data source in a focused PR. Remove simulated
   dashboard rows, counts and detail records; preserve an honest unavailable
   state until the real service is enabled.
5. Test request creation, view permissions, routing, every allowed/denied
   transition, concurrent update handling, error/offline states, and Android
   E2E with a non-production data set.

## Questions requiring owner approval

1. Which exact request categories are V1: machine, fabrication, component,
   design help, technical support, or another set? Machine and component
   requests should remain visibly distinct if both are approved.
2. Can a student cancel a submitted request? If yes, until which state and
   must a reason be supplied? Who may cancel after approval?
3. What is the first real routing rule when a request spans both machine and
   operations responsibility, or when the relevant head is absent?
4. When, if ever, may a requester see an estimated date, a queue summary or
   a named responsible person?
5. Which requests can incur cost, who creates the quote, and which verified
   payment/refund provider and audit record are authoritative?

## Next smallest safe task

Have the owner approve the five questions and the current catalog boundary.
Then create a reviewed Work Request API/schema proposal with authorization
tests. Until then, do not turn the mock provider into a production backend.
