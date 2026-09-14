-- ============================================================
-- 006_profile_rls_hardening.sql
-- RLS Policy Hardening for Profile Sub-tables
-- ============================================================

-- 1. user_experience
DROP POLICY IF EXISTS user_experience_select ON public.user_experience;
CREATE POLICY user_experience_select_auth ON public.user_experience
  FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_profiles.user_id = user_experience.user_id
      AND user_profiles.is_public = true
    )
  );

-- 2. user_education
DROP POLICY IF EXISTS user_education_select ON public.user_education;
CREATE POLICY user_education_select_auth ON public.user_education
  FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_profiles.user_id = user_education.user_id
      AND user_profiles.is_public = true
    )
  );

-- 3. user_volunteering
DROP POLICY IF EXISTS user_volunteering_select ON public.user_volunteering;
CREATE POLICY user_volunteering_select_auth ON public.user_volunteering
  FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_profiles.user_id = user_volunteering.user_id
      AND user_profiles.is_public = true
    )
  );

-- 4. user_portfolio_projects
DROP POLICY IF EXISTS user_portfolio_projects_select ON public.user_portfolio_projects;
CREATE POLICY user_portfolio_projects_select_auth ON public.user_portfolio_projects
  FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_profiles.user_id = user_portfolio_projects.user_id
      AND user_profiles.is_public = true
    )
  );

-- 5. user_social_links
DROP POLICY IF EXISTS user_social_links_select ON public.user_social_links;
CREATE POLICY user_social_links_select_auth ON public.user_social_links
  FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_profiles.user_id = user_social_links.user_id
      AND user_profiles.is_public = true
    )
  );

-- 6. user_skills
DROP POLICY IF EXISTS user_skills_select ON public.user_skills;
CREATE POLICY user_skills_select_auth ON public.user_skills
  FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_profiles.user_id = user_skills.user_id
      AND user_profiles.is_public = true
    )
  );

-- 7. user_interests
DROP POLICY IF EXISTS user_interests_select ON public.user_interests;
CREATE POLICY user_interests_select_auth ON public.user_interests
  FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE user_profiles.user_id = user_interests.user_id
      AND user_profiles.is_public = true
    )
  );
