-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  Grow~ by IdeaLab — Supabase Database Schema                   ║
-- ║  All tables, indexes, and RLS policies for the app              ║
-- ╚══════════════════════════════════════════════════════════════════╝

-- 1. users (extends Supabase auth.users)
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  college_roll TEXT UNIQUE,
  username TEXT UNIQUE,
  base_role TEXT DEFAULT 'student'
    CHECK (base_role IN ('student','faculty')),
  system_role TEXT DEFAULT 'user'
    CHECK (system_role IN ('user','core_team','machine_head','operation_head','tech_head','admin')),
  skills TEXT[],
  interests TEXT[],
  profile_completed BOOLEAN DEFAULT false,
  club_id UUID,
  xp INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  reputation_score INTEGER DEFAULT 100,
  qr_code_data TEXT UNIQUE,
  fcm_token TEXT,
  is_blocked BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. clubs
CREATE TABLE public.clubs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  color TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add FK from users → clubs (after clubs exists)
ALTER TABLE public.users
  ADD CONSTRAINT fk_users_club
  FOREIGN KEY (club_id) REFERENCES public.clubs(id);

-- 3. tools
CREATE TABLE public.tools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category TEXT NOT NULL
    CHECK (category IN ('3d_printer','laser','electronics','woodwork','fabrication','other')),
  description TEXT,
  image_url TEXT,
  sop_url TEXT,
  total_qty INTEGER NOT NULL DEFAULT 1,
  available_qty INTEGER NOT NULL DEFAULT 1,
  health_status TEXT DEFAULT 'available'
    CHECK (health_status IN ('available','maintenance','disabled','broken')),
  requires_approval BOOLEAN DEFAULT false,
  last_maintained TIMESTAMPTZ,
  qr_code_data TEXT UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. tool_bookings
CREATE TABLE public.tool_bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tool_id UUID REFERENCES public.tools(id),
  user_id UUID REFERENCES public.users(id),
  project_id UUID,
  slot_start TIMESTAMPTZ NOT NULL,
  slot_end TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER NOT NULL DEFAULT 60,
  status TEXT DEFAULT 'pending'
    CHECK (status IN ('pending','approved','active','returned','cancelled')),
  approved_by UUID REFERENCES public.users(id),
  approved_at TIMESTAMPTZ,
  checkout_at TIMESTAMPTZ,
  returned_at TIMESTAMPTZ,
  return_reminder_sent BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. events
CREATE TABLE public.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  event_type TEXT DEFAULT 'workshop'
    CHECK (event_type IN ('workshop','hackathon','talk','competition','open_lab','other')),
  club_id UUID REFERENCES public.clubs(id),
  organization_name TEXT,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ,
  location_name TEXT,
  capacity INTEGER,
  rsvp_count INTEGER DEFAULT 0,
  image_url TEXT,
  created_by UUID REFERENCES public.users(id),
  project_id UUID REFERENCES public.projects(id),
  status TEXT DEFAULT 'active'
    CHECK (status IN ('active', 'cancelled', 'completed')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. rsvps
CREATE TABLE public.rsvps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id),
  qr_ticket_data TEXT UNIQUE,
  status TEXT DEFAULT 'going'
    CHECK (status IN ('going', 'cancelled', 'checked_in')),
  checked_in_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

-- 8. projects
CREATE TABLE public.projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  club_id UUID REFERENCES public.clubs(id),
  project_type TEXT DEFAULT 'team'
    CHECK (project_type IN ('personal', 'team', 'club', 'research', 'hackathon')),
  status TEXT DEFAULT 'active'
    CHECK (status IN ('active', 'archived', 'completed')),
  created_by UUID REFERENCES public.users(id),
  visibility TEXT DEFAULT 'public'
    CHECK (visibility IN ('public', 'private')),
  external_link TEXT,
  cover_image_url TEXT,
  showcase_url TEXT,
  member_limit INTEGER,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add FK from tool_bookings.project_id → projects
ALTER TABLE public.tool_bookings
  DROP CONSTRAINT IF EXISTS fk_bookings_project;
ALTER TABLE public.tool_bookings
  ADD CONSTRAINT fk_bookings_project
  FOREIGN KEY (project_id) REFERENCES public.projects(id);

-- 9. project_members
CREATE TABLE public.project_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES public.projects(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id),
  role TEXT DEFAULT 'member'
    CHECK (role IN ('owner', 'admin', 'member', 'mentor')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(project_id, user_id)
);

-- 10. project_members (was here, moved up)

