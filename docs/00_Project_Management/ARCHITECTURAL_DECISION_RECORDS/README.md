# Architectural Decision Records

**Status: Superseded as the authoritative ADR record.** The canonical,
git-tracked ADR index is `/ARCHITECTURE_DECISIONS.md` at the repo root — it is
visible to every contributor, while this folder lives under the local-only
`docs/` tree. This folder is retained for the extended Context/Alternatives/
Consequences detail behind ADR-0002, ADR-0003, and ADR-0004, which the root
file references. If this folder and the root file ever disagree, the root
file wins. Record new decisions in the root file first.

ADRs explain why major architectural decisions were made.

## ADR Rules

- Use the template in `ADR_TEMPLATE.md`.
- One ADR per important decision.
- Keep ADRs concise but explicit.
- Link decisions back to `../PROJECT_DECISIONS.md`.
- Do not rewrite history. If a decision changes, create a new ADR that supersedes
  the old one.

## Current ADRs

- `ADR-0001-platform-scope.md`
- `ADR-0002-work-requests.md`
- `ADR-0003-manufacturing-tasks.md`
- `ADR-0004-assets-inventory-separation.md`
