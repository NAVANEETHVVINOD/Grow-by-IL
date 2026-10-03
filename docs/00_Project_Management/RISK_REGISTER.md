# Grow Platform Risk Register

Last updated: 2026-07-29

| ID | Risk | Probability | Impact | Severity | Mitigation | Owner | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| R-001 | Architecture drift from continued coding before blueprint approval | High | High | Critical | Phase gates; no implementation until approved architecture | Technical Program Manager | Active |
| R-002 | Scope creep from combining community app, ERP, manufacturing, inventory, and alumni goals | High | High | Critical | Separate MVP, V1, V2, and Future scope in every document | Product Architect | Active |
| R-003 | Database redesign if Work Requests are modeled as simple orders | Medium | High | High | Use Work Request + Task architecture from the start | Database Architect | Mitigated in charter |
| R-004 | Inventory model becomes unusable if consumables, borrowables, and assets are mixed | Medium | High | High | Separate inventory classes and movement records | Database Architect | Mitigated in charter |
| R-005 | Supabase storage cost/limits from large CAD/design uploads | Medium | Medium | Medium | Prefer external Drive/GitHub/URL links for large files | Backend Architect | Active |
| R-006 | Role complexity slows MVP delivery | Medium | Medium | Medium | Use common dashboard plus role widgets; refine permissions later | Product Architect | Active |
| R-007 | Audit/compliance gaps if operational changes are overwritten without history | Medium | High | High | Add append-only audit logs and inventory movement history | Solution Architect | Active |
| R-008 | External customer portal expands scope too early | Medium | Medium | Medium | Keep external flow outside app and defer public website module | Product Manager | Active |
| R-009 | Reports become unreliable if master data is free-text | Medium | Medium | Medium | Use configurable master data for departments/labs/categories | Data Architect | Active |
| R-010 | Payment disputes if UPI records are informal | Medium | Medium | Medium | Store payment reference, optional proof, verifier, status, and audit trail | Operation Head | Active |

## Review Cadence

Review risks at every phase gate and before implementation starts.
