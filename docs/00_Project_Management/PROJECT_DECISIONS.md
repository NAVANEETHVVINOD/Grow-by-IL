# Grow Platform Decision Log

Last updated: 2026-07-29

## Decision Format

Each decision should include:

- ID
- Title
- Status
- Date
- Context
- Decision
- Rationale
- Impact
- Related ADR

## Decisions

### DEC-0001 - Treat Grow as an Innovation Hub Management Platform

Status: Approved  
Date: 2026-07-29  
Related ADR: `ARCHITECTURAL_DECISION_RECORDS/ADR-0001-platform-scope.md`

Context: Grow began as a lab/project/community app but requirements now include
Fab Lab, IDEA Lab, manufacturing, inventory, visitors, payments, reports, and
audit logs.

Decision: Grow will be architected as an Innovation Hub Management Platform, not
only a mobile lab utility.

Rationale: The broader architecture avoids repeated rewrites as operational
modules are added.

Impact: Product docs, schema design, module architecture, and roadmap must treat
operations as first-class.

### DEC-0002 - Use Work Requests Instead Of Orders

Status: Approved  
Date: 2026-07-29  
Related ADR: `ARCHITECTURAL_DECISION_RECORDS/ADR-0002-work-requests.md`

Decision: User-submitted manufacturing/service needs are called Work Requests.

Rationale: Students are asking the lab/core team to help build something, not
buying a simple product.

Impact: Future schema and UI should use work request terminology.

### DEC-0003 - Support Collaborators On Work Requests

Status: Approved  
Date: 2026-07-29  
Related ADR: TBD

Decision: Each Work Request supports a leader/owner and multiple members from
V1. Optional faculty guide support may be added later.

Rationale: Engineering college projects are commonly team-based.

Impact: Database design requires a Work Request member table.

### DEC-0004 - Split Work Requests Into Manufacturing Tasks

Status: Approved  
Date: 2026-07-29  
Related ADR: `ARCHITECTURAL_DECISION_RECORDS/ADR-0003-manufacturing-tasks.md`

Decision: A Work Request may produce one or more Manufacturing Tasks.

Rationale: One request may require laser cutting, 3D printing, PCB milling,
design help, assembly, and testing.

Impact: Machine queues, task assignment, costing, progress, and reporting should
operate at task level where appropriate.

### DEC-0005 - Separate Consumables, Borrowables, And Assets

Status: Approved  
Date: 2026-07-29  
Related ADR: `ARCHITECTURAL_DECISION_RECORDS/ADR-0004-assets-inventory-separation.md`

Decision: Inventory architecture separates consumables, borrowable items, and
fixed assets.

Rationale: Quantity-managed stock, returnable items, and fixed equipment have
different lifecycles and audit needs.

Impact: Future database and UI must avoid mixing components/filament with
machines/laptops/projectors.

### DEC-0006 - Use Manual UPI Payment Verification In V1

Status: Approved  
Date: 2026-07-29  
Related ADR: TBD

Decision: V1 payment flow uses quotation, UPI payment by user, transaction ID or
optional screenshot, and Operation Head verification.

Rationale: Avoid payment gateway complexity while preserving operational
records.

Impact: Payment records need status, verification actor, receipt/reference, and
audit log.

### DEC-0007 - Use Configurable Master Data

Status: Approved  
Date: 2026-07-29  
Related ADR: TBD

Decision: Operational values such as labs, departments, machine types, visitor
purposes, payment methods, categories, and allowed domains should be master data
instead of hardcoded values.

Rationale: Labs and policy details will evolve.

Impact: Database and admin design must include configurable reference data.

### DEC-0008 - External Customers Are Website-First, Not App-First

Status: Approved  
Date: 2026-07-29  
Related ADR: TBD

Decision: External customer ordering is deferred to a separate website or portal
that may share the backend later.

Rationale: The mobile app should stay focused on MEC users and core team
operations first.

Impact: V1 app scope excludes external public customer registration.
