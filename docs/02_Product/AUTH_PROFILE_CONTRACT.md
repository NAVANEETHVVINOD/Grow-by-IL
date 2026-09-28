# Auth and initial profile contract

This document describes the implemented mobile flow, not a claim that live
configuration or device end-to-end tests have passed.

## Account states

1. Signup collects name, email, and password. The email-confirmation step must
   complete before an email/password sign-in can create an application session.
2. An email confirmation callback displays success or failure and returns the
   member to sign-in. It does not grant access to Home on its own. Expired or
   already-used links do not establish a Grow session.
3. A signed-in member whose `public.users.profile_completed` is not `true`
   sees profile setup. A missing or unreadable profile must not be treated as
   complete.
4. Profile setup edits only `name`, optional `phone`, optional `college_roll`,
   and `profile_completed`. Completion is verified from the database before
   navigation to Home.

## Data ownership

The client may provide `id`, `name`, `email`, optional `phone`, optional
`college_roll`, and `qr_code_data` when creating its own profile row. Database
defaults and trusted administrative paths own account role and progress fields.
The client does not submit those fields at signup or offer self-service role
selection. The deployed role vocabulary remains unchanged by this flow.

Profile expansion (bio, skills, interests, education, projects, and badges)
requires an approved persistence, visibility, validation, and authorization
contract before the UI may claim that those values were saved.

## Release verification

- Confirm-email enabled and the mobile callback allow-listed in the target
  Supabase project.
- Fresh signup, newest confirmation link, sign-in, profile setup, and Home
  verified on a real Android device without logging credentials or links.
- Expired/used confirmation and password-recovery links cannot bypass sign-in.
- Google provider configured in the target environment, then tested separately
  with the Android OAuth client and its signing certificate fingerprint.
- Analyze, automated tests, CI, and target-environment database permissions
  verified against the exact release commit.