-- 10.1 project_updates
CREATE TABLE IF NOT EXISTS public.project_updates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES public.projects(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.project_updates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "updates_select_auth" ON public.project_updates
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "updates_insert_member" ON public.project_updates
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 11. knowledge_articles
CREATE TABLE public.knowledge_articles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  tags TEXT[],
  author_id UUID REFERENCES public.users(id),
  upvotes INTEGER DEFAULT 0,
  is_approved BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── Helper Functions ──────────────────────────────────────────
CREATE OR REPLACE FUNCTION increment_rsvp_count(row_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.events
  SET rsvp_count = rsvp_count + 1
  WHERE id = row_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrement_rsvp_count(row_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE public.events
  SET rsvp_count = rsvp_count - 1
  WHERE id = row_id AND rsvp_count > 0;
END;
$$ LANGUAGE plpgsql;

-- ── Indexes ──────────────────────────────────────────────────────
CREATE INDEX idx_tool_bookings_user ON public.tool_bookings(user_id);
CREATE INDEX idx_tool_bookings_status ON public.tool_bookings(status);
CREATE INDEX idx_lab_sessions_user ON public.lab_sessions(user_id);
CREATE INDEX idx_events_date ON public.events(event_date);
CREATE INDEX idx_rsvps_event ON public.rsvps(event_id);
CREATE INDEX idx_notifications_user ON public.notifications(user_id, is_read);

-- ── RLS (enable — policies added per feature) ────────────────────
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tools ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tool_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lab_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rsvps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.knowledge_articles ENABLE ROW LEVEL SECURITY;

-- ── Users RLS Policies ───────────────────────────────────────────
-- Allow users to INSERT their own row
CREATE POLICY "users_insert_own"
ON public.users
FOR INSERT
WITH CHECK (auth.uid() = id);

-- Allow users to SELECT their own data
CREATE POLICY "users_select_own"
ON public.users
FOR SELECT
USING (auth.uid() = id);

-- Allow users to UPDATE their own data
CREATE POLICY "users_update_own"
ON public.users
FOR UPDATE
USING (auth.uid() = id);

-- ── Lab Sessions Table ───────────────────────────────────────────
CREATE TABLE public.lab_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id),
  checkin_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  checkout_time TIMESTAMPTZ,
  purpose TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.lab_sessions ENABLE ROW LEVEL SECURITY;

-- Prevent double active sessions at DB level
CREATE UNIQUE INDEX one_active_session_per_user
ON public.lab_sessions(user_id)
WHERE checkout_time IS NULL;

-- ── Lab Sessions RLS Policies ────────────────────────────────────
-- Allow users to INSERT their own sessions
CREATE POLICY "sessions_insert_own"
ON public.lab_sessions
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Allow users to SELECT their own sessions
CREATE POLICY "sessions_select_own"
ON public.lab_sessions
FOR SELECT
USING (auth.uid() = user_id);

-- Allow admins / op_heads / faculty to SELECT all sessions
CREATE POLICY "sessions_select_admin"
ON public.lab_sessions
FOR SELECT
USING (
  auth.uid() IN (
    SELECT id FROM public.users
    WHERE system_role IN ('admin','operation_head','faculty')
  )
);

-- Allow users to UPDATE (check-out) their own sessions
CREATE POLICY "sessions_update_own"
ON public.lab_sessions
FOR UPDATE
USING (auth.uid() = user_id);

-- ── Tools RLS Policies ───────────────────────────────────────────
-- Tools are viewable by everyone
CREATE POLICY "Tools are viewable by everyone"
ON public.tools
FOR SELECT
USING (true);

-- Only admins/op_heads can modify tools
CREATE POLICY "Admins/OpHeads can manage all tools"
ON public.tools
USING (
  auth.uid() IN (
    SELECT id FROM public.users
    WHERE system_role IN ('admin', 'operation_head', 'machine_head')
  )
);

-- ── Tool Bookings RLS Policies ───────────────────────────────────
-- Users can view their own bookings
-- ── Events RLS Policies ──────────────────────────────────────────
-- 1. Events are viewable by everyone
CREATE POLICY "Events are viewable by everyone"
ON public.events FOR SELECT USING (true);

-- 2. Admins/OpHeads can manage all events
CREATE POLICY "Admins can manage all events"
ON public.events USING (
  auth.uid() IN (SELECT id FROM public.users WHERE system_role IN ('admin', 'operation_head'))
);

-- ── RSVPs RLS Policies ───────────────────────────────────────────
-- 1. RSVPs are viewable by the user who RSVP'd
CREATE POLICY "Users can view own RSVPs"
ON public.rsvps FOR SELECT USING (auth.uid() = user_id);

-- 2. RSVPs are viewable by event organizers/admins
CREATE POLICY "Organizers can view event RSVPs"
ON public.rsvps FOR SELECT
USING (
  auth.uid() IN (
    SELECT created_by FROM public.events WHERE id = event_id
  ) OR auth.uid() IN (
    SELECT id FROM public.users WHERE system_role IN ('admin', 'operation_head')
  )
);

-- 3. Users can create their own RSVPs
CREATE POLICY "Users can create own RSVPs"
ON public.rsvps FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 4. Users can update (cancel) their own RSVPs
CREATE POLICY "Users can update own RSVPs"
ON public.rsvps FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own bookings"
ON public.tool_bookings
FOR SELECT
USING (auth.uid() = user_id);

-- Users can create their own bookings
CREATE POLICY "Users can create own bookings"
ON public.tool_bookings
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can update their own bookings (e.g., cancel/return)
CREATE POLICY "Users can update own bookings"
ON public.tool_bookings
FOR UPDATE
USING (auth.uid() = user_id);

-- Admins/op_heads can manage all bookings (approvals)
CREATE POLICY "Admins/OpHeads can manage all bookings"
ON public.tool_bookings
ALL
USING (
  auth.uid() IN (
    SELECT id FROM public.users
    WHERE system_role IN ('admin', 'operation_head', 'machine_head')
  )
);

-- Project members can return a tool on behalf of the project (if project_id matches)
CREATE POLICY "Project members can return project tools"
ON public.tool_bookings
FOR UPDATE
USING (
  project_id IS NOT NULL 
  AND auth.uid() IN (
    SELECT user_id FROM public.project_members WHERE project_id = public.tool_bookings.project_id
  )
);

-- ── Projects RLS Policies ────────────────────────────────────────
-- 1. Public projects are viewable by everyone
CREATE POLICY "Public projects are viewable by everyone"
ON public.projects FOR SELECT
USING (visibility = 'public');

-- 2. Private projects are viewable by members
CREATE POLICY "Private projects are viewable by members"
ON public.projects FOR SELECT
USING (
  auth.uid() IN (SELECT user_id FROM public.project_members WHERE project_id = id)
);

-- 3. Authenticated users can create projects
CREATE POLICY "Auth users can create projects"
ON public.projects FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

-- 4. Owners and Admins can update projects
CREATE POLICY "Owners and Admins can update projects"
ON public.projects FOR UPDATE
USING (
  auth.uid() IN (
    SELECT user_id FROM public.project_members 
    WHERE project_id = id AND role IN ('owner', 'admin')
  )
);

-- ── Project Members RLS Policies ─────────────────────────────────
-- 1. Members are viewable by other project members
CREATE POLICY "Project members are viewable by project members"
ON public.project_members FOR SELECT
USING (
  auth.uid() IN (SELECT user_id FROM public.project_members WHERE project_id = project_id)
);

-- 2. Authenticated users can join public projects
CREATE POLICY "Auth users can join projects"
ON public.project_members FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

-- 3. Only owners can manage roles or remove members
CREATE POLICY "Owners can manage members"
ON public.project_members FOR UPDATE
USING (
  auth.uid() IN (
    SELECT user_id FROM public.project_members 
    WHERE project_id = project_id AND role = 'owner'
  )
);


-- 12. inventory_items
CREATE TABLE public.inventory_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,
  item_type TEXT NOT NULL
    CHECK (item_type IN ('consumable', 'component', 'kit')),
  quantity INTEGER NOT NULL DEFAULT 0,
  min_quantity INTEGER DEFAULT 0,
  unit TEXT DEFAULT 'unit',
  storage_location TEXT,
  image_url TEXT,
  project_id UUID REFERENCES public.projects(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. inventory_transactions (Audit Ledger)
CREATE TABLE public.inventory_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tool_id UUID REFERENCES public.tools(id),
  inventory_item_id UUID REFERENCES public.inventory_items(id),
  user_id UUID REFERENCES public.users(id),
  transaction_type TEXT NOT NULL
    CHECK (transaction_type IN ('stock_in', 'stock_out', 'maintenance', 'damage_report', 'adjustment', 'assignment')),
  quantity_change INTEGER DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT one_item_ref CHECK (
    (tool_id IS NOT NULL AND inventory_item_id IS NULL) OR
    (tool_id IS NULL AND inventory_item_id IS NOT NULL)
  )
);

-- RLS for Inventory
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Inventory is viewable by everyone"
ON public.inventory_items FOR SELECT USING (true);

CREATE POLICY "Admins manage inventory_items"
ON public.inventory_items USING (
  auth.uid() IN (SELECT id FROM public.users WHERE system_role IN ('admin', 'operation_head', 'machine_head'))
);

CREATE POLICY "Admins manage inventory_transactions"
ON public.inventory_transactions USING (
  auth.uid() IN (SELECT id FROM public.users WHERE system_role IN ('admin', 'operation_head', 'machine_head'))
);

-- 14. notifications
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('alert', 'reminder', 'invite', 'milestone', 'system')),
  action_url TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications"
ON public.notifications FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
ON public.notifications FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Authenticated users can create notifications"
ON public.notifications FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

