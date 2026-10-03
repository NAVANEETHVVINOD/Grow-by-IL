# Grow Platform Documentation Governance

Status: Draft preservation-policy amendment; historical product approvals unchanged  
Owner: Lead Architect / Core Team  
Last updated: 2026-10-03  
Version: 1.1  

---

## 1. Overview & Purpose

This document establishes the official governance rules for all technical, product, architectural, operational, and development documentation in the Grow platform repository.

Documentation in Grow is treated with the same engineering rigor as production Dart code. Misleading, stale, or contradictory documentation creates architectural drift and operational risk.

---

## 2. Document Frontmatter Requirement

Every Markdown file in `docs/` MUST begin with a standardized header block containing metadata:

```markdown
# [Document Title]

Status: [Draft | Pending Review | Approved | Superseded | Archived]
Owner: [Role / Team Name]
Version: [e.g. 1.0]
Last updated: [YYYY-MM-DD]
Depends on: [Link/Reference to parent requirement or ADR]
Referenced by: [Links/References to child docs]
```

### Allowed Status Values
- `Draft`: In progress, under active writing or iteration.
- `Pending Review`: Complete, waiting for formal approval.
- `Approved`: Reviewed, frozen, and authoritative for implementation.
- `Superseded`: Replaced by a newer document (must include pointer to new document).
- `Archived`: Historical record, no longer active.

---

## 3. Directory Naming & Taxonomy

All documents live in dedicated, numbered categories under `docs/`:

```text
docs/
  00_Project_Management/      # Backlogs, risk registers, approval logs, issue tracking
  01_Product/                 # Product charter, BRD, business rules, WR requirements
  02_Architecture/            # System architecture, ADRs, state machines, provider maps
  03_Database/                # Schema design, ERD planning, API contracts, RLS policies
  04_Security/                # Security policies, RLS matrix, threat models
  05_DevOps/                  # CI/CD pipeline maps, PR templates, git strategy
  06_Testing/                 # Failure scenarios, test inventories, test matrices
  07_Release/                 # Changelogs, release checklists, performance baselines
  08_Migrations/              # Schema & data migration rollout protocols
  09_Performance/             # Benchmarks, startup metrics, bundle analysis
  archive/
    rc-history/               # Release candidate historical logs & QA notes
    superseded/               # Obsolete or replaced planning documents
```

---

## 4. Root Governance Files Boundary

The following files are **repository-level governance documents** and MUST remain at the root of the workspace so GitHub, open-source contributors, and tooling can auto-detect them:

- `README.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `LICENSE`
- `CODEOWNERS`
- `DEV_WORKFLOW.md`
- `CODING_STANDARD.md`
- `SYSTEM_BOUNDARIES.md`
- `DEFINITION_OF_DONE.md`
- `BRANCH_PROTECTION.md`
- `ARCHITECTURE_DECISIONS.md`

### Pointer Policy
Documentation within `docs/` MUST NOT duplicate the content of root governance files. Instead, `docs/` files must include a pointer section at the top:

> **Authoritative Version Pointer**: See [`DEV_WORKFLOW.md`](../DEV_WORKFLOW.md) for the root PR workflow; compare its historical instructions with the current baseline and user guidance before acting.

---

## 5. Git-Ignored Retention & Archival Policy

- Reviewed, non-sensitive documentation is versioned by default. Private security evidence, credentials, raw data snapshots and build artifacts remain excluded. See [current baseline](00_Project/CURRENT_PROJECT_BASELINE.md) and [documentation index](README.md).
- Historical documents are retained for provenance; old statuses are not current release evidence. The [delivery board](00_Project/GROW_V1_TASK_BOARD.md) is the single current execution queue.
- A local Git commit is not an off-machine backup. Authorized publication and remote verification are separate completion steps; private evidence requires an owner-approved private backup destination.
- **Never hard-delete a document** unless byte-for-byte identity has been confirmed via file hash comparison (`Get-FileHash` or `sha256sum`).
- Superseded documents must be moved to `docs/archive/superseded/` with a note explaining what document replaced them.
- Release-candidate QA notes, stabilization logs, and release history must be moved to `docs/archive/rc-history/`.

---

## 6. Single Source of Truth Principle

Each operational concept or architecture component has exactly ONE primary document:

| Domain | Primary Source of Truth |
| --- | --- |
| Governance & Workflows | Root governance docs (`DEV_WORKFLOW.md`, `CODING_STANDARD.md`, etc.) |
| Product Intent | `docs/01_Product/00_PRODUCT_CHARTER.md` |
| Business Requirements | `docs/01_Product/03_BUSINESS_REQUIREMENTS.md` |
| Business Rules | `docs/01_Product/04_BUSINESS_RULE_MATRIX.md` |
| Module Implementation | `docs/01_Product/06_WORK_REQUEST_IMPLEMENTATION_CONTRACT.md` (per module) |
| Architecture | `docs/02_Architecture/system_architecture.md` & `REPOSITORY_ARCHITECTURE.md` |
| Current Navigation Index | `docs/README.md`; current execution queue: `docs/00_Project/GROW_V1_TASK_BOARD.md` |
| Historical Navigation Index | `docs/00_Project_Management/MASTER_INDEX.md`; `docs/documentation_index.md` is superseded |
