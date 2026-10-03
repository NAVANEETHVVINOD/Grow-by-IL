# Penpot page completion specification — 2026-09-17

Status: design handoff candidate, **not a claim that Penpot has been updated**. The connector was unavailable during this pass. The file previously had pages numbered 00–17 and a newer `18 — Home Lab Profile Shell`; confirm the live page list and ownership before editing. Page 17 was reported blank by the product owner.

## Product and visual intent

Grow is a credible engineering/lab operating product with a playful maker personality. The visual language is bright neo-brutalism: near-white paper, near-black ink, 2 px structural outlines, compact hard shadows, crisp typography, and color that clarifies actions and status. Original technical doodles and authentic lab imagery provide delight; they never replace labels, status, or data. No emoji decoration, invented lab statistics, fabricated member badges, placeholder operational records, or fake photos.

### Canonical design-token proposal for approval

| Token | Value | Use |
| --- | --- | --- |
| `ink` | `#101114` | text, border, hard shadow |
| `paper` | `#FFFDF7` | primary page canvas |
| `surface` | `#FFFFFF` | cards and fields |
| `blue` | `#83D8FF` | information, discovery, primary secondary accent |
| `lime` | `#BDF57A` | successful or ready actions, never the sole status cue |
| `yellow` | `#FFE36B` | prompts, reminders, maker highlights |
| `pink` | `#FFA6D8` | community and project accents |
| `coral` | `#FF756A` | attention, warning, destructive confirmation only with labels |

Typography: Space Grotesk for display/title hierarchy; DM Sans for body, labels, and forms. Use a 4/8 px spacing system with 16 px phone gutters, 24–32 px section spacing, 48 dp minimum touch targets, 2 px outlines, 3–4 px hard shadows, 4 px control radius, 8 px card radius, and pills only for compact chips/filters. Body text must meet WCAG AA contrast against its actual surface. Accent fills need ink text unless contrast is proven. The active bottom destination must have both a label and selected shape/fill, not color alone.

Motion: 100–120 ms press compression/shadow shift; 180–220 ms route/content transitions; 240–300 ms once-only celebratory moments (such as confirmed lab check-in), with no blocking animation. Loading skeletons keep the final geometry. Respect reduced-motion preference and expose text equivalents. Doodles may animate once on entry but must not loop over task content. A checked-in banner may persist while the app is open; a true OS-level banner/notification requires a separate Android permission/background-behavior design and must not be promised by a static mockup.

Imagery: use only approved IDEA Lab/Fab Lab photos, user-supplied project media, or original vector maker illustrations. Provide a useful no-image state. Never use generic stock machinery to imply an actual installed asset. Add alt text, crop-safe focal points, and rights/source metadata for every image. Build a small reusable vector motif set (spark, traced wire, drafting grid, tool silhouette, cut-paper arrow) instead of unique doodles on every card.

## Page-by-page handoff

The labels below are **proposed board responsibilities**, not verified names of the existing Penpot pages. Preserve and map existing useful work; do not replace a finished page just to match numbering.

