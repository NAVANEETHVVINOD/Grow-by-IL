# RC5 Manual QA Report

**Date:** YYYY-MM-DD
**Device/Emulator:** [e.g., Pixel 6 Emulator, iPhone 13 Physical]
**Tester:** [Your Name]

## Pass 1 — Happy Path (Normal Usage)
- [ ] Login with Google
- [ ] Complete onboarding flow
- [ ] Edit Profile (Skills, Interests, Education, Social Links, Privacy)
- [ ] Navigate to Home
- [ ] Navigate to Akathalam
- [ ] Logout and Login successfully

**Findings / Notes:**
- *Add screenshots or notes here*

## Pass 2 — Break It Intentionally (Stress Test)
- [ ] Back button spam during transitions
- [ ] Force close app mid-onboarding and verify resume
- [ ] Turn on airplane mode during profile save
- [ ] Restart app repeatedly
- [ ] Rotate screen orientation
- [ ] Open profile while loading
- [ ] Rapid profile tab switching
- [ ] Rapid scrolling (check for dropped frames/lag)
- [ ] Deep link intercepts (try linking to `/home` while onboarding is incomplete)

**Findings / Notes:**
- *Add any overflow bugs, crashes, or jitter here*

## Pass 3 — RC4 Regression (Legacy Flows)
- [ ] Create a booking
- [ ] View notifications
- [ ] Realtime state checks
- [ ] Admin approval flow
- [ ] Lab check-in
- [ ] View events

**Findings / Notes:**
- *Ensure old features didn't break*

---
**Final QA Verdict:** [PASS / FAIL]
**Blockers for Merge:** None so far.
