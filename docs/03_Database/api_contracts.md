# API Contracts

This document records the exact API signatures and repository contracts implemented for the profile ecosystem.

## CURRENT IMPLEMENTATION STATUS
* **API Contracts**: `Status: fully implemented` - Verified in `ProfileEcosystemRepository` and mocked in unit tests.

---

## 1. Repository Method Contracts

All database mutations return model objects on success or throw `OfflineQueueException` if the device is offline.

### 1.1 Profile Metadata
```dart
Future<UserProfileModel?> getProfile(String userId);
Future<UserProfileModel> upsertProfile(UserProfileModel profile);
```

### 1.2 Skills
```dart
Future<List<UserSkillModel>> getSkills(String userId);
Future<UserSkillModel> upsertSkill(UserSkillModel skill);
Future<void> deleteSkill(String id);
Future<void> deleteSkillByName(String userId, String name);
```

### 1.3 Interests
```dart
Future<List<String>> getInterests(String userId);
Future<void> setInterests(String userId, List<String> interests);
```

### 1.4 Education
```dart
Future<List<UserEducationModel>> getEducation(String userId);
Future<UserEducationModel> addEducation(UserEducationModel item);
Future<void> updateEducation(String id, Map<String, dynamic> updates);
Future<void> deleteEducation(String id);
```

### 1.5 Social Links
```dart
Future<List<UserSocialLinkModel>> getSocialLinks(String userId);
Future<UserSocialLinkModel> upsertSocialLink(UserSocialLinkModel link);
Future<void> deleteSocialLink(String id);
Future<void> deleteSocialLinkByPlatform(String userId, String platform);
```

---

## 2. Replay Contract
```dart
Future<void> replayQueue();
```
Processes the local SharedPreferences queue in-order. Aborts and preserves queue on authentication expiry or network socket timeout.
