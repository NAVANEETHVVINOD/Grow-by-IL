# Grow Platform Product Vision

Status: Draft - Phase 1A  
Owner: Product Owner / Lead Architect  
Last updated: 2026-08-02

## Purpose

This document defines the product vision for Grow as an Innovation Hub
Management Platform. It aligns product design, engineering, operations, and
future planning around a shared north star.

## Vision Statement

Grow should become the operating system for college innovation hubs: a platform
where students can turn ideas into structured Work Requests, core teams can
manage execution responsibly, and institutions can preserve trustworthy records
of people, machines, materials, events, payments, and impact.

## Product Identity

Grow is:

- operationally reliable
- student-friendly
- core-team-aware
- audit-ready
- configurable
- lightweight enough for student-led operations
- extensible enough for future institutions

Grow is not:

- only a lab booking app
- only a social/community app
- an external marketplace in V1
- a chat platform
- an AI-first automation experiment

## Product Principles

### PV-PR-01: Operations Before Decoration

The app can be bright, friendly, and beautifully designed, but operational
clarity comes first.

### PV-PR-02: Every Workflow Must Have An Owner

Each operational entity should have one primary owner. Shared visibility is
allowed, but ownership must be clear.

### PV-PR-03: Students Request, Core Team Executes

Students can request work and track progress. Fabrication machines are operated
primarily by trained core team or machine team members.

### PV-PR-04: Manual Where Manual Is Safer

V1 should support manual UPI verification, manual machine usage entry, manual
inventory corrections, and manual queue decisions instead of pretending
automation exists.

### PV-PR-05: Configure, Do Not Hardcode

Labs, positions, departments, categories, domains, visitor purposes, and payment
methods should be data-driven wherever practical.

### PV-PR-06: Preserve History

Important actions should leave an audit trail.

### PV-PR-07: Build For Low Operational Load

The system should reduce work for the core team. If a workflow requires too much
data entry, it will fail in practice.

### PV-PR-08: Keep V1 Focused

Messaging, external ordering, AI estimation, IoT telemetry, and full payment
gateway integration are future capabilities, not V1 blockers.

## Experience Vision

### Student Experience

Students should feel that the lab is accessible, understandable, and alive.
They should know what they can request, where their request stands, what they
owe, what they borrowed, which events are active, and how to participate.

### Core Team Experience

Core team members should see what needs attention today. Machine Heads need
queues and task clarity. Operation Head needs inventory, visitor, borrowing, and
payment reliability. Events Head needs registration and attendance workflows.

### Admin Experience

Admins should have oversight without clutter. They need configuration,
moderation, reports, role control, and audit visibility.

## Design Vision

The UI should be bright, professional, and fun:

- white-first layout
- strong typography
- soft purple/pink accent system where appropriate
- modern neo-brutalist tactile controls
- clear cards and chips
- minimal but polished motion
- no overloaded dashboards
- no decorative complexity that hurts readability

UX must make complex operations feel simple, especially on mobile.

## Product Horizons

### MVP / Internal Alpha

Validate core operations with a small trusted group:

- onboarding
- Work Requests
- machine queue
- inventory import
- borrowing
- visitor log
- basic events
- manual payment verification

### V1 / Internal Production

Run IDEA Lab and Fab Lab daily operations:

- stable role dashboards
- reports
- audit logs
- notifications
- admin controls
- refined UX

### V2

Expand platform depth:

- alumni module
- public external website
- certificates
- richer analytics
- better exports
- push notifications

### Future

Prepare for:

- multi-institution support
- AI-assisted costing
- IoT telemetry
- payment gateway
- knowledge base growth

## Dependencies

- Approved Product Charter v1.0.
- Business Glossary.
- Phase 1A BRD.
- Phase 1B PRD/SRS.

## Risks

- Product identity could split between community/social features and operations.
- UI redesign could outrun backend readiness.
- New modules could duplicate existing RC5 profile/community work.

## Open Questions

1. How much of the previous RC5 maker-profile direction should remain in V1?
2. Should the first internal alpha target core team only or core team plus
   selected students?
3. What is the minimum delightful UI level for the first operational release?

## Future Enhancements

- Public student portfolios.
- Alumni network and donation activities.
- Certificate generation.
- External customer website.
- Push notifications.

## Approval Checklist

- [ ] Vision accepted
- [ ] Product principles accepted
- [ ] V1 focus accepted
- [ ] Design direction accepted
- [ ] Future horizons accepted
