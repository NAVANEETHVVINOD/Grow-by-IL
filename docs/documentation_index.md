# Documentation Coverage Map & Index

This document provides a comprehensive index and audit log of all development, design, and release documentation in the Grow~ project repository.

---

## 1. Documentation Index & Status Audit

| Document | Status | Generated from implementation? | Last Updated | Needs Review? |
| :--- | :---: | :---: | :---: | :---: |
| [project_context.md](file:///f:/kannan/projects/Grow/docs/project_context.md) | Active | Yes | May 27, 2026 | No |
| [roadmap.md](file:///f:/kannan/projects/Grow/docs/roadmap.md) | Active | Yes | May 27, 2026 | No |
| [workflow.md](file:///f:/kannan/projects/Grow/docs/workflow.md) | Active | Yes | May 27, 2026 | No |
| [agents.md](file:///f:/kannan/projects/Grow/docs/agents.md) | Active | Yes | May 27, 2026 | No |
| [IdeaLab_AI_IDE_Tasks.md](file:///f:/kannan/projects/Grow/docs/IdeaLab_AI_IDE_Tasks.md) | Active | Yes | May 27, 2026 | No |
| [stabilization_error_log.md](file:///f:/kannan/projects/Grow/docs/stabilization_error_log.md) | Active | Yes | May 27, 2026 | No |
| [rc1-release.md](file:///f:/kannan/projects/Grow/docs/rc1-release.md) | Historical | Yes | Historical | No |
| [rc2-operations-architecture.md](file:///f:/kannan/projects/Grow/docs/rc2-operations-architecture.md) | Historical | Yes | Historical | No |
| [rc2-test-matrix.md](file:///f:/kannan/projects/Grow/docs/rc2-test-matrix.md) | Historical | Yes | Historical | No |
| [rc2-verified-issues.md](file:///f:/kannan/projects/Grow/docs/rc2-verified-issues.md) | Historical | Yes | Historical | No |
| [rc3-auth-stabilization.md](file:///f:/kannan/projects/Grow/docs/rc3-auth-stabilization.md) | Historical | Yes | Historical | No |
| [rc4-production-hardening.md](file:///f:/kannan/projects/Grow/docs/rc4-production-hardening.md) | Historical | Yes | Historical | No |
| [rc44_validation_report.md](file:///f:/kannan/projects/Grow/docs/rc44_validation_report.md) | Historical | Yes | Historical | No |
| [rc5_manual_qa_report.md](file:///f:/kannan/projects/Grow/docs/rc5_manual_qa_report.md) | Active | Yes | May 27, 2026 | No |
| **Architecture Docs** | | | | |
| [feature_flags.md](file:///f:/kannan/projects/Grow/docs/architecture/feature_flags.md) | Active | Yes | May 27, 2026 | No |
| [media_upload_state_machine.md](file:///f:/kannan/projects/Grow/docs/architecture/media_upload_state_machine.md) | Active | Yes | May 27, 2026 | No |
| [offline_sync.md](file:///f:/kannan/projects/Grow/docs/architecture/offline_sync.md) | Active | Yes | May 27, 2026 | No |
| [product_architecture.md](file:///f:/kannan/projects/Grow/docs/architecture/product_architecture.md) | Active | Yes | May 27, 2026 | No |
| [provider_graph.md](file:///f:/kannan/projects/Grow/docs/architecture/provider_graph.md) | Active | Yes | May 27, 2026 | No |
| [rc5_design_system.md](file:///f:/kannan/projects/Grow/docs/architecture/rc5_design_system.md) | Active | Yes | May 27, 2026 | No |
| [sqlite_schema_rfc.md](file:///f:/kannan/projects/Grow/docs/architecture/sqlite_schema_rfc.md) | Active | Yes | May 27, 2026 | No |
| [system_architecture.md](file:///f:/kannan/projects/Grow/docs/architecture/system_architecture.md) | Active | Yes | May 27, 2026 | No |
| **Contracts** | | | | |
| [api_contracts.md](file:///f:/kannan/projects/Grow/docs/contracts/api_contracts.md) | Active | Yes | May 27, 2026 | No |
| **Database** | | | | |
| [database_schema.md](file:///f:/kannan/projects/Grow/docs/database/database_schema.md) | Active | Yes | May 27, 2026 | No |
| **Security** | | | | |
| [security_policy.md](file:///f:/kannan/projects/Grow/docs/security/security_policy.md) | Active | Yes | May 27, 2026 | No |
| **Storage** | | | | |
| [storage_architecture.md](file:///f:/kannan/projects/Grow/docs/storage/storage_architecture.md) | Active | Yes | May 27, 2026 | No |
| **DevOps** | | | | |
| [ci_pipeline_map.md](devops/ci_pipeline_map.md) | Active | Yes | May 27, 2026 | No |
| [git_strategy.md](devops/git_strategy.md) | Active | Yes | May 27, 2026 | No |
| **Releases** | | | | |
| [rc5_beta_manifest.md](releases/rc5_beta_manifest.md) | Active | Yes | May 27, 2026 | No |
| **Testing** | | | | |
| [test_inventory.md](testing/test_inventory.md) | Active | Yes | May 27, 2026 | No |

---

## 2. Documentation Governance Policies

To ensure that documentation does not drift from the actual implementation, the following policies apply:
1. **Accompanying PRs**: Any change to application behavior (e.g. adding offline queues, changes to models) must include a corresponding update to the respective design/contract document within the same PR.
2. **Post-Release Auditing**: During each Release Candidate review, the documentation map must be checked and updated with status, versioning, and verification results.
3. **Historical Document Retention**: Documents specific to old releases (e.g. `rc1`, `rc2`) are retained under the `Historical` status for developmental traceability and audit trails.
