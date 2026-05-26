-- ============================================================
-- 003_profile_ecosystem.sql
-- Profile Ecosystem Migration
-- 
-- Creates the relational profile tables that replace the
-- SharedPreferences draft system with real Supabase persistence.
--
-- Architecture:
--   projects            = platform/lab collaborative projects (EXISTING)
--   user_portfolio_projects = personal showcase projects (NEW)
--   project_members     = users ↔ platform projects (EXISTING)
-- ============================================================

-- ============================================================
-- 1. user_profiles
-- Base profile metadata (bio, department, privacy flags)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  bio TEXT DEFAULT '',
  user_type TEXT DEFAULT 'student' CHECK (user_type IN ('student', 'professional', 'faculty')),
  department TEXT DEFAULT '',
  avatar_url TEXT,
  is_public BOOLEAN DEFAULT true,
  show_email BOOLEAN DEFAULT false,
  show_phone BOOLEAN DEFAULT false,
  show_stats BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT unique_user_profile UNIQUE (user_id)
);

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Anyone authenticated can read public profiles
CREATE POLICY "user_profiles_select_public" ON public.user_profiles
  FOR SELECT TO authenticated
  USING (is_public = true OR user_id = auth.uid());

-- Owner can do everything
CREATE POLICY "user_profiles_insert_own" ON public.user_profiles
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_profiles_update_own" ON public.user_profiles
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_profiles_delete_own" ON public.user_profiles
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

CREATE INDEX idx_user_profiles_user_id ON public.user_profiles(user_id);

-- ============================================================
-- 2. user_experience
-- Work/lab history with ordering
-- ============================================================
CREATE TABLE IF NOT EXISTS public.user_experience (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  organization TEXT NOT NULL,
  description TEXT DEFAULT '',
  start_date DATE,
  end_date DATE,
  is_current BOOLEAN DEFAULT false,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.user_experience ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_experience_select" ON public.user_experience
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "user_experience_insert_own" ON public.user_experience
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_experience_update_own" ON public.user_experience
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_experience_delete_own" ON public.user_experience
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

CREATE INDEX idx_user_experience_user_id ON public.user_experience(user_id);
CREATE INDEX idx_user_experience_sort ON public.user_experience(user_id, sort_order);

-- ============================================================
-- 3. user_education
-- Academic history
-- ============================================================
CREATE TABLE IF NOT EXISTS public.user_education (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  institution TEXT NOT NULL,
  degree TEXT NOT NULL,
  field_of_study TEXT DEFAULT '',
  start_year INT,
  end_year INT,
  is_current BOOLEAN DEFAULT false,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.user_education ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_education_select" ON public.user_education
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "user_education_insert_own" ON public.user_education
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_education_update_own" ON public.user_education
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_education_delete_own" ON public.user_education
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

CREATE INDEX idx_user_education_user_id ON public.user_education(user_id);

-- ============================================================
-- 4. user_portfolio_projects
-- Personal showcase projects (SEPARATE from platform projects)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.user_portfolio_projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  project_url TEXT,
  source_url TEXT,
  banner_url TEXT,
  technologies TEXT[] DEFAULT '{}',
  is_featured BOOLEAN DEFAULT false,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.user_portfolio_projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_portfolio_projects_select" ON public.user_portfolio_projects
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "user_portfolio_projects_insert_own" ON public.user_portfolio_projects
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_portfolio_projects_update_own" ON public.user_portfolio_projects
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_portfolio_projects_delete_own" ON public.user_portfolio_projects
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

CREATE INDEX idx_user_portfolio_projects_user_id ON public.user_portfolio_projects(user_id);
CREATE INDEX idx_user_portfolio_projects_sort ON public.user_portfolio_projects(user_id, sort_order);

-- ============================================================
-- 5. user_volunteering
-- Volunteer history
-- ============================================================
CREATE TABLE IF NOT EXISTS public.user_volunteering (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL,
  organization TEXT NOT NULL,
  description TEXT DEFAULT '',
  start_date DATE,
  end_date DATE,
  is_current BOOLEAN DEFAULT false,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.user_volunteering ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_volunteering_select" ON public.user_volunteering
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "user_volunteering_insert_own" ON public.user_volunteering
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_volunteering_update_own" ON public.user_volunteering
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_volunteering_delete_own" ON public.user_volunteering
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

CREATE INDEX idx_user_volunteering_user_id ON public.user_volunteering(user_id);

-- ============================================================
-- 6. user_social_links
-- GitHub, LinkedIn, Twitter, etc.
-- ============================================================
CREATE TABLE IF NOT EXISTS public.user_social_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  platform TEXT NOT NULL CHECK (platform IN ('github', 'linkedin', 'twitter', 'website', 'instagram', 'youtube', 'other')),
  url TEXT NOT NULL,
  label TEXT,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT unique_user_platform UNIQUE (user_id, platform)
);

ALTER TABLE public.user_social_links ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_social_links_select" ON public.user_social_links
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "user_social_links_insert_own" ON public.user_social_links
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_social_links_update_own" ON public.user_social_links
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_social_links_delete_own" ON public.user_social_links
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

CREATE INDEX idx_user_social_links_user_id ON public.user_social_links(user_id);

-- ============================================================
-- 7. user_skills
-- Skill tags with proficiency levels
-- ============================================================
CREATE TABLE IF NOT EXISTS public.user_skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  level INT NOT NULL DEFAULT 1 CHECK (level >= 1 AND level <= 3),
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT unique_user_skill UNIQUE (user_id, name)
);

ALTER TABLE public.user_skills ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_skills_select" ON public.user_skills
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "user_skills_insert_own" ON public.user_skills
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_skills_update_own" ON public.user_skills
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_skills_delete_own" ON public.user_skills
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

CREATE INDEX idx_user_skills_user_id ON public.user_skills(user_id);

-- ============================================================
-- 8. user_interests (simple tag table)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.user_interests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT unique_user_interest UNIQUE (user_id, name)
);

ALTER TABLE public.user_interests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_interests_select" ON public.user_interests
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "user_interests_insert_own" ON public.user_interests
  FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "user_interests_delete_own" ON public.user_interests
  FOR DELETE TO authenticated
  USING (user_id = auth.uid());

CREATE INDEX idx_user_interests_user_id ON public.user_interests(user_id);

-- ============================================================
-- Auto-update updated_at triggers
-- ============================================================
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_user_experience_updated_at
  BEFORE UPDATE ON public.user_experience
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_user_education_updated_at
  BEFORE UPDATE ON public.user_education
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_user_portfolio_projects_updated_at
  BEFORE UPDATE ON public.user_portfolio_projects
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_user_volunteering_updated_at
  BEFORE UPDATE ON public.user_volunteering
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
