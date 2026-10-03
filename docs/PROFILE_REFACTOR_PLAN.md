# Profile Refactor Plan

Status: Draft
Last updated: 2026-08-07

## 1. Target Structure

The large profile experience should be split into focused cards and sections:
- ProfileHeader
- AcademicCard
- FabLabCard
- ProjectsCard
- AchievementsCard
- SettingsCard
- QRCard
- ActivityCard
- PreferencesCard

## 2. Refactor Strategy

- Move section-specific content into dedicated widgets under lib/features/profile/presentation/widgets
- Keep shared state and profile data access in a dedicated profile controller/provider
- Preserve navigation and edit flows while reducing monolithic screen complexity
- Use RC5Card, RC5Badge, RC5Chip, RC5EmptyState, and RC5Loading to standardize the presentation layer

## 3. Suggested Extraction Order

1. ProfileHeader
2. AcademicCard
3. FabLabCard
4. ProjectsCard
5. AchievementsCard
6. SettingsCard
7. QRCard
8. ActivityCard
9. PreferencesCard

## 4. Migration Notes

- Start by extracting the header and summary cards without changing behavior
- Update the parent screen to compose sections from smaller widgets
- Keep the underlying repository/provider contract stable during the refactor
