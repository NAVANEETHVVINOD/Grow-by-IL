# Grow Platform Documentation Debt Report

Status: Approved  
Owner: Lead Architect  
Version: 1.0  
Last updated: 2026-08-04  
Depends on: `docs/DOCUMENTATION_GOVERNANCE.md`  

---

## 1. Executive Summary

This report catalogues all identified documentation debt across the repository, classifying every issue by type, impact, affected files, and target resolution.

---

## 2. Identified Debt Inventory

### A. Duplicate Documents (Identical / Near-Identical Content)

| ID | File A | File B | Status | Resolution |
| --- | --- | --- | --- | --- |
| DD-001 | `docs/01_Product/00_PRODUCT_CHARTER.md` | `docs/01_Product/approved/00_PRODUCT_CHARTER_v1.0.md` | **Confirmed Hash Match** | Delete `approved/` copy |
| DD-002 | `docs/rc44_validation_report.md` | `docs/release/rc44_validation_report.md` | **Hash Mismatch (Different content)** | Keep both; archive root copy |
| DD-003 | `docs/workflow.md` | `docs/workflow/git_policy.md` vs `/DEV_WORKFLOW.md` | Overlapping content | Move `workflow.md` to `archive/superseded/` |
| DD-004 | `docs/devops/git_strategy.md` | `docs/workflow/git_policy.md` vs `/DEV_WORKFLOW.md` | Overlapping content | Merge `git_policy.md` into `git_strategy.md`; point to `/DEV_WORKFLOW.md` |
| DD-005 | `docs/devops/branch_protection.json` | `/BRANCH_PROTECTION.md` | Overlapping concept | Keep JSON spec; point to `/BRANCH_PROTECTION.md` |
| DD-006 | `docs/security/security_policy.md` | `/SECURITY.md` | Overlapping concept | Add pointer to root `/SECURITY.md` |

### B. Outdated / Superseded Documents

| ID | File | Reason | Resolution |
| --- | --- | --- | --- |
| OD-001 | `docs/roadmap.md` | Replaced by `docs/00_Project_Management/PRODUCT_BACKLOG.md` | Move to `archive/superseded/` |
| OD-002 | `docs/project_context.md` | Replaced by `docs/01_Product/` suite | Move to `archive/superseded/` |
| OD-003 | `docs/IdeaLab_AI_IDE_Tasks.md` | Historical session scratch notes | Move to `archive/superseded/` |
| OD-004 | `docs/agents.md` | Historical session scratch notes | Move to `archive/superseded/` |
| OD-005 | `docs/rls_policies_backup_may26.json` | Historical SQL/JSON backup | Move to `archive/superseded/` |
| OD-006 | `docs/rc1-release.md` through `rc4-production-hardening.md` | Historical RC logs | Move to `archive/rc-history/` |
| OD-007 | `docs/stabilization_error_log.md` | Historical RC4 log | Move to `archive/rc-history/` |
| OD-008 | `docs/rc5_manual_qa_report.md` | Historical RC5 log | Move to `archive/rc-history/` |

### C. Missing Core Documents

| ID | Document | Category | Status | Target Resolution |
| --- | --- | --- | --- | --- |
| MD-001 | `REPOSITORY_ARCHITECTURE.md` | `02_Architecture` | Missing | Create in WP3 |
| MD-002 | `MODULE_LIFECYCLE.md` | `02_Architecture` | Missing | Create in WP3 |
| MD-003 | `MODULE_DEPENDENCY_GRAPH.md` | `02_Architecture` | Missing | Create in WP3 |
| MD-004 | `FEATURE_MODULE_TEMPLATE.md` | `02_Architecture` | Missing | Create in WP3 |
| MD-005 | `AI_DEVELOPMENT_GUIDE.md` | Root | Missing | Create in WP3 |
| MD-006 | `FEATURE_INVENTORY.md` | `00_Project_Management` | Missing | Create in WP4 |
| MD-007 | `TECHNICAL_DEBT_REGISTER.md` | `00_Project_Management` | Missing | Create in WP4 |
| MD-008 | `API_READINESS_MATRIX.md` | `00_Project_Management` | Missing | Create in WP4 |

### D. Formatting & Governance Gaps

| ID | Gap | Impact | Remediation |
| --- | --- | --- | --- |
| FG-001 | Frontmatter missing on 90%+ of legacy docs | Inconsistent version/ownership tracking | Add frontmatter header during reorg |
| FG-002 | `docs/documentation_index.md` references non-existent or moved paths | Broken navigation | Rewrite in WP6 |
| FG-003 | `docs/00_Project_Management/MASTER_INDEX.md` missing recent docs | Stale master index | Rewrite in WP6 |
