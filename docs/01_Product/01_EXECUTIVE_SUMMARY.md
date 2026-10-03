# Grow Platform Executive Summary

Status: Draft - Phase 1A  
Owner: Product Owner / Lead Architect  
Last updated: 2026-08-02

## Purpose

This document summarizes the business case for Grow at executive level. It
references the approved Product Charter v1.0 and does not replace detailed PRD,
SRS, database, UI, or implementation documents.

## Executive Overview

Grow is the proposed digital operating platform for the Innovation Hub ecosystem
at Model Engineering College, initially serving IDEA Lab and Fab Lab. It exists
to replace scattered manual coordination with a single reliable platform for
students, core team members, faculty, and administrators.

The platform is not only a booking app. It is intended to manage the daily
operational backbone of an innovation facility: Work Requests, Manufacturing
Tasks, machine queues, inventory, borrowing, visitor logs, events, quotations,
payments, reports, notifications, and audit history.

## Business Problem

Innovation labs often run on informal communication channels, manual records,
spreadsheets, memory, WhatsApp messages, and person-dependent coordination.
This creates operational risk:

- Work Requests are hard to track from submission to completion.
- Machine queues and responsibilities are unclear.
- Inventory and borrowing records are difficult to maintain.
- Visitor purpose and lab usage are not consistently recorded.
- Payment verification can become disputed.
- Reports require manual reconstruction.
- New core team members lose operational context.

Grow addresses these issues by creating structured, role-aware workflows.

## Business Opportunity

Grow can become the operational system of record for college innovation hubs.
For MEC, it can make IDEA Lab and Fab Lab easier to run. Long term, it can
become a reusable platform for other institutions if the system is built around
configurable master data, clean module boundaries, and auditability.

## Target Outcomes

### For Students

- Submit and track Work Requests.
- Attend events and workshops.
- Borrow components and tools responsibly.
- Check into labs with purpose.
- Build a visible maker identity over time.

### For Core Team

- See assigned work clearly.
- Manage queues and tasks.
- Maintain inventory and borrowing records.
- Verify payments.
- Generate operational reports.

### For Administration

- Improve accountability and reporting.
- Preserve institutional records.
- Understand usage, revenue, inventory, and participation patterns.

## MVP Direction

MVP/V1 should prioritize operational reliability over advanced automation.

V1 should focus on:

- institution-based onboarding
- role-aware dashboard
- Work Requests and Manufacturing Tasks
- machine queue basics
- inventory and borrowing foundation
- visitor log
- event/workshop management
- quotation and manual UPI payment verification
- notifications
- reports and audit logs

## Non-Goals For V1

V1 should not include:

- direct messaging/chat
- full payment gateway
- external public customer portal inside the mobile app
- AI quotation
- AI design validation
- IoT machine telemetry
- multi-college UI
- public marketplace

## Canonical Module Scope

Grow is organized around the module list defined in
`BUSINESS_GLOSSARY.md`, covering MOD-01 through MOD-22.

Priority V1 modules:

- MOD-01 Authentication
- MOD-02 User Profiles
- MOD-04 Work Requests
- MOD-05 Manufacturing Tasks
- MOD-06 Machine Queue
- MOD-07 Machines
- MOD-09 Assets
- MOD-10 Inventory
- MOD-11 Borrowing
- MOD-12 Visitors
- MOD-13 Events
- MOD-15 Payments
- MOD-16 Quotations
- MOD-17 Notifications
- MOD-18 Reports
- MOD-19 Audit Logs
- MOD-20 Administration
- MOD-21 Master Data

## Strategic Recommendation

Grow should be built as a phased operational platform, not as a single large UI
rewrite. The first implementation work after requirements and architecture
approval should focus on the operational spine:

1. Master Data
2. Roles and permissions
3. Work Requests
4. Manufacturing Tasks
5. Machine Queue
6. Inventory/Borrowing
7. Visitors and Events
8. Payments/Reports/Audit Logs

## Dependencies

- Approved Product Charter v1.0.
- Business Glossary.
- Core team review of operational workflows.
- Phase 1B PRD/SRS before implementation.

## Risks

- Scope could expand before the operational core is stable.
- UI polish could distract from operational correctness.
- Database design could be rushed before business rules are complete.
- Manual processes may remain outside Grow if workflows are too complex.

## Open Questions

1. Which operational module should be implemented first after architecture:
   Work Requests/Machine Queue or Inventory/Borrowing?
2. What level of reporting is required for the first internal release?
3. Which existing RC5 community/profile features should remain in V1 versus
   later releases?

## Future Enhancements

- External public ordering website.
- Alumni engagement portal.
- Push notifications.
- AI-assisted quotations.
- IoT telemetry.
- Multi-institution rollout.

## Approval Checklist

- [ ] Executive business direction accepted
- [ ] MVP/V1 scope accepted
- [ ] Non-goals accepted
- [ ] Module prioritization accepted
- [ ] Approved to proceed with Phase 1A BRD review
