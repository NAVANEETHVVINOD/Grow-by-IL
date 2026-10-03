# Grow Platform Business Glossary

Status: Draft - Phase 1A  
Owner: Product Owner / Lead Architect  
Last updated: 2026-08-02

## Purpose

This glossary is the canonical terminology reference for Grow. All future BRD,
PRD, SRS, architecture, schema, UX, and implementation documents should use
these terms consistently.

## Canonical Module List

| Module ID | Module |
| --- | --- |
| MOD-01 | Authentication |
| MOD-02 | User Profiles |
| MOD-03 | Alumni |
| MOD-04 | Work Requests |
| MOD-05 | Manufacturing Tasks |
| MOD-06 | Machine Queue |
| MOD-07 | Machines |
| MOD-08 | Maintenance |
| MOD-09 | Assets |
| MOD-10 | Inventory |
| MOD-11 | Borrowing |
| MOD-12 | Visitors |
| MOD-13 | Events |
| MOD-14 | Workshops |
| MOD-15 | Payments |
| MOD-16 | Quotations |
| MOD-17 | Notifications |
| MOD-18 | Reports |
| MOD-19 | Audit Logs |
| MOD-20 | Administration |
| MOD-21 | Master Data |
| MOD-22 | Knowledge Base |

## Core Terms

### Institution

The parent organization operating the platform. For V1 this is Model Engineering
College. The architecture should not prevent future institutions, but the V1 UI
is institution-focused.

### Lab

A physical innovation workspace. Initial labs are IDEA Lab and Fab Lab. Machines,
assets, inventory, visitors, and work can be associated with a lab.

### User

Any authenticated person in Grow, including students, faculty, alumni, trainees,
core team members, and admins.

### Student

A standard platform user who can submit Work Requests, attend events, borrow
items, visit labs, and build a profile.

### Core Team

The operational student team that runs lab work, machines, events, inventory,
documentation, media, design, and technical support.

### Student Ambassador

The highest student leadership position in the core team. This role may receive
overview dashboards and escalation visibility.

### Machine Head

A core team position responsible for reviewing machine-related Work Requests,
assigning Manufacturing Tasks, managing machine queues, and recording machine
usage.

### Operation Head

A core team position responsible for inventory, borrowing, visitor logs, payment
verification, exports, reports, and operational records.

### Events Head

A core team position responsible for planning, publishing, managing, and
reviewing events/workshops.

### Work Request

A request submitted by a student or team for project support, fabrication,
design, technical help, machine work, or related lab services. This is the
primary operational object and should not be called an order in the app.

### Work Request Leader

The student who owns a Work Request and is responsible for communication,
payment, approvals, and pickup. A Work Request can have collaborators.

### Work Request Member

A collaborator on a Work Request. Members should be visible for accountability,
but the leader remains the single source of truth.

### Manufacturing Task

A specific unit of operational work under a Work Request. Examples include laser
cutting, 3D printing, PCB milling, CNC routing, assembly, design support, or
testing.

### Machine Queue

The ordered list of Manufacturing Tasks waiting for machine/core team action.
The Machine Head owns queue decisions.

### Machine

A major piece of fabrication or technical equipment, such as a laser cutter, 3D
printer, CNC router, PCB milling machine, soldering station, or related lab
machine.

### Machine Runtime

The manually recorded time or usage count of a machine. Runtime can support
costing, maintenance planning, reporting, and operational history.

### Maintenance Record

A record that a machine or asset is unavailable, repaired, serviced, inspected,
or otherwise maintained.

### Asset

A fixed or individually tracked object such as a machine, laptop, projector,
camera, UPS, oscilloscope, or other high-value item.

### Inventory

Consumable or stock-like items managed by the lab, such as filament, acrylic,
PCB material, screws, sensors, motors, ICs, ESP32 boards, Arduinos, tools, and
hardware components.

### Consumable

An inventory item that is consumed or reduced during usage, such as filament,
acrylic, PCB material, solder, or electronic components.

### Borrowable Item

An item that can leave the lab temporarily and must be returned, such as tools,
boards, sensors, motors, or equipment.

### Borrowing Record

The record of who borrowed what, when it is due, when it was returned, and
whether it is overdue, damaged, lost, or cleared.

### Visitor Log

A digital record of a person entering and leaving a lab, including purpose,
lab, check-in time, checkout time, and related event/tool/project context when
relevant.

### Event

A scheduled community or learning activity such as a meetup, orientation,
training, talk, or gathering.

### Workshop

A hands-on event with practical learning, registration, attendance, and optional
certificate eligibility.

### Quotation

A cost estimate prepared for a Work Request before work begins or before
payment is collected.

### Payment Verification

The manual confirmation of a UPI or online payment by an authorized core team
member, usually Operation Head.

### Notification

An in-app or future push message sent to a user about a booking, Work Request,
payment, event, borrowing, vouch, system update, or operational action.

### Report

An exportable summary for operations, such as weekly inventory movement,
monthly lab usage, visitor logs, event participation, payments, or machine
runtime.

### Audit Log

An immutable or append-only record of important actions, including who did what,
when, and which entity was affected.

### Master Data

Configurable reference data controlled by admins, such as labs, departments,
semesters, positions, machine types, inventory categories, visitor purposes,
payment methods, and allowed email domains.

### Knowledge Base

A future-ready module for SOPs, guides, machine instructions, tutorials,
troubleshooting notes, and community-authored articles.

## Terms To Avoid

- Use Work Request instead of Order inside the student/core-team app.
- Use Manufacturing Task instead of Job when referring to machine work under a
  Work Request.
- Use Asset only for fixed individually tracked items, not consumable inventory.

## Dependencies

- Approved Product Charter v1.0.
- Current operational language used by IDEA Lab and Fab Lab.

## Risks

- Terms may drift if UI, database, and documents use different words.
- Core team positions may evolve yearly and must be configurable.

## Open Questions

1. Exact user-facing labels can be refined during UX design.
2. Some machine names and lab mappings require final operational confirmation.

## Future Enhancements

- Add localized Malayalam labels for selected user-facing terms.
- Add glossary mapping for external public website terminology later.

## Approval Checklist

- [ ] Terms reviewed by Product Owner
- [ ] Terms reviewed by core team representative
- [ ] Module list accepted
- [ ] Approved for use in BRD/PRD/SRS
