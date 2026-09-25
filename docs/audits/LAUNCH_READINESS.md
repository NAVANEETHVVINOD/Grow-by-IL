# Launch readiness audit

Status: open. Evidence checked 16 September 2026 against the RC5 source and
live GitHub PR/rules status. Passing CI currently proves only a subset of
these gates. Complete and recheck each item at a specific commit before launch.

| Gate | Current evidence | Required result |
| --- | --- | --- |
| Real configuration and signed release | Release Gradle config uses debug signing; release CI accepts placeholder Supabase values and does not create Firebase config. | Release fails without real protected configuration and a separately controlled signing key; inspect the signed artifact. |
| Work Requests | Default source builds `MockWorkRequestDataSource` with seeded local people and requests. | Approved persistent implementation with authorization, or disable submission and mark the feature unavailable until it exists. |
| Real lab information | Home announcement/opportunities, Wi-Fi/power status, profile verification and badges include fixed facts. | Admin-managed content or honest empty states; never claim a status or badge without evidence. |
| QR and presence | Web QR scanner has a demo user fallback; manual-first policy differs from older copy. | Remove production simulation; test manual check-in/out and after-hours head rule. |
| Roles and data | RLS, role assignment, profile visibility, and payment approval need live adversarial verification. | Test member, each head, and super admin against the same backend policies; log and close findings. |
| Payments and capacity | Manual UPI/refund flows and atomic paid-seat confirmation are not proven. | Verify oversubscription races, duplicate UTRs, refunds, cancellations, and event/non-event role separation. |
| E2E | `integration_test` currently exercises mocked profile sync, not full Android journeys. | Device + real backend tests for signup/onboarding, lab entry, booking, projects, event capacity, payment approval, and offline recovery. |
| Scale and recovery | No 4,000-member load/backups/restore evidence. | Set measurable load targets, run realistic concurrency tests, document backups, and practice restore. |
| Privacy | Retention and notices newly approved in principle. | Publish reviewed notices and field inventory; implement retention rules with exceptions for required financial records. |
| GitHub governance | Open human PRs lack independent approval; #44 fails an architecture guard on the merge run. | Exact PR head passes current required checks and review before merge. Never bypass protection to make a release. |

Priority is to stop misleading runtime behavior, secure signing/configuration,
validate authorization and financial state, then complete device E2E and scale
tests. Track each acceptance test against a real commit and environment.
