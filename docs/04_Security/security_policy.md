# Grow~ Security Policy

This document details the row-level security (RLS), frontend secrets injection, Firebase policies, and storage access controls for Grow~.

## CURRENT IMPLEMENTATION STATUS
* **RLS Policies**: `Status: production validated` - Configured in Supabase migrations `002_rls_security_fixes.sql` and `006_profile_rls_hardening.sql`.
* **Secrets Management**: `Status: fully implemented` - Secrets are injected via build-time `--dart-define` constants.

---

## 1. Secrets & Environment Variables Injection

To prevent credential leaks and ensure environment segregation:
- **No Hardcoded Keys**: Service role keys or database credentials must NEVER be committed to source files. The frontend client uses the public `anon` key only.
- **Firebase/Google Credentials**:
  - `google-services.json` and `GoogleService-Info.plist` are **gitignored** and must be downloaded individually by developers.
  - The Firebase Web Client ID for Google Sign-In is injected at build time via `--dart-define=GOOGLE_WEB_CLIENT_ID`.
- **Environment File**: Refer to `.env.example` for local environment configuration variables.

---

## 2. Row Level Security (RLS) Policies

All database tables implement strict RLS checking. The frontend context must always act as the authenticated user.

### 2.1 Profile Table `user_profiles`
- **SELECT**: Authenticated users can read public profiles (`is_public = true`) or their own profile.
  ```sql
  CREATE POLICY "user_profiles_select_public" ON public.user_profiles
    FOR SELECT TO authenticated
    USING (is_public = true OR user_id = auth.uid());
  ```
- **INSERT/UPDATE/DELETE**: Restricted to matching owner ID path:
  ```sql
  CREATE POLICY "user_profiles_update_own" ON public.user_profiles
    FOR UPDATE TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());
  ```

### 2.2 Profile Child Tables (`user_skills`, `user_education`, `user_experience`, `user_social_links`, `user_interests`)
- **SELECT**: Accessible by all authenticated users to render profiles.
- **INSERT/UPDATE/DELETE**: Restricted to own record writes via `user_id = auth.uid()`.

---

## 3. Storage Bucket Security

Avatar image storage (bucket name: `avatars`):
- **Select (Read)**: Any authenticated user can read public avatar images.
- **Insert / Update / Delete**: Restricted to the owner's subfolder:
  ```sql
  CREATE POLICY "avatars_owner_all" ON storage.objects
    FOR ALL TO authenticated
    USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);
  ```
- **File Validation**: Buckets restrict upload file types (`image/jpeg`, `image/png`, `image/webp`) and limit avatar files to 2 MB to prevent abuse.
