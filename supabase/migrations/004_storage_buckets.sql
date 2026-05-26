-- ============================================================
-- 004_storage_buckets.sql
-- Media Architecture for Profile Ecosystem
--
-- Creates storage buckets and access policies BEFORE any
-- form wiring. This prevents media becoming tech debt.
-- ============================================================

-- 1. Avatars bucket (public read, owner write)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  true,
  2097152, -- 2MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- 2. Portfolio media bucket (public read, owner write)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'portfolio',
  'portfolio',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO NOTHING;

-- 3. Project banners bucket (public read, owner write)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'project-banners',
  'project-banners',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- Storage RLS Policies
-- ============================================================

-- Avatars: anyone can read, owner can write
CREATE POLICY "avatars_public_read" ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'avatars');

CREATE POLICY "avatars_owner_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "avatars_owner_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "avatars_owner_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Portfolio: anyone can read, owner can write
CREATE POLICY "portfolio_public_read" ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'portfolio');

CREATE POLICY "portfolio_owner_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'portfolio' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "portfolio_owner_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'portfolio' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "portfolio_owner_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'portfolio' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Project banners: anyone can read, owner can write
CREATE POLICY "project_banners_public_read" ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'project-banners');

CREATE POLICY "project_banners_owner_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'project-banners' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "project_banners_owner_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'project-banners' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "project_banners_owner_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'project-banners' AND (storage.foldername(name))[1] = auth.uid()::text);
