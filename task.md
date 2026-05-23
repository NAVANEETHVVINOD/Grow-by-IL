# Grow~ Task Tracker

Last updated: 2026-05-23

## Current Status

Current maturity:

- RC4.4: production stabilization complete enough to support RC5 work
- RC5: product redesign started
- Current branch: `rc5-onboarding-v2`

Open PRs:

- [x] PR #34 - RC4.3 production stabilization: merged
- [ ] PR #38 - RC5 UI foundation, navigation shell, and Home redesign: open, mergeable, CI green
- [ ] PR #39 - RC5 onboarding v2 foundation: open, stacked on PR #38

Approximate RC5 completion:

- Foundation/design/navigation: 80%
- Home redesign foundation: 60%
- Onboarding foundation: 55%
- Profile system: 35%
- Schema migrations: 0%
- Opportunities: 0%
- Vouch system: 0%
- Akathalam full merge: 35%
- Admin/content tools: 0%
- Visual QA/device validation: 15%

Overall RC5 progress: about 35-40%.

## Completed

### RC4 Stabilization

- [x] Provider rebuild audit completed
- [x] Home screen rebuild surface reduced
- [x] Notification pagination added
- [x] Notification realtime refresh made safer
- [x] Rebuild diagnostics added
- [x] N+1 event RSVP query fixed
- [x] Dual subscription pattern reduced
- [x] Booking overlap risk identified
- [x] Notification RLS issue identified
- [x] Backend authority SQL prepared
- [x] Release signing configured locally
- [x] Release APK built
- [x] Release AAB built
- [x] Google release OAuth/SHA issue fixed
- [x] Unit/widget tests passing
- [x] Analyzer passing

### RC5 Planning

- [x] Product direction finalized
- [x] 3-tab navigation finalized: Home / Akathalam / Profile
- [x] Public/private profile visibility rules finalized
- [x] Username rules finalized
- [x] Vouch rules finalized
- [x] Opportunity rules finalized
- [x] Event apply rules finalized
- [x] Messaging deferred
- [x] GitHub OAuth deferred
- [x] Push notifications deferred to future FCM work

### RC5 Slice 1 - UI Foundation

- [x] RC5 design tokens added
- [x] RC5 opt-in theme added
- [x] RC5 card component added
- [x] RC5 button component added
- [x] RC5 chip component added
- [x] RC5 avatar component added
- [x] RC5 skeleton component added
- [x] RC5 empty state component added
- [x] RC5 bottom nav component added
- [x] Kerala-inspired Akathalam nav mark added
- [x] Repo hygiene cleanup completed
- [x] Android-unneeded `web/` assets removed from tracked repo
- [x] Old analyzer output removed
- [x] QA XML artifacts removed
- [x] `.gitignore` tightened

### RC5 Slice 2 - Navigation + Home Foundation

- [x] Main shell moved to 3-tab structure
- [x] Akathalam route added
- [x] Akathalam gateway screen added
- [x] Existing Lab, Events, Tools, Projects, Admin, Notifications routes preserved
- [x] RC5 Home screen added
- [x] HomeTopBar added
- [x] LiveStatusStrip added
- [x] QuickActionsGrid added
- [x] UpcomingEventsCarousel added
- [x] OpportunitiesPreview added with temporary visual data
- [x] MentorshipSupportPreview added with temporary visual data
- [x] ActiveProjectsPreview added using existing provider
- [x] KnowledgePreview added with temporary visual data
- [x] Home wired to existing safe providers only
- [x] No schema migration introduced
- [x] `flutter analyze` passing
- [x] `flutter test` passing

### RC5 Slice 3 - Onboarding V2 Foundation

