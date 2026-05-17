-- Fix 1: project_members RLS self-reference bug
-- The WHERE clause compares column to itself (always true)
DROP POLICY IF EXISTS "Project members are viewable by project members" 
  ON public.project_members;

CREATE POLICY "project_members_select_own_projects" 
ON public.project_members FOR SELECT
USING (
  auth.uid() IN (
    SELECT pm.user_id FROM public.project_members pm
    WHERE pm.project_id = public.project_members.project_id
  )
);

-- Fix 2: notifications insert too permissive  
-- Any user can create notifications for any other user
DROP POLICY IF EXISTS "Authenticated users can create notifications" 
  ON public.notifications;

CREATE POLICY "notifications_insert_own"
ON public.notifications FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Fix 3: missing booking admin visibility (from rc2_rls_fixes.sql)
-- Admins cannot see other users' bookings — breaks approval queue
CREATE POLICY IF NOT EXISTS "bookings_select_admin" 
ON public.tool_bookings FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.uid() AND role IN ('lab_admin', 'super_admin')
  )
);

-- Fix 4: events admin write policies (from rc2_rls_fixes.sql)  
CREATE POLICY IF NOT EXISTS "events_insert_admin" ON events FOR INSERT 
WITH CHECK (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() 
          AND role IN ('lab_admin','super_admin'))
);
CREATE POLICY IF NOT EXISTS "events_update_admin" ON events FOR UPDATE
USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() 
          AND role IN ('lab_admin','super_admin'))
);
