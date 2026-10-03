# Grow~ AI Development Rules

## Project Status

* RC1 frozen and stable
* RC2 frozen and stable
* No uncontrolled feature expansion
* Mobile-first operational platform

---

## Architecture Rules

* Supabase is the source of truth
* Never hallucinate schema columns
* Always inspect live schema before model changes
* No fake repositories or placeholder backends
* No duplicate operational systems
* Tools are the inventory system

---

## Database Rules

* All schema changes require migration docs
* All schema changes require rollback consideration
* RLS required for all protected tables
* Never expose service_role keys to frontend
* Auth checks must exist at DB level, not only UI
* All documentation lives in docs/ at the repository root.
* Update docs/database_contract.md when schema changes.
* Update docs/roadmap.md when phases complete.
* Never create new doc files outside docs/.

---

## Flutter Rules

* flutter analyze must pass before commit
* No dead routes
* No invisible failures
* No silent catches without logs
* All loading/error states required
* Mobile responsiveness required

---

## UI Rules

* No placeholder buttons
* No fake actions
* No hidden broken flows
* Use graceful “Coming Soon” states only when approved
* Keep UI operational, not decorative

---

## Operational Rules

* Admin flows require permission checks
* All destructive actions should be auditable
* Notifications should fail gracefully
* Project lifecycle must be explicit
* Booking lifecycle must be explicit

---

## Development Workflow

1. Inspect schema first
2. Inspect RLS second
3. Update models third
4. Update repositories fourth
5. Update UI last

Never reverse this order.

---

## Testing Rules

* Update RC2 test matrix after fixes
* Verify on real device before phase completion
* Do not begin next phase until current phase stabilized

---

## Security Rules

* Never commit PATs or secrets
* MCPs should default to read-only
* No unrestricted admin access
* Principle of least privilege

---

## Anti-Drift Rules

* Do not invent fields
* Do not invent statuses
* Do not invent tables
* Do not invent relationships
* Inspect actual database first
