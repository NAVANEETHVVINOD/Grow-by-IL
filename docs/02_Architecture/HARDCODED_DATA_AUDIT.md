# Hardcoded Data Audit

Status: Initial static-code inventory. This report distinguishes stable code constants from mutable institutional and user data. It does not authorize a blanket replacement of every literal with a remote setting.

## Classification Rules

| Class | Treatment |
| --- | --- |
| True constant | Keep named in code when it expresses technical behavior or a stable design token. |
| Configuration | Read from environment/build configuration, never source secrets. |
| Master data | Manage through approved backend/admin data after the related schema gate. |
| User data | Read from authenticated user/profile data. |
| Backend data | Access only through an approved repository/API contract. |
| Security policy | Define and enforce server-side; do not use client strings as authority. |
| Test fixture | Keep in test-only files or clearly labelled preview data. |
| Temporary/mock | Remove from production paths only after the real contract and tests exist. |

## High-Priority Findings

| Evidence | Class | Risk | Required disposition |
| --- | --- | --- | --- |
| lib/features/work_requests/services/mock_work_request_data_source.dart seeds named people, external avatar URLs, request titles, dates, statuses, and mock IDs. | Temporary/mock and user-like fixture data | Preview data can be mistaken for real operational data. | Keep only behind an explicit local-preview/test boundary until the approved Work Request backend contract exists. Do not move sample people into production master data. |
| lib/features/work_requests/presentation/widgets/confirmation_step_view.dart says a local mock request was created and refers to future routing. | Temporary/mock user-facing text | The UI can overstate persistence or operational workflow. | Keep local-preview language explicit until backend delivery; replace only with approved real workflow wording. |
| lib/features/work_requests/constants/work_request_options.dart contains request options and categories. | Candidate master data and validated UI options | Values may drift from future lab services or machine capabilities. | Treat the current list as local-flow options. Move to backend master data only after Work Request requirements and schema approval. |
| lib/core/constants/app_roles.dart fixes student, lab_admin, and super_admin in a Flutter enum. | Security policy compatibility code | It conflicts with the approved target account types and cannot represent positions. | Do not add Head values. Replace only through the approved account-type migration and authorization refactor. |
| lib/core/constants/app_defaults.dart supplies Maker, profile defaults, role, XP, level, and reputation values. | Mixed: true defaults plus user data policy | The fallback display name and gamification defaults are product decisions. | Keep technical defaults named; review user-facing fallback and gamification policy before production rollout. |
| lib/core/theme/rc5_design_tokens.dart, neo_button.dart, and neo_card.dart contain color, geometry, motion, and typography values. | True design constants | Uncoordinated values cause visual drift, but moving them to the database would harm reliability. | Keep centralized in the design system; synchronize approved values with Figma tokens. |
| Supabase table and bucket names in repositories and media services. | Backend contract | Scattered string literals make contract changes error-prone. | Centralize only where duplication creates a real maintenance risk; table names do not belong in user-editable master data. |
| Profile and auth logs in lib/features/auth/data/auth_repository.dart include email/user identifiers in diagnostic strings. | Security/privacy logging | Identifiers can leak into device or CI logs. | Security review and redact/minimize before release; do not print raw identifiers in new logs. |

## Known Data Boundaries

- Current people, Core Team assignments, faculty assignments, labs, machines, pricing, services, inventory quantities, and event data are mutable institutional data. They must not be introduced as Flutter constants.
- Position names and their current occupancy are future master data, not enum values or database capacity constraints.
- Account type and authorization policy are server-enforced security policy, not client-only UI state.
- Mock request content is not an approved seed dataset.

## Audit Method And Next Pass

This pass inspected the current role constants, auth defaults, profile/auth repositories, Work Request local data source, design primitives, and database migration references. The next pass must enumerate remaining literals by feature and classify them before a migration or cleanup PR is proposed.

Do not delete a literal merely because it is hardcoded. First identify whether it is a stable implementation constant, an approved product rule, test data, or mutable operational data.

