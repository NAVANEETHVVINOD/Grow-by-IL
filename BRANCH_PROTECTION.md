# Grow~ Branch Protection

## Required Repository Settings

Configure these in GitHub repository settings for `main`.

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

## Required Status Checks

The following checks from `.github/workflows/ci.yml` should be required:

- `Quality Gate`
- `Debug APK Build`

## Recommended Release Rule

Release builds should run from version tags (`v*`) or release branches only.

## Notes

Branch protection cannot be fully enforced by a committed file alone. A repository
admin must enable these rules in GitHub settings.
