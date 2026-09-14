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

## Solo-Maintainer Review Rule

During solo development, repository administrators may merge their own PRs after
all required CI checks pass and the PR has been reviewed against the checklist in
`.github/PULL_REQUEST_TEMPLATE.md`.

This is not a permanent substitute for independent review. Once a second
maintainer joins the project, at least one independent approval becomes
mandatory for `main` and active release-candidate branches.

## RC Branch

If `rc5-release-candidate` is used as the active integration/release-candidate
branch, apply the same protections as `main`:

- Require pull request before merging.
- Follow the solo-maintainer review rule above until a second maintainer exists.
- Require status checks to pass before merging.
- Block force pushes.
- Block deletions.
- Restrict direct pushes.

## Required Status Checks

The following checks from `.github/workflows/ci.yml` should be required:

- `Quality Gate`
- `Debug APK Build`

## Recommended Release Rule

Release builds should run from version tags (`v*`) or release branches only.

## Dependabot Rule

Do not let Dependabot self-approve and auto-merge Flutter, Android, Firebase,
Supabase, or GitHub Actions updates. Dependency PRs require CI plus human review.

## Current Exceptions

The direct commits `372d116` and `11ab748` are accepted as historical exceptions
that predate this clarified branch policy. Do not rewrite shared history to
remove them.

## Notes

Branch protection cannot be fully enforced by a committed file alone. A repository
admin must enable these rules in GitHub settings.
