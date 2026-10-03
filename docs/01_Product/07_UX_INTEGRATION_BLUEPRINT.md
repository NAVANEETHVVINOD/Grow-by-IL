# Grow UX and Integration Blueprint

Status: Draft  
Owner: Product Design and Lead Architect  
Version: 0.1  
Last updated: 2026-09-11  
Depends on: `00_PRODUCT_CHARTER.md`, `05_WORK_REQUEST_REQUIREMENTS.md`, `06_WORK_REQUEST_IMPLEMENTATION_CONTRACT.md`, `docs/02_Architecture/MODULE_LIFECYCLE.md`  
Referenced by: Future UX implementation plans and module PRDs

> **Authoritative Version Pointer**: This document organizes the user experience
> and integration work. It does not replace the Product Charter, approved Work
> Request contract, database schema, RLS policy, or root engineering governance.
> When this document conflicts with an approved source, the approved source wins.

## 1. Purpose and Delivery Boundary

Grow is a mobile-first operating platform for the Model Engineering College
Innovation Hub. The experience must feel calm, direct, and capable: students
should understand what to do next, while operational roles can scan work and
take accountable actions quickly.

This blueprint is a design and integration map, not implementation approval. It
does not authorize production SQL, new RLS policies, new role values, backend
persistence for Work Requests, Manufacturing Tasks, or Machine Queue.

The current visual direction is premium soft neo-brutalism: paper-like light
surfaces, black structural borders, compact hard shadows, expressive but useful
accent colors, and short tactile motion. Visual character must never reduce
legibility, touch-target size, task density, or accessibility.

## 2. Verified Current State

| Area | Current state | UX consequence |
| --- | --- | --- |
| Authentication | Email/password and Google sign-in are implemented. Android startup verified `user_profiles` access and an authenticated profile gate on 2026-09-11. | Treat auth as a reliability slice; finish physical email and Google journeys before broad visual work. |
| Roles | Code and `public.users.role` currently support `student`, `lab_admin`, and `super_admin`. | Do not render capabilities for Machine Head, Operation Head, or other planned roles as if authorization exists. |
| Profile | `public.users` drives completion. The profile ecosystem has separate relational tables and migration/offline infrastructure. | Profile completion and rich profile editing are separate flows; do not imply onboarding writes all profile tables. |
| Work Requests | Feature-flagged Fabrication V1 UI/local flow; its source is a mock in-memory data source and local draft storage. | No UI may claim a cloud submission, operator assignment, payment, or machine queue action. |
| Manufacturing Tasks and Machine Queue | Product rules exist, but no approved module PRD/SRS, implementation contract, UI, or persistence exists. | Keep both modules out of the current navigation and implementation backlog until their gates are passed. |
| Existing shell | Home, Akathalam, and Profile are the current bottom-navigation destinations. | Operational modules should enter through contextual Home actions or task links, not a crowded permanent tab bar. |

## 3. Source Hierarchy and Known Conflicts

| Topic | Current authority | Conflict or drift | Resolution for future work |
| --- | --- | --- | --- |
| Product scope | `00_PRODUCT_CHARTER.md` and `PRODUCT_SCOPE.md` | The platform describes a wider operational role taxonomy than the shipped role enum. | Treat expanded roles as planned requirements, not current permissions. A role model decision is required before implementation. |
| Work Request V1 | `06_WORK_REQUEST_IMPLEMENTATION_CONTRACT.md` | The business-rule matrix includes `Urgent`; the approved V1 contract limits priority to Low, Normal, High. | Use the approved contract for the current local flow. Resolve `Urgent` during a later requirements revision. |
| Onboarding | Auth screens and `public.users.profile_completed` | `product_architecture.md` contains older Google-only/onboarding wording that does not match the current email-plus-Google implementation. | Runtime code and the approved product requirements govern current behavior. Reconcile the older architecture document in a documentation-only task. |
| Profile ecosystem | `003`, `006`, and `008` migrations plus `schema.sql` | Live profile policies/indexes have known drift. | Do not hide drift through new UI or an ad-hoc migration. Resolve it through a separately reviewed database reconciliation. |

## 4. Information Architecture

### 4.1 Current, reachable product structure

