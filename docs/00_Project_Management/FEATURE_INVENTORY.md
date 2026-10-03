# Grow Platform Feature Inventory

Status: Approved  
Owner: Product Owner / Lead Architect  
Version: 1.0  
Last updated: 2026-08-04  
Depends on: `docs/01_Product/00_PRODUCT_CHARTER.md`  

---

## 1. Executive Summary

This document maintains an accurate, single-table status inventory of every feature module in the Grow platform, tracking its operational state, database status, UI status, test coverage, feature flags, and dependencies.

---

## 2. Platform Feature Status Inventory

| Module Name | Status | Phase Gate | DB Layer | UI Layer | Test Coverage | Feature Flag | Dependencies | Future Work |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **Authentication** | Stable | Phase 4 (Engineering) | Complete | Complete | ~90% | None | Firebase, Supabase Auth | Google OAuth auto-domain mapping |
| **User Profile** | In Progress | Phase 4 (Engineering) | Partial (Schema drift debt) | Complete | ~80% | None | Auth | Alumni hub, skill endorsements |
| **Work Requests** | Phase 1 Complete | Gate 4 (UI / Local) | Blocked (Architecture guard) | Complete (Fabrication V1) | ~85% | `enableWorkRequests` | Profile, Validators, SharedPreferences | Phase 2 ERD, Manufacturing Task split |
| **Projects** | Stable | Phase 4 (Engineering) | Complete | Complete | ~70% | None | Auth, Storage | Project collaboration tools |
| **Notifications** | Stable | Phase 4 (Engineering) | Complete | Complete | ~60% | None | Auth, Realtime | Push notifications (FCM) |
| **Events & Explore** | Stable | Phase 4 (Engineering) | Complete | Complete | ~50% | None | Auth | Certificate generation, attendance QR |
| **Lab Check-in & Tools** | Stable | Phase 4 (Engineering) | Complete | Complete | ~70% | None | Auth, Overlap Constraint DB | Equipment maintenance logging |
| **Admin Operations** | Stable | Phase 4 (Engineering) | Complete | Complete | ~40% | None | Auth, Super Admin Role | Master data management UI |
| **Akathalam** | Shell | Phase 3 (UX) | None | Shell | 0% | None | None | Full tab consolidation |
| **Home (RC5)** | In Progress | Phase 4 (Engineering) | N/A (Adapter approach) | Complete | ~30% | `enableRc5Theme` | Profile, Quick Actions | Section-level isolation |
| **Manufacturing Tasks** | Not Started | Phase 1B (PRD) | Blocked | Not Started | 0% | Planned | Work Requests | Task assignment, duration estimates |
| **Machine Queue** | Not Started | Phase 1B (PRD) | Blocked | Not Started | 0% | Planned | Manufacturing Tasks | Parallel job management UI |
| **Inventory & Assets** | Not Started | Phase 1B (PRD) | Blocked | Not Started | 0% | Planned | Master Data | CSV/Excel import parser, borrow rules |
| **Quotations & Payments**| Not Started | Phase 1B (PRD) | Blocked | Not Started | 0% | Planned | Work Requests | UPI receipt verification workflow |
| **Visitor Logging** | Not Started | Phase 1B (PRD) | Blocked | Not Started | 0% | Planned | Master Data | Visitor check-in UI & exports |
| **Reports & Analytics** | Not Started | Phase 1B (PRD) | Blocked | Not Started | 0% | Planned | Audit Logs | Excel/PDF operational exports |
