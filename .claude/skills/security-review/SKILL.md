---
name: security-review
description: Use when reviewing a change for secrets handling, auth/session logic, RLS, storage access, logging, or the camera/sensor trust boundary — before flagging or fixing a security concern in this repo.
---

# Security Review

## Canonical sources

- `SECURITY.md` — scope (Flutter app code, Supabase access patterns, RLS,
  auth/session, storage, CI/CD secrets/signing) and reporting contact.
- `docs/04_Security/security_policy.md` — current RLS policies, secrets
  injection model (`--dart-define` only, no hardcoded keys), storage bucket
  rules (file type/size limits on `avatars`).
- `docs/04_Security/TRUST_BOUNDARY.md` — device camera/sensor trust boundary.
  Grow's camera use is QR-decode only (lab check-in/tool booking); the
  decoded string is untrusted input validated server-side. No audio capture,
  no ML inference anywhere in the app — don't assume otherwise even if an
  older planning doc implied a measurement/ML pipeline.
- `.github/workflows/ci.yml` — the actual enforced automated checks: a
  grep-based scan for hardcoded `AIzaSy` keys and `service_role` references
  in `lib/`, plus Gitleaks. Treat either failing as a release blocker.

## Checks to run

1. **Secrets**: no hardcoded API keys, service role keys, keystores, `.env`,
   or `google-services.json` in a diff. All secrets flow through
   `--dart-define` at build time.
2. **RLS**: any new/changed Supabase mutation needs an explicit RLS policy
   review — don't accept "RLS will be added later." No client-side RLS
   bypass.
3. **Logging**: no tokens, payment identifiers, or private profile fields in
   logs, including debug-only logs (they must not create release-mode
   overhead either, per `CODING_STANDARD.md`).
4. **Storage**: new buckets need an access policy review; check file-type
   and size limits are enforced (existing pattern: `avatars` bucket, 2MB,
   image/jpeg|png|webp only).
5. **New public profile fields**: need a privacy review before shipping —
   check whether they're exposed via a `SELECT` policy that's broader than
   intended.
6. **Trust boundary changes**: any feature that would use the camera/mic for
   something beyond QR decode (photo capture, video, document scan) needs an
   approved requirement + architecture decision + security review first,
   per `/SYSTEM_BOUNDARIES.md`'s "Future Boundary Changes" gate.

## Workflow

1. Scope the review to what `SECURITY.md` actually covers — don't flag
   things outside that scope (e.g. general code style) as security findings.
2. For anything touching RLS or storage, cross-check against the concrete
   SQL in `docs/04_Security/security_policy.md`, not general RLS best
   practice — the repo has an established pattern to match.
3. Report findings with which specific rule/doc they violate and the
   concrete exploit/leak scenario, not a generic "this could be a risk."