| Board | Deliverable and primary decision | Required production states / detail |
| --- | --- | --- |
| 00 — Product foundation | Product personality, user types, one entity/two rooms, navigation map, original visual references | Approved vs proposed decisions visibly labeled; real photo/asset sources only |
| 01 — Tokens | Palette, semantic colors, type scale, spacing, borders, shadows, breakpoints, icon/doodle rules | Contrast samples, dark/low-light consideration, large-text samples |
| 02 — Components | Buttons, cards, fields, chips, tabs, app bar, bottom bar, banners, sheets, dialogs | Default, pressed, focused, disabled, loading, validation, destructive variants |
| 03 — Content/states | Empty, loading, partial failure, offline, unauthorized, missing record, retry patterns | Honest copy and skeleton geometry; no fake counts or records |
| 04 — Splash/session | Brand splash and session/profile gate | Signed out, refreshing, incomplete onboarding, network failure; no direct gate bypass |
| 05 — Sign in/register | Email/password and Google entry with legal/help links | Form errors, loading, cancelled Google flow, recoverable failure; no credential decoration |
| 06 — Onboarding | Required identity path by MEC student / other student / professional; optional interests/skills | Required fields marked, skip optional sections, save error, return progress, no invented verification badge |
| 07 — Profile completion | Minimum required profile before Home, then editable enrichment | Clear progress and privacy descriptions; resumable failure |
| 08 — Home | One primary task, quick actions, relevant events/projects/news with real data | Personalized/empty/error sections, no false ticker/opportunities, selected Home nav |
| 09 — Lab | One lab entity with IDEA and Fab rooms, manual entry, presence, requests/bookings | Checked out/in, outside-hours supervised entry, no booking, permission denied, offline; no machine self-operation implication |
| 10 — Profile | Identity, editable sections, public view for signed-in users, share action | No fabricated verification/tenure/badges; private data clearly separated; accessible tabs/sections |
| 11 — Projects | Discover, create public/private, team, code-based join request | Owner approval, pending/declined, empty discovery, private visibility, code error |
| 12 — Events | Discover, free/paid registration, RSVP, full event, cancellation request | Payment pending is not a seat; verified seat, sold out, refund pending/complete, outside attendee rules |
| 13 — Work Requests | User list, create wizard, detail/timeline | Real vs local-only status explicitly labeled; validation, saved draft, submission failure, cancellation request |
| 14 — Machines/operations | Machine Head queue and Operation Head work surfaced in role-aware task views | Approved authorization only; no fake inventory, machine availability, or price |
| 15 — Bright system and motion | High-fidelity system examples, reusable doodles and asset placement | Motion storyboard, reduced motion, component mapping back to tokens |
| 16 — Admin/system | Super Admin role assignment, approvals, audit states; 404/unauthorized/offline | Separate permission-denied and empty data; high-risk confirmation and history |
| 17 — Interaction and state specification | **Fill the reported blank page** with full click-through routes, back behavior, state transitions, micro-interaction frames, and accessibility notes | At least Home→Lab→Profile, onboarding gate, request, project join, paid RSVP, cancellation, check-in/out; loading/error/offline/denied overlays; no dead targets |
| 18 — Home Lab Profile shell | Refine the already-created bright shell to final implementation-ready frames | Phone and wide layouts, selected-tab variants, real/empty data, documented component and token IDs |

## Key wireframes to implement in Penpot

```text
HOME                            LAB                             PROFILE
Brand / notifications           Lab status / hours              Identity / share / settings
Personal greeting               IDEA Lab | Fab Lab              Public profile / private account
Primary task CTA                Manual Check In or Out          About / interests / skills
Quick actions (4 max)           Active session + exit          Projects / experience / education
Upcoming event or empty         Rooms + actual assets          Activity from real records
Projects or empty               Booking/request entry          Edit focused section
Home | Lab | Profile             Home | Lab | Profile            Home | Lab | Profile
```

Home should make the next action obvious within one viewport; it is not a feed of equal-weight cards. Lab should not present QR as the only entry route. Profile share should use an owned, verified destination when implemented; do not render a broken `grow.app` link. Project code entry creates a join request, never instant membership. Paid-event registration must show “payment under review” without reserving a seat, then confirm only after verification and capacity check. Machine booking copy says “request machine work/slot,” never “operate machine.”

## Acceptance criteria for every actual Penpot page

1. One named user/task, entry, exit, back destination, and primary CTA; non-applicable details are deliberately omitted rather than filler.
2. Component instances reference the shared library; local overrides are documented, not duplicated color/type systems.
3. Phone artboard at a current Android viewport plus responsive/wide behavior; no clipped text at 200% text scale.
4. Default, loading, empty, partial error, offline, disabled, and unauthorized states where applicable, plus confirmation for destructive/financial actions.
5. Doodle/image source, accessibility description, and motion purpose documented. Decorative motion has a reduced-motion alternative.
6. Prototype links cover the happy path and back/cancel/retry; no blank Page 17, dead buttons, or fake operational data.
7. Flutter comparison screenshot and issue link after implementation. The Penpot frame is not “done” until it can be mapped to shared tokens/components and checked on Android.

## Implementation order after design review

Finish navigation and auth gate evidence; reconcile charter/role decisions; approve tokens/components; implement Home/Lab/Profile shared primitives; compare Android screenshots; then progress through Work Requests, Manufacturing Tasks, Machine Queue, inventory, projects, events, payments, and reports under their separate product/backend gates. Do not treat this design document as authorization for production SQL, RLS, or payment logic.
