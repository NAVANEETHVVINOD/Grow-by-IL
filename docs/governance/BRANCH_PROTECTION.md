# Grow~ Branch Protection

## Required Repository Settings

Configure these in GitHub repository settings for `main`.

During RC5, also protect `rc5-release-candidate` if it remains the active
release-candidate integration branch.

## Main Branch

- Require pull request before merging.
- Require at least one approval.
- Dismiss stale approvals when new commits are pushed.
- Require status checks to pass before merging.
- Require branches to be up to date before merging.
- Require conversation resolution before merging.
- Block force pushes.
- Block deletions.
- Restrict direct pushes.

## Review Rule

The live `main` and `rc5-release-candidate` rules require one approval, dismiss
stale reviews, require up-to-date checks, and enforce rules for administrators.
Do not bypass review or merge a PR whose required checks do not match the
configured check names. Recheck GitHub rules before each merge.

## RC Branch

If `rc5-release-candidate` is used as the active integration/release-candidate
branch, apply the same protections as `main`:

- Require pull request before merging.
- Require an independent approval under the live branch rule.
- Require status checks to pass before merging.
- Block force pushes.
- Block deletions.
- Restrict direct pushes.

## Required Status Checks

Required check names must match the workflow running for the PR's base branch.
The two branches currently use different CI workflows:

| PR base | Required checks |
| --- | --- |
| `main` | `Quality Gate (CI)`, `Android Production Build` |
| `rc5-release-candidate` | `Quality Gate`, `Debug APK Build` |

The live `main` rule requires the first pair with strict up-to-date checks.
`Release APK Build` and `GitHub Release` are release jobs, not PR merge checks.
Re-read the live rules and the exact-head CI run before each merge; do not
weaken a rule to make a stale or missing check appear green.

## Recommended Release Rule

Release builds should run from version tags (`v*`) or release branches only.

## Dependabot Rule

Scheduled Dependabot version updates are disabled. Manually proposed dependency
updates require CI plus human review. Keep security alerting enabled.

## Current Exceptions

The direct commits `372d116` and `11ab748` are accepted as historical exceptions
that predate this clarified branch policy. Do not rewrite shared history to
remove them.

## Notes

Branch protection cannot be fully enforced by a committed file alone. A repository
admin must enable these rules in GitHub settings.
