-- Events: admins can manage
CREATE POLICY "events_insert_admin" ON events FOR INSERT TO authenticated 
  WITH CHECK (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('lab_admin','super_admin')));

CREATE POLICY "events_update_admin" ON events FOR UPDATE TO authenticated 
  USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('lab_admin','super_admin')));

CREATE POLICY "events_delete_admin" ON events FOR DELETE TO authenticated 
  USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('lab_admin','super_admin')));

-- tool_bookings: admins can see all
CREATE POLICY "bookings_select_admin" ON tool_bookings FOR SELECT TO authenticated 
  USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('lab_admin','super_admin')));

-- tool_bookings: users can cancel own pending
CREATE POLICY "bookings_update_own" ON tool_bookings FOR UPDATE TO authenticated 
  USING (user_id = auth.uid() AND status = 'pending');

-- project_members: fix the security hole
DROP POLICY IF EXISTS "members_insert_auth" ON project_members;
CREATE POLICY "members_insert_secure" ON project_members FOR INSERT TO authenticated 
  WITH CHECK (
    EXISTS (SELECT 1 FROM projects WHERE id = project_id AND created_by = auth.uid())
    OR (user_id = auth.uid() AND EXISTS (
      SELECT 1 FROM projects WHERE id = project_id AND visibility = 'public'
    ))
  );

-- notifications: users can only create for themselves
DROP POLICY IF EXISTS "notifications_insert_auth" ON notifications;
CREATE POLICY "notifications_insert_own" ON notifications FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);
