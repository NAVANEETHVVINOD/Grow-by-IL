# Grow Platform Documentation Navigation Index

**Status: Superseded.** This file duplicated
`docs/00_Project_Management/MASTER_INDEX.md`'s purpose as the platform's
navigation index. `MASTER_INDEX.md` is now the canonical index — it is the
actively maintained one. This file is retained for its Root Governance
Documents section and archive map (not yet folded into MASTER_INDEX.md) but
should not be treated as authoritative, and should not be updated going
forward.

Owner: Lead Architect  
Version: 2.0  
Last updated: 2026-08-04  
Depends on: `docs/DOCUMENTATION_GOVERNANCE.md`  

---

## 1. Overview

This index is the primary navigation map for all technical, product, architectural, operational, testing, and DevOps documentation across the Grow platform ecosystem.

---

## 2. Root Governance Documents (Repository Root)

These files are intentionally located at the workspace root for auto-detection by GitHub and open-source tooling:

- [`/README.md`](file:///f:/kannan/projects/Grow/grow/README.md) — Public project overview & quickstart
- [`/CONTRIBUTING.md`](file:///f:/kannan/projects/Grow/grow/CONTRIBUTING.md) — Contributor guidelines
- [`/DEV_WORKFLOW.md`](file:///f:/kannan/projects/Grow/grow/DEV_WORKFLOW.md) — PR-first workflow rules
- [`/CODING_STANDARD.md`](file:///f:/kannan/projects/Grow/grow/CODING_STANDARD.md) — Dart/Flutter coding standards
- [`/SYSTEM_BOUNDARIES.md`](file:///f:/kannan/projects/Grow/grow/SYSTEM_BOUNDARIES.md) — Platform scope & system boundaries
- [`/DEFINITION_OF_DONE.md`](file:///f:/kannan/projects/Grow/grow/DEFINITION_OF_DONE.md) — Quality completion checklist
- [`/BRANCH_PROTECTION.md`](file:///f:/kannan/projects/Grow/grow/BRANCH_PROTECTION.md) — Trunk protection & merge rules
- [`/SECURITY.md`](file:///f:/kannan/projects/Grow/grow/SECURITY.md) — Vulnerability reporting policy
- [`/ARCHITECTURE_DECISIONS.md`](file:///f:/kannan/projects/Grow/grow/ARCHITECTURE_DECISIONS.md) — High-level ADR index

---

## 3. Platform Documentation Map

### 00_Project_Management
- [`MASTER_INDEX.md`](file:///f:/kannan/projects/Grow/grow/docs/00_Project_Management/MASTER_INDEX.md) — Complete master catalog
- [`APPROVAL_LOG.md`](file:///f:/kannan/projects/Grow/grow/docs/00_Project_Management/APPROVAL_LOG.md) — Formal phase approval log
- [`FEATURE_INVENTORY.md`](file:///f:/kannan/projects/Grow/grow/docs/00_Project_Management/FEATURE_INVENTORY.md) — Feature status & readiness table
- [`TECHNICAL_DEBT_REGISTER.md`](file:///f:/kannan/projects/Grow/grow/docs/00_Project_Management/TECHNICAL_DEBT_REGISTER.md) — Technical debt log
- [`API_READINESS_MATRIX.md`](file:///f:/kannan/projects/Grow/grow/docs/00_Project_Management/API_READINESS_MATRIX.md) — Backend readiness matrix
- [`PRODUCT_BACKLOG.md`](file:///f:/kannan/projects/Grow/grow/docs/00_Project_Management/PRODUCT_BACKLOG.md) — Backlog & feature priorities
- [`PROJECT_STATUS.md`](file:///f:/kannan/projects/Grow/grow/docs/00_Project_Management/PROJECT_STATUS.md) — Status updates
- [`RISK_REGISTER.md`](file:///f:/kannan/projects/Grow/grow/docs/00_Project_Management/RISK_REGISTER.md) — Risk log & mitigations
- [`ARCHITECTURAL_DECISION_RECORDS/`](file:///f:/kannan/projects/Grow/grow/docs/00_Project_Management/ARCHITECTURAL_DECISION_RECORDS/) — Individual ADR files (ADR-0001 to ADR-0004)

### 01_Product
- [`00_PRODUCT_CHARTER.md`](file:///f:/kannan/projects/Grow/grow/docs/01_Product/00_PRODUCT_CHARTER.md) — Platform mission, vision & charter
- [`01_EXECUTIVE_SUMMARY.md`](file:///f:/kannan/projects/Grow/grow/docs/01_Product/01_EXECUTIVE_SUMMARY.md) — Executive summary
- [`02_PRODUCT_VISION.md`](file:///f:/kannan/projects/Grow/grow/docs/01_Product/02_PRODUCT_VISION.md) — Product vision & principles
- [`03_BUSINESS_REQUIREMENTS.md`](file:///f:/kannan/projects/Grow/grow/docs/01_Product/03_BUSINESS_REQUIREMENTS.md) — Business requirements (BRD)
- [`04_BUSINESS_RULE_MATRIX.md`](file:///f:/kannan/projects/Grow/grow/docs/01_Product/04_BUSINESS_RULE_MATRIX.md) — Consolidated business rule IDs
- [`05_WORK_REQUEST_REQUIREMENTS.md`](file:///f:/kannan/projects/Grow/grow/docs/01_Product/05_WORK_REQUEST_REQUIREMENTS.md) — Work Request SRS
- [`06_WORK_REQUEST_IMPLEMENTATION_CONTRACT.md`](file:///f:/kannan/projects/Grow/grow/docs/01_Product/06_WORK_REQUEST_IMPLEMENTATION_CONTRACT.md) — Work Request implementation contract
- [`BUSINESS_GLOSSARY.md`](file:///f:/kannan/projects/Grow/grow/docs/01_Product/BUSINESS_GLOSSARY.md) — Platform terminology

### 02_Architecture
- [`REPOSITORY_ARCHITECTURE.md`](file:///f:/kannan/projects/Grow/grow/docs/02_Architecture/REPOSITORY_ARCHITECTURE.md) — Repository structure & layer rules
- [`MODULE_LIFECYCLE.md`](file:///f:/kannan/projects/Grow/grow/docs/02_Architecture/MODULE_LIFECYCLE.md) — 9-phase module gate standard
- [`MODULE_DEPENDENCY_GRAPH.md`](file:///f:/kannan/projects/Grow/grow/docs/02_Architecture/MODULE_DEPENDENCY_GRAPH.md) — Feature dependency graph & blockages
- [`FEATURE_MODULE_TEMPLATE.md`](file:///f:/kannan/projects/Grow/grow/docs/02_Architecture/FEATURE_MODULE_TEMPLATE.md) — Feature layout template
- [`system_architecture.md`](file:///f:/kannan/projects/Grow/grow/docs/02_Architecture/system_architecture.md) — High-level system design
- [`product_architecture.md`](file:///f:/kannan/projects/Grow/grow/docs/02_Architecture/product_architecture.md) — Product architecture mapping
- [`feature_flags.md`](file:///f:/kannan/projects/Grow/grow/docs/02_Architecture/feature_flags.md) — Feature flag strategy
- [`offline_sync.md`](file:///f:/kannan/projects/Grow/grow/docs/02_Architecture/offline_sync.md) — Offline sync & replay queue
- [`media_upload_state_machine.md`](file:///f:/kannan/projects/Grow/grow/docs/02_Architecture/media_upload_state_machine.md) — Media upload state machine
- [`provider_graph.md`](file:///f:/kannan/projects/Grow/grow/docs/02_Architecture/provider_graph.md) — Riverpod provider dependency map
- [`rc5_design_system.md`](file:///f:/kannan/projects/Grow/grow/docs/02_Architecture/rc5_design_system.md) — RC5 design tokens & UI standard
- [`../10_Master_Architecture/SYSTEM_BLUEPRINT.md`](file:///f:/kannan/projects/Grow/grow/docs/10_Master_Architecture/SYSTEM_BLUEPRINT.md) — High-level platform architecture blueprint
- [`../10_Master_Architecture/MODULE_DEPENDENCY_GRAPH.md`](file:///f:/kannan/projects/Grow/grow/docs/10_Master_Architecture/MODULE_DEPENDENCY_GRAPH.md) — Cross-module dependency planning
- [`../10_Master_Architecture/DEVELOPMENT_ROADMAP.md`](file:///f:/kannan/projects/Grow/grow/docs/10_Master_Architecture/DEVELOPMENT_ROADMAP.md) — Phase-based implementation roadmap
- [`../10_Master_Architecture/ARCHITECTURE_PRINCIPLES.md`](file:///f:/kannan/projects/Grow/grow/docs/10_Master_Architecture/ARCHITECTURE_PRINCIPLES.md) — Design principles for future expansion

### 03_Database
- [`database_schema.md`](file:///f:/kannan/projects/Grow/grow/docs/03_Database/database_schema.md) — Supabase database schema reference
- [`api_contracts.md`](file:///f:/kannan/projects/Grow/grow/docs/03_Database/api_contracts.md) — API & DTO contracts
- [`WORK_REQUEST_ERD.md`](file:///f:/kannan/projects/Grow/grow/docs/03_Database/WORK_REQUEST_ERD.md) — Work request domain ERD planning
- [`INVENTORY_ERD.md`](file:///f:/kannan/projects/Grow/grow/docs/03_Database/INVENTORY_ERD.md) — Inventory domain ERD planning
- [`BORROWING_ERD.md`](file:///f:/kannan/projects/Grow/grow/docs/03_Database/BORROWING_ERD.md) — Borrowing domain ERD planning
- [`MACHINE_QUEUE_ERD.md`](file:///f:/kannan/projects/Grow/grow/docs/03_Database/MACHINE_QUEUE_ERD.md) — Machine queue domain ERD planning
- [`PAYMENT_ERD.md`](file:///f:/kannan/projects/Grow/grow/docs/03_Database/PAYMENT_ERD.md) — Payment domain ERD planning

### 04_Security
- [`security_policy.md`](file:///f:/kannan/projects/Grow/grow/docs/04_Security/security_policy.md) — Internal security rules (pointer to `/SECURITY.md`)

### 05_DevOps
- [`ci_pipeline_map.md`](file:///f:/kannan/projects/Grow/grow/docs/05_DevOps/ci_pipeline_map.md) — CI pipeline architecture map
- [`git_strategy.md`](file:///f:/kannan/projects/Grow/grow/docs/05_DevOps/git_strategy.md) — Git strategy (pointer to `/DEV_WORKFLOW.md`)
- [`git_policy.md`](file:///f:/kannan/projects/Grow/grow/docs/05_DevOps/git_policy.md) — Branch & PR policies
- [`branch_protection.json`](file:///f:/kannan/projects/Grow/grow/docs/05_DevOps/branch_protection.json) — Branch protection rule spec
- [`pr_body.txt`](file:///f:/kannan/projects/Grow/grow/docs/05_DevOps/pr_body.txt) — PR description template

### 06_Testing
- [`test_inventory.md`](file:///f:/kannan/projects/Grow/grow/docs/06_Testing/test_inventory.md) — Unit & widget test inventory
- [`failure_scenarios.md`](file:///f:/kannan/projects/Grow/grow/docs/06_Testing/failure_scenarios.md) — Chaos & offline failure modes
- [`profile_migration_test_matrix.md`](file:///f:/kannan/projects/Grow/grow/docs/06_Testing/profile_migration_test_matrix.md) — Profile sync test matrix

### 07_Release
- [`CHANGELOG.md`](file:///f:/kannan/projects/Grow/grow/docs/07_Release/CHANGELOG.md) — Platform changelog
- [`release_checklist.md`](file:///f:/kannan/projects/Grow/grow/docs/07_Release/release_checklist.md) — Release completion checklist
- [`release_rollback.md`](file:///f:/kannan/projects/Grow/grow/docs/07_Release/release_rollback.md) — Release rollback procedure
- [`performance_baseline.md`](file:///f:/kannan/projects/Grow/grow/docs/07_Release/performance_baseline.md) — Performance baseline
- [`rc44_validation_report.md`](file:///f:/kannan/projects/Grow/grow/docs/07_Release/rc44_validation_report.md) — RC4.4 validation report
- [`BETA_TEST_NOTES.md`](file:///f:/kannan/projects/Grow/grow/docs/07_Release/BETA_TEST_NOTES.md) — Beta tester feedback
- [`rc5_beta_manifest.md`](file:///f:/kannan/projects/Grow/grow/docs/07_Release/rc5_beta_manifest.md) — RC5 beta manifest

### 08_Migrations
- [`profile_migration_phase_a.md`](file:///f:/kannan/projects/Grow/grow/docs/08_Migrations/profile_migration_phase_a.md) — Profile migration phase A
- [`rc5_rollback_protocol.md`](file:///f:/kannan/projects/Grow/grow/docs/08_Migrations/rc5_rollback_protocol.md) — RC5 rollback protocol

### 09_Performance
- [`startup_benchmark.md`](file:///f:/kannan/projects/Grow/grow/docs/09_Performance/startup_benchmark.md) — App startup benchmarks

### General Guides
- [`DOCUMENTATION_GOVERNANCE.md`](file:///f:/kannan/projects/Grow/grow/docs/DOCUMENTATION_GOVERNANCE.md) — Frontmatter, lifecycles, and standards
- [`DOCUMENTATION_DEBT_REPORT.md`](file:///f:/kannan/projects/Grow/grow/docs/DOCUMENTATION_DEBT_REPORT.md) — Debt register for docs
- [`AI_DEVELOPMENT_GUIDE.md`](file:///f:/kannan/projects/Grow/grow/docs/AI_DEVELOPMENT_GUIDE.md) — AI pair programming rules & handoffs
- [`Cleanup_Report.md`](file:///f:/kannan/projects/Grow/grow/docs/Cleanup_Report.md) — Repository cleanup audit
- [`UX_AUDIT.md`](file:///f:/kannan/projects/Grow/grow/docs/UX_AUDIT.md) — Screen-level UX audit
- [`TEST_MATRIX.md`](file:///f:/kannan/projects/Grow/grow/docs/TEST_MATRIX.md) — Feature test coverage matrix
- [`API_SPEC.md`](file:///f:/kannan/projects/Grow/grow/docs/API_SPEC.md) — Phase 2 API planning
- [`PROFILE_REFACTOR_PLAN.md`](file:///f:/kannan/projects/Grow/grow/docs/PROFILE_REFACTOR_PLAN.md) — Large profile screen refactor plan
- [`FEATURE_BLUEPRINTS.md`](file:///f:/kannan/projects/Grow/grow/docs/FEATURE_BLUEPRINTS.md) — Future module design blueprints

---

## 4. Archive Directory Map (`docs/archive/`)

- `archive/rc-history/` — RC1 through RC5 release notes, QA reports, and stabilization logs.
- `archive/superseded/` — Superseded planning docs (`roadmap.md`, `project_context.md`, `workflow.md`, `IdeaLab_AI_IDE_Tasks.md`, `agents.md`, `rls_policies_backup_may26.json`).
