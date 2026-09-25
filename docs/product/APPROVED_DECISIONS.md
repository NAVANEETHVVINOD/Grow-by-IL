# Current product decisions

Status: decisions stated by the product owner through 16 September 2026.
This is a planning record, not a claim that the app implements each decision.
Machine, tool, component, logo, final name, and pricing inventories will be
provided later. Do not invent them or populate production with sample entries.

## Audience and access

- Idea Lab and Fab Lab are one managed organisation with two rooms.
- Design for a supervised initial group of 25–50 and eventual use by 4,000+
  students and external participants. Android first; iOS later.
- Any email address may sign up. Every person signs in, completes mandatory
  onboarding, and can then enter the app. MEC mail is optional. Collect
  institution and identity details appropriate to a student or professional;
  no manual verification gate was approved for ordinary onboarding.
- Profile enrichment, including interests, skills, projects, volunteering,
  hackathons, education, and experience, is optional and editable later.
- A public profile is visible to signed-in members; sharing to another app
  may use a link, but a viewer still signs in for member-only details.
- The super admin appoints Machine, Operations, Events, Design, Web, and other
  heads. Role elevation is never self service. Only a Machine Head operates
  fabrication machines.

## Navigation and lab

- Bottom navigation has Home, Lab, and Profile. Remove Akathalam as a separate
  brand/destination. Use an original neo-brutalist visual system, accessible
  animation, useful drawings, no emoji UI. English first; Malayalam later.
- Manual check-in/out is primary. Door QR is optional. Show who is currently
  present, including name and profile, to signed-in members.
- Ordinary hours are 9 AM–6 PM, Monday–Saturday. After hours, entry is allowed
  while any appointed head is present. Capacity is currently about 40–50;
  final room-specific limits and rules need operational confirmation.
- Require safety acknowledgement before relevant lab, machine, or borrowing
  actions. A checked-in state may appear in an Android notification; it must
  end when checked out and obey notification permissions.

## Work, borrowing, and projects

- Users may submit fabrication and other work requests for personal or
  academic purposes. Machine-related work routes to the Machine Head; other
  requests route to Operations. Keep Work Requests, Manufacturing Tasks, and
  Machine Queue distinct.
- Members may request reservations, but only Machine Heads operate machines.
  Machine questions depend on the eventual equipment inventory. Quote and
  actual usage must remain auditable.
- Borrowers propose a return date within the semester. They mark returned;
  Operations verifies. A warning precedes the current default fine of ₹10 per
  day, configurable by item/policy. Do not charge from an unverified clock or
  assume an unapproved cap.
- Any member can create a public or private project. Public projects appear
  immediately in discovery. Joining by code creates a request; only the
  creator approves it. The project creator controls membership. Core review
  for lab support is a separate decision from project visibility.

## Events and money

- Free and paid events may admit outside participants, subject to event
  audience. A paid seat is confirmed only after payment verification. Pending
  payment does not reserve capacity; when full, registration closes. If money
  arrives after capacity is exhausted, Events handles a recorded refund.
- Cancelling any RSVP requires a reasoned request to the Events Head; members
  do not cancel confirmed attendance unilaterally. Events handles all event
  payment, cancellation, and refund decisions. Operations handles non-event
  charges, quotes, and usage billing.
- The lab uses an official UPI QR. Record a UTR/reference and optionally
  payment proof; head verification and all changes need an audit history.
  Confirming the last seat requires a server-side atomic capacity check.

## Data and launch

- Keep anonymised operational analytics for one academic year, with a clear
  privacy notice. Define the exact academic-year cutoff, personal-data
  deletion/retention rules, and legally required financial records before
  automating deletion. Optional profile fields are not required for access.
- The final product name, inventory, lab pricing, brand assets, and account
  recovery policy await product-owner input. Avoid hardcoded mutable policies
  and placeholder live data while these are unresolved.

## Conflict to resolve in existing documentation

The old ADR-006 says external customers are outside mobile V1. The owner has
since approved external participant onboarding and fabrication requests in
the app. Update ADR-006 and its affected implementation contracts in a focused
review before building that path; do not silently follow the stale ADR.