- [x] RC5OnboardingScreen added
- [x] `/profile-setup` wired to RC5 onboarding
- [x] Card-based onboarding shell added
- [x] Progress indicator added
- [x] Draft persistence added with SharedPreferences
- [x] Resume-after-restart support added
- [x] Welcome step added
- [x] Username step added
- [x] Username format validation added
- [x] Reserved username blocking added
- [x] Basic profile step added
- [x] Bio validation added
- [x] Interests step added
- [x] Skills/familiarity dots added
- [x] Role/context step added
- [x] Goals step added
- [x] Profile preview step added
- [x] Completion step added
- [x] Supabase update limited to current safe schema: `profile_completed = true`
- [x] Future profile fields kept local until schema migration
- [x] `flutter analyze` passing
- [x] `flutter test` passing

### RC5 Slice 4 - Public Profile Foundation (UI-First)

- [x] Feature flags added (`enableNewProfile`, `enableAkathalam`, `enableVouches`)
- [x] RC5 adapter profile providers created
- [x] RC5 profile screen created with isolated tab sections
- [x] Profile header with username/bio/department adapter data
- [x] Public vs private visibility boundary copy added in UI
- [x] Lazy tab switching added (Overview, Projects, Experience, Education, Volunteering)
- [x] Public projects tab wired to existing provider adapter
- [x] Public event participation preview wired
- [x] Edit profile hub route linked (`/profile/edit`)
- [x] Router flag-gated new profile rollout (`/profile`)
- [x] Existing sign-out flow preserved from profile
- [x] `flutter analyze` passing
- [x] `flutter test` passing

## Immediate Next Steps

### Merge Queue

- [ ] Review PR #38 visually on device
- [ ] Merge PR #38 into `main`
- [ ] Retarget PR #39 from `rc5-foundation-ui-system` to `main`
- [ ] Wait for PR #39 CI
- [ ] Review onboarding on device
- [ ] Merge PR #39

### Device Validation Needed

- [ ] Fresh install
- [ ] Google sign-in
- [ ] New user routes to RC5 onboarding
- [ ] Existing completed user routes to Home
- [ ] Onboarding draft resumes after app restart
- [ ] Username validation blocks invalid names
- [ ] Bio validation blocks too-short bio
- [ ] Exactly 5 interests required
- [ ] Completion sets profile completed
- [ ] Home loads after onboarding
- [ ] Existing booking flow still works
- [ ] Existing admin flow still works

## Upcoming RC5 Phases

### Phase 4 - RC5 Schema Migration

Status: not started

- [ ] Inspect live production schema
- [ ] Create migration for username fields
- [ ] Create onboarding fields
- [ ] Create profile visibility fields
- [ ] Create user interests table
- [ ] Create user skills table
- [ ] Create user education table
- [ ] Create user experience table
- [ ] Create user volunteering table
- [ ] Create user social links table
- [ ] Create RLS policies
- [ ] Create indexes
- [ ] Add rollback comments
- [ ] Add DB tests
- [ ] Backfill usernames for existing users
- [ ] Update UserModel safely
- [ ] Replace local onboarding draft fields with DB persistence

### Phase 5 - Public Profile Foundation

Status: in progress

- [x] New RC5 profile header
- [x] Public profile view foundation
- [x] Profile tabs shell
- [x] Profile activity privacy rules (UI boundary)
- [x] Projects tab
- [x] Experience tab placeholder
- [x] Education timeline placeholder
- [x] Volunteering tab placeholder
- [x] Skills/interests display
- [x] Edit profile hub
- [ ] Basic profile edit page
- [ ] Portfolio public/private toggle
- [ ] Social links display
- [ ] Share profile action
- [x] Settings page foundation (bottom sheet)

### Phase 6 - Home Full Data Wiring

Status: partially started

- [x] Home visual foundation
- [x] Existing provider adapters started
- [ ] Real schedule provider
- [ ] Real opportunities provider
- [ ] Real mentorship/support provider
- [ ] Real knowledge preview provider
- [ ] Event poster fallback refinement
- [ ] Home visual QA on physical device
- [ ] Scroll performance profiling
- [ ] Rebuild count inspection

### Phase 7 - Akathalam Full Merge

Status: partially started