```text
Grow
|- Authentication
|  |- Splash and session gate
|  |- Onboarding entry
|  |- Email login and registration
|  |- Google sign-in
|  `- Profile completion
|- Main shell
|  |- Home
|  |- Akathalam
|  `- Profile
|- Contextual screens
|  |- Notifications
|  |- Projects and project detail
|  |- Events and event detail
|  |- Lab, tools, QR scan, bookings
|  |- Knowledge, mentorship, donations
|  |- Work Requests and local Create Work Request
|  `- Admin and unauthorized states
`- System states
   |- 404
   |- Unauthorized
   `- Debug schema status in debug builds only
```

### 4.2 Product modules by maturity

| Module | Product status | Navigation posture |
| --- | --- | --- |
| Authentication and profile completion | Current | Entry gate only; never visible as a normal destination after completion. |
| Home, Akathalam, Profile | Current | Bottom navigation. Preserve the three-destination shell. |
| Events, lab, tools, projects, notifications, admin | Current | Contextual routes and Home/role-aware entry points. |
| Work Requests | Current local V1 | Home quick action and contextual request links. Feature-flagged. |
| Manufacturing Tasks, Machine Queue | Planned | No route or shell item until PRD, contract, and local-flow gates are approved. |
| Machines/maintenance, inventory/borrowing, visitors, quotations/payments, reports | Planned | Design only at requirements level; no fake operational screens. |

### 4.3 Navigation rules

1. `/splash` is the sole post-auth decision point. It resolves the session,
   synchronizes the `public.users` row, and routes completed users to Home or
   incomplete users to profile setup.
2. Authenticated users sent to `/login`, `/register`, or `/onboarding` must
   return to `/splash`, never directly to Home. This prevents profile-gate
   bypasses.
3. A bottom bar has at most three stable destinations. Operational flows begin
   from Home cards, notifications, deep links, or role-scoped task inboxes.
4. Unknown routes render the explicit 404 state. Unauthorized role access
   renders the unauthorized state, not an empty page or a silent redirect.
5. A detail screen returns to the list/context that opened it. It must not
   reset the user to Home unless its parent record no longer exists.

## 5. Roles and Capability Boundary

### 5.1 Implemented authorization model

| Role | Shipped UI meaning | Current implementation boundary |
| --- | --- | --- |
| Student | Default self-selected role. | Standard signed-in experience and own-record actions where implemented. |
| Lab Admin | Assigned role. | Admin dashboard access. |
| Super Admin | Assigned role. | Admin dashboard access and elevated governance actions already implemented. |

### 5.2 Planned actor taxonomy

The Product Charter names faculty, alumni, Core Team, Machine Head, Operation
Head, and specialist heads. These are operational actors, not current
`AppRole` values. The following is a design boundary, not an authorization
matrix:

| Planned actor | Intended future responsibility | Required before implementation |
| --- | --- | --- |
| Faculty and Alumni | Participation and approved read-mostly experiences. | Role semantics, user lifecycle, and RLS approval. |
| Core Team | Review requests and communicate operational decisions. | Work Request backend contract and audit model. |
| Machine Head | Own Manufacturing Task allocation and queue decisions. | Manufacturing Task and Machine Queue PRDs/contracts. |
| Operation Head | Own inventory, borrowing, record, and billing operations. | Per-module PRD and role/RLS design. |
| Events, Tech, Design, Media, Documentation Heads | Functional team responsibilities. | Product decision whether these are roles, assignments, or permissions. |

No client-side button visibility is authorization. Every future capability must
be represented in a role-to-permission model and enforced by repository/API and
RLS rules before it is released.

## 6. Primary User Journeys

### 6.1 Authentication and profile completion

```text
Launch
-> Splash
-> session absent: onboarding -> login or registration
-> session present: ensure public.users row
-> profile_completed false: profile setup
-> profile_completed true: Home
```

Email registration creates an auth account followed by a `public.users` row.
Email login and Google sign-in both return through Splash. Google sign-in first
obtains an identity token, signs in to Supabase, and synchronizes a missing
`public.users` row. The rich `user_profiles` ecosystem is not a prerequisite
for entering Home.

### 6.2 Fabrication Work Request V1

```text
Home or contextual entry
-> My Work Requests
-> Create
-> Fabrication category and one-or-more subcategories
-> Request basics
-> Dates, lab preference, links, material/design choices
-> Collaborators
-> Review and acknowledgements
-> Local submit confirmation
-> My Work Requests and local detail timeline
```

The approved local flow stops here. The displayed request is local/mock data;
there is no cloud write, payment collection, machine assignment, task split,
operator assignment, or queue reordering.

### 6.3 Future manufacturing boundary

```text
Approved Work Request
-> Core Team review decision
-> One or more Manufacturing Tasks
-> Machine Head assignment and queue decision
-> Execution status and audit history
-> Ready for pickup
-> Completion
```

Manufacturing Task answers **what work must be executed**. Machine Queue
answers **when, where, and in which operational order it executes**. A task
must not become a queue record merely to make a future screen look complete.

## 7. Screen and State Specification

Every screen added or redesigned must define its entry, data source, action,
and recovery states before implementation.

| Screen family | Primary data | Required states | Primary action |
| --- | --- | --- | --- |
| Auth | Supabase Auth and `public.users` | form validation, submitting, credential failure, cancelled Google flow | Sign in or create account |
| Profile completion | `public.users` | loading user, validation, save failure, completion | Complete setup |
| Home | Current profile and feature-specific providers | skeleton, personalized loaded state, unavailable section, retry | One high-value contextual action |
| Profile | profile ecosystem repository plus cache | loading, empty section, sync queued, sync failure, retry | Edit a focused profile section |
| Work Request list | local data source in current phase | seeded/local list, empty, filter no-results, local submit feedback | Create request |
| Work Request detail | local detail controller in current phase | loading, missing local request, timeline, cancellation/rejection variants | Return or contextual status action |
| Future operational list | approved repository/API only | loading, empty, permission denied, offline, retry | Role-approved task action |

Use an explicit state vocabulary across network-backed screens: loading, empty,
loaded, submitting, success, recoverable error, permission denied, and offline
or queued. A blank section is never an acceptable loading or error state.

## 8. Design System Direction

The existing implementation is the starting point: `RC5DesignTokens`,
`RC5Theme`, `NeoCard`, `NeoButton`, Space Grotesk headings, and DM Sans body
copy. Future work must refine those primitives before restyling individual
screens.

### 8.1 Visual rules

| Element | Rule |
| --- | --- |
| Surfaces | Use white or near-white as the main canvas. Use yellow, blush, blue, or green as purposeful status/section accents, not large decorative backgrounds. |
| Borders and shadows | Use 2px borders and a compact 3px hard offset shadow for interactive cards and commands. Keep structural layouts unframed. |
| Radius | Use 4px for controls and 8px for cards. Reserve pill radius for compact filters, status chips, and segmented controls only. |
| Cards | One card equals one actionable or repeated unit. Do not nest cards or turn every page section into a floating panel. |
| Typography | Space Grotesk communicates hierarchy; DM Sans carries body copy. Keep labels clear, sentence case, and task oriented. |
| Icons | Use familiar Material/Lucide-equivalent semantics, icon-only controls with tooltips where a text label is redundant. |
| Images | Use real project, machine, event, or profile media only when it adds operational meaning. Do not use stock-like or atmospheric decoration. |

### 8.2 Motion and feedback

- Press feedback: 100-120ms card/button compression plus light haptic feedback
  where appropriate.
- Navigation and state changes: 200ms fades/slides; do not use stacked or
  decorative animation chains.
- Loading: skeletons preserve layout dimensions. Long operations must show a
  label and retain a retry path.
- Success: a concise confirmation tied to the completed action; no celebratory
  full-screen interruption for routine operations.
- Respect platform reduce-motion settings when introducing new animation.

### 8.3 Accessibility and responsive baseline

- Minimum 48dp touch targets and visible focus states.
- Never encode request state using color alone; pair color with a label and
  icon.
- Validate and announce form errors near the affected field.
- Support text scaling without clipped status chips, buttons, cards, or wizard
  steps.
- Phone is the primary layout. Wide screens may use split auth/content layouts
  but preserve one dominant task column.

## 9. Frontend and Backend Contract Map

| Feature | Current UI/application path | Current data contract | Boundary before expansion |
| --- | --- | --- | --- |
| Auth | auth screens -> `AuthRepository` / `GoogleAuthService` -> Supabase Auth | `auth.users`, `public.users` | Do not add profile table writes as a workaround for auth. |
| Profile | profile screens -> Riverpod providers -> `ProfileEcosystemRepository` | `user_profiles` and child profile tables, local cache/queue | Resolve recorded schema/RLS drift separately from UI. |
| Lab/tools/bookings | screens -> providers -> repositories | tools, bookings, lab sessions | Retain repository boundary and explicit failure states. |
| Events/projects/notifications | screens -> providers/repositories | existing Supabase tables and models | Audit model-to-schema mismatches before visual expansion. |
| Work Requests | wizard/detail -> Riverpod controllers -> local draft/mock data source | no approved cloud table/repository in this phase | Require approved ERD/RLS before `data/` or `domain/` layers. |
| Manufacturing/Queue | none | none | Require PRD/SRS, contract, architecture guard coverage, ERD, RLS, then repository/API. |

## 10. UX and Architecture Risks

| Priority | Finding | Required action |
| --- | --- | --- |
| P0 | Auth routing previously allowed a completed session to race toward Home before the completion check. | Current local fix routes successful auth flows through Splash. Verify email and Google journeys on device before packaging the auth slice. |
| P1 | Product actors exceed the implemented three-role enum. | Do not build role-aware operational screens until the role/permission decision is approved. |
| P1 | Work Request mock/local behavior can be mistaken for operational submission. | Keep all confirmation copy explicitly local until the backend gate is approved. |
| P1 | Existing design documents contain older visual and onboarding assumptions. | Reconcile documents in a focused documentation change before declaring a new design system authoritative. |
| P2 | Profile schema/RLS/index drift remains independent security and data debt. | Reconcile only through canonical migration history and a reviewed plan. |
| P2 | Current UX audit identifies Home density, profile scanability, and wizard summaries as design debt. | Address them through isolated UI slices after the blueprint review. |

## 11. Recommended Implementation Sequence

| Milestone | Scope | Required evidence | Explicit exclusion |
| --- | --- | --- | --- |
| 0. Auth reliability closeout | Physical email registration/login, Google sign-in, profile gate, Home entry. | Device log and manual QA result; analyzer and tests green. | New DB schema, redesign of unrelated screens. |
| 1. Design primitive consolidation | Bring shared buttons, cards, inputs, status chips, loading/error/empty states into alignment with RC5 tokens. | Widget tests, accessibility text-scale checks, screenshots on phone and wide layout. | A whole-app visual rewrite. |
| 2. App shell and Home | Clarify navigation hierarchy, one primary Home action, bounded quick actions, resilient section states. | Navigation/back/404/unauthorized test cases. | New operational modules. |
| 3. Profile | Focused edit entry points, state feedback, profile migration/offline cues. | Existing profile migration and security tests. | Schema repair hidden inside UI work. |
| 4. Work Request local experience | Wizard comprehension, local list/detail clarity, timeline and cancellation/rejection states. | Existing Work Request tests plus device accessibility QA. | Persistence, payments, Manufacturing Tasks, Queue. |
| 5. Manufacturing Task definition | PRD/SRS, approval log entry, implementation contract, architecture-guard path. | Product Owner and architecture approval. | UI, DB, repository, or queue implementation. |
| 6. Manufacturing local flow | Approved UI/local models, controller, validation, tests. | Contract acceptance criteria. | Supabase migrations and data/domain layers. |
| 7. Backend and Queue | DB architecture, RLS, repository/API, operational persistence; then Queue requirements and implementation. | Separate approved gates for each module. | Coupling task definition with queue scheduling. |

## 12. Definition of Ready for a UI Slice

A design or implementation slice is ready only when it has:

1. A named user and role within the implemented authorization model.
2. A single primary task, entry point, exit path, and back behavior.
3. A stated source of data that already exists or an approved future contract.
4. Loading, empty, error, offline, and permission-denied behavior.
5. Reused design-system components rather than a one-off visual language.
6. An explicit test plan covering validation, text scale, navigation, and
   relevant device behavior.
7. A bounded PR scope that does not mix UI redesign, security/schema changes,
   and unrelated dependency upgrades.

## 13. Next Review Decision

Review this blueprint before beginning broad visual work. The first executable
slice after review is **Auth Reliability Closeout**: complete physical email and
Google tests, verify the profile gate and Home entry, then package only the
focused auth/navigation changes. The next product milestone remains the
Manufacturing Task PRD/SRS, not Manufacturing UI or database implementation.
