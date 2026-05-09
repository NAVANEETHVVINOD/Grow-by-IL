-- RC2 Operations: Database Foundation

-- 1. ROLE-BASED ACCESS CONTROL HELPERS
-- Returns the role of the current authenticated user from public.users table.
-- SECURITY DEFINER and STABLE used for performance and permission bypass.
CREATE OR REPLACE FUNCTION auth.get_user_role() 
RETURNS TEXT AS $$
  SELECT role FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- 2. AUDIT LOGGING SYSTEM
-- Records critical administrative and operational changes.
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES public.users(id),
    target_table TEXT NOT NULL,
    target_id TEXT,
    action TEXT NOT NULL, -- e.g., 'ROLE_CHANGE', 'STOCK_ADJUST', 'SESSION_TERMINATED'
    payload JSONB,        -- snapshot of the change
    created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS for Audit Logs: Admins can read, System (Service Role) can insert.
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Super Admins can view audit logs" ON public.audit_logs
    FOR SELECT USING (auth.get_user_role() = 'super_admin');

CREATE POLICY "System can insert audit logs" ON public.audit_logs
    FOR INSERT WITH CHECK (true); -- Validated by application logic / service role

-- 3. LAB REPORTS SYSTEM
-- For persisting "Report Issue" feedback from the lab environment.
CREATE TABLE IF NOT EXISTS public.lab_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID REFERENCES public.users(id),
    resource_type TEXT NOT NULL, -- 'tool', 'lab', 'inventory'
    resource_id TEXT,
    description TEXT NOT NULL,
    status TEXT DEFAULT 'pending', -- 'pending', 'resolved', 'dismissed'
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.lab_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can create lab reports" ON public.lab_reports
    FOR INSERT WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Lab Admins can manage reports" ON public.lab_reports
    FOR ALL USING (auth.get_user_role() IN ('lab_admin', 'super_admin'));

-- 4. USER TABLE EXTENSIONS
-- Ensure role and status columns are present for RC2 governance.
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'status') THEN
        ALTER TABLE public.users ADD COLUMN status TEXT DEFAULT 'active';
    END IF;
END $$;

-- 5. TRIGGER FOR AUDIT LOGGING (Example: User Role Change)
-- This function can be expanded to other tables as needed.
CREATE OR REPLACE FUNCTION public.log_user_role_change()
RETURNS TRIGGER AS $$
BEGIN
    IF (OLD.role <> NEW.role) THEN
        INSERT INTO public.audit_logs (actor_id, target_table, target_id, action, payload)
        VALUES (
            auth.uid(), 
            'users', 
            NEW.id::TEXT, 
            'ROLE_CHANGE', 
            jsonb_build_object('old_role', OLD.role, 'new_role', NEW.role)
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_user_role_change
    AFTER UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.log_user_role_change();