- [x] Akathalam gateway screen
- [x] Lab status placeholder chips
- [x] Check-in entry
- [x] Tool booking entry
- [x] Events entry
- [ ] Real lab status table
- [ ] Lab admin status update UI
- [ ] Electricity/Wi-Fi realtime provider
- [ ] Today's events section
- [ ] Past events archive
- [ ] Machine/facility booking redesign
- [ ] Event detail RC5 redesign
- [ ] Swipe-to-apply flow
- [ ] Event application status UI

### Phase 8 - Opportunities

Status: not started

- [ ] Opportunity schema
- [ ] Opportunity RLS
- [ ] Opportunity repository
- [ ] Opportunity providers
- [ ] Home opportunities wiring
- [ ] Opportunity detail page
- [ ] External apply link
- [ ] Share button
- [ ] Admin create/edit opportunity UI
- [ ] Expiry/grace period logic

### Phase 9 - Mentorship & Support

Status: not started

- [ ] Request support schema
- [ ] Request categories
- [ ] User request form
- [ ] Admin review flow
- [ ] Home preview wiring
- [ ] Notifications for request updates

### Phase 10 - Knowledge Base

Status: not started

- [ ] Knowledge article schema review
- [ ] Article create flow
- [ ] Admin approval flow
- [ ] Home preview wiring
- [ ] Article detail page
- [ ] Empty states
- [ ] Search hooks

### Phase 11 - Vouch System

Status: not started

- [ ] Vouch schema
- [ ] Max 10 active vouches constraint
- [ ] One vouch per pair constraint
- [ ] No self-vouch enforcement
- [ ] Soft-remove support
- [ ] 90-day revouch cooldown
- [ ] Vouch notification
- [ ] Profile vouch count display
- [ ] Admin abuse removal flow

### Phase 12 - Admin RC5

Status: not started

- [ ] Admin lab status controls
- [ ] Event application approval
- [ ] Opportunity approval/management
- [ ] Knowledge approval
- [ ] Vouch moderation
- [ ] User moderation hooks
- [ ] Audit log planning

### Phase 13 - Visual QA and Performance

Status: not started

- [ ] Screenshot pass for Home
- [ ] Screenshot pass for Akathalam
- [ ] Screenshot pass for Onboarding
- [ ] Mobile overflow audit
- [ ] Low-end device scroll test
- [ ] Provider rebuild log review
- [ ] Active stream count review
- [ ] Profile mode performance test
- [ ] Release APK visual smoke test

### Phase 14 - Release Readiness

Status: partially complete

- [x] Release signing configured
- [x] Release APK build verified previously
- [x] Release AAB build verified previously
- [ ] Rebuild release APK after RC5 merge
- [ ] Rebuild release AAB after RC5 merge
- [ ] Internal testing track upload
- [ ] Crashlytics verification
- [ ] Supabase backup before migrations
- [ ] Schema baseline after RC5 migrations
- [ ] Release notes

## Not In RC5

- [ ] Direct messaging
- [ ] Live chat
- [ ] GitHub OAuth sync
- [ ] Firebase Cloud Messaging push notifications
- [ ] Public web profiles
- [ ] AI recommendations
- [ ] Multi-lab federation
- [ ] Marketplace
- [ ] Advanced analytics dashboard

## Recommended Order From Here

1. Merge PR #38.
2. Retarget and merge PR #39.
3. Device-test RC5 Home and onboarding.
4. Device-test RC5 profile foundation.
5. Start RC5 schema migration PR.
6. Wire Home previews to real backend data.
7. Expand Akathalam/event apply flow.
8. Add opportunities.
9. Add mentorship/support.
10. Add vouch system.

## Risk Notes

- Do not add new backend features until PR #38 and PR #39 are merged and tested.
- Do not store GitHub tokens in Flutter.
- Do not make detailed activity history public.
- Do not introduce direct messaging in RC5.
- Do not turn Home into an unbounded feed.
- Keep all preview sections capped and lazy where possible.
