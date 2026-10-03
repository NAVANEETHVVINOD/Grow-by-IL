# Grow~ RC5 Product Architecture

Grow~ RC5 evolves the app from a lab utility into a maker community platform for IDEA Lab operations, student identity, events, opportunities, mentorship, projects, and knowledge sharing.

---

## 1. Bottom Navigation Shell

The bottom navigation has three destinations only:
- **Home**: The personalized dashboard.
- **അകത്തളം (Akathalam)**: The living lab, events, and realtime community space.
- **Profile**: The public maker identity and portfolio.

---

## 2. Core Screen Specifications

### 2.1 Home Dashboard
Home is a contextual dashboard with two layers:
- **Core Dashboard**:
  - Header with avatar, greeting, username, XP/streak, notifications, admin entry when allowed.
  - Live status cards (shown only when relevant).
  - Quick actions: Check In, Book Tool, My Projects, Events.
  - Your Schedule.
  - Active Projects.
- **Discover Layer**:
  - Upcoming Events carousel.
  - Opportunities.
  - Mentorship & Support.
  - Knowledge Base preview.
  - About IDEA Lab preview.

### 2.2 അകത്തളം (Akathalam)
Akathalam combines lab status, check-in, events, and booking context:
- Lab status chips: electricity, Wi-Fi/internet quality, active visitors.
- Check-in/check-out card.
- Today's, upcoming, and past events.
- Tool and facility booking entry points.

### 2.3 Profile
The profile is a maker identity containing:
- **Tabs**: Profile, Activities, Projects, Experience, Education, Volunteering.
- **Public Data**: Display name, username, avatar, bio, interests, skills, public projects, public event participation, vouch count.
- **Private Data**: Detailed activity history, booking history, moderation/internal states, KTU ID, internal timestamps.

---

## 3. Onboarding Questionnaire Flow

Onboarding uses Google-only auth and forces completion of the following steps:
1. Welcome
2. Role Selection (student or professional)
3. Profile photo/avatar
4. Username (unique, lowercase, letters/numbers/underscores only, no reserved words)
5. Bio
6. Interests (exactly five selected)
7. Skills/languages
8. Review

Onboarding progress is locked until `users.onboarding_completed = true`.

---

## 4. Platform Workflows

### 4.1 Events
Events support public and invite-only application flows:
- **Auto-approved events**: Approved while capacity exists; waitlisted when full.
- **Invite-only events**: Pending review by admin; approved users cannot reapply.

### 4.2 Opportunities
Opportunity statuses can be `draft`, `published`, `expired`, `archived`, or `removed`. Expired items remain visible for a 2-day grace period, then auto-archive.

### 4.3 Vouches
- One active vouch per pair. No self-vouch. Max 10 active vouches given by one user.
- Removed vouch pairs cannot re-vouch for 90 days.
