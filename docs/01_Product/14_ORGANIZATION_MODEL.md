# Grow Organization Model

Status: Product input captured. This is an implementation contract proposal, not authorization code or a database migration.

## Purpose

Grow must represent changing IDEA Lab leadership without app releases or hardcoded personal data. The organization model separates an account's broad type from a time-bound operational position.

## Locked Decisions

### Account Types

The intended account types are super_admin, student, and faculty.

lab_admin is present in the current Flutter code and database-facing model, but is not part of the intended future model. It remains a compatibility concern until an approved migration and authorization transition removes or maps it safely.

### Core Team

Core Team is not an account type, flag, or separate authorization truth. A person is a Core Team member when they hold an active position assignment for a lab.

User -> account type -> active position assignment -> lab -> capabilities

The current team is selected each year. Historical assignments remain attributable after a new team is selected.

### Position Rules

- A person may have at most one active position across the entire platform.
- Multiple people may hold the same position.
- Positions are scoped to a lab.
- A Super Admin is the only actor allowed to assign or revoke a position.
- Position assignments retain history through dates and status rather than overwriting a person's account row.
- The current number of people in a position is informational, not a schema limit. Future positions and trainee arrangements must be configurable.

## Current IDEA Lab Position Catalogue

This is current institutional input. It is candidate master data after the organization schema is approved; it must never be hardcoded in Flutter or treated as a permanent capacity rule.

| Position | Current occupancy | Account type expectation | Responsibility boundary |
| --- | ---: | --- | --- |
| Student Ambassador | 1 | Student | Coordinates the Heads and student team work. |
| Operation Head | 3 | Student | Components, equipment requests, inventory, billing, and payments. |
| Machine Head | 2 | Student | Machine request approval, assignment, execution, and maintenance work. |
| Tech Head | 2 | Student | Technical team work; detailed capabilities pending module requirements. |
| Documentation Head | 2 | Student | Documentation team work; detailed capabilities pending requirements. |
| Event Head | 3 | Student | Event team work; detailed capabilities pending event requirements. |
| Media Head | 1 | Student | Media team work; detailed capabilities pending requirements. |
| Web Head | 1 | Student | Web team work; detailed capabilities pending requirements. |
| Design Head | 2 | Student | Design team work; detailed capabilities pending requirements. |
| Patent and Paper Presentation Head | 2 | Student | Patent and paper presentation work; detailed capabilities pending requirements. |
| Relation and Documentation Coordinator | 1 | Student | Coordination responsibilities; detailed capabilities pending requirements. |
| Operation Coordinator | 1 | Student | Operations coordination; detailed capabilities pending requirements. |
| Staff In-Charge | 1 | Faculty | Faculty oversight. |
| IDEA Lab Faculty Coordinator | 1 | Faculty | Faculty coordination and oversight. |

There is no separate Head of IDEA Lab position in the current model. App and position administration belongs to Super Admin. Faculty oversight belongs to the two faculty positions above.

## Assignment Contract

Each historical and active assignment requires user_id, position_id, lab_id, assigned_by, effective_from, effective_until, status, created_at, and updated_at.

The future database constraint must prevent more than one active assignment for the same person, platform-wide. It must not prevent several people from being assigned to the same position.

## Operational Boundaries

| Actor | Owns | Does not gain automatically |
| --- | --- | --- |
| Super Admin | Position assignment/revocation, organization master data, application administration | Unbounded business-policy changes without audit. |
| Machine Head | Machine-related request review, assignment, execution, and maintenance work within the assigned lab | Billing, payment, global administration, unrelated lab authority. |
| Operation Head | Components/equipment requests, inventory, borrowing, billing, quotations, and payment operations within the assigned lab | Machine approval, global administration, unrelated lab authority. |
| Student Ambassador | Coordination of student Heads | Global administration or module authority not explicitly granted later. |
| Faculty positions | Institutional oversight responsibilities | Super Admin capabilities unless separately assigned. |

The capability list is intentionally incomplete for positions whose module requirements are not approved. A position title is not a substitute for a permission contract.

## Request Segmentation

Machine work and component/equipment work are separate request paths. They are
not one request object with two approval owners.

| Request path | Operational owner | Scope |
| --- | --- | --- |
| Machine Work Request | Active Machine Head | Machine approval, assignment, execution, and maintenance-related work. |
| Component/Equipment Request | Active Operation Head | Component/equipment handling, inventory, billing, quotation, and payment work. |

The two paths may later share approved infrastructure such as a status-timeline
pattern or notifications, but their PRDs, lifecycle rules, permissions, and
persistence contracts must remain distinct.

## Annual Team Lifecycle

Select team -> Super Admin records assignments -> assignments become active -> operations use active assignments -> year ends or team changes -> assignments are ended/revoked -> history is retained.

Replacing a position holder creates a new assignment and ends the prior active assignment. It does not rewrite the old assignment, change an account type, or hardcode a name in the app.

## Explicit Non-Goals

- No new Flutter role enum values for Heads or coordinators.
- No current-person roster in source code.
- No position capacity hardcoding.
- No database migration, seed data, RLS policy, or admin screen implementation in this document.
- No assumption that the public IDEA Lab website is an authorization source.

## Approval Required Before Implementation

The schema proposal and authorization model must be reviewed together before any migration, RLS change, admin UI, or role-code refactor begins.
