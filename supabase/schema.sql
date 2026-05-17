-- AUTO-SYNCED FROM LIVE SUPABASE: 2026-05-17
-- This file reflects the ACTUAL production schema.
-- DO NOT edit manually. Update via Supabase dashboard then re-sync.
-- See docs/database_contract.md for the human-readable contract.

-- 1. CLUBS
CREATE TABLE public.clubs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  color TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. USERS (extends auth.users)
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  college_roll TEXT UNIQUE,
  role TEXT NOT NULL DEFAULT 'student' CHECK (role = ANY (ARRAY['student'::text, 'lab_admin'::text, 'super_admin'::text])),
  club_id UUID REFERENCES public.clubs(id),
  xp INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  reputation_score INTEGER DEFAULT 100,
  qr_code_data TEXT UNIQUE,
  fcm_token TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  profile_completed BOOLEAN DEFAULT false,
  avatar_url TEXT,
  is_active BOOLEAN DEFAULT true,
  ban_reason TEXT,
  banned_at TIMESTAMP WITH TIME ZONE
);

-- 3. TOOLS
CREATE TABLE public.tools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category = ANY (ARRAY['3d_printer'::text, 'laser'::text, 'electronics'::text, 'woodwork'::text, 'fabrication'::text, 'other'::text])),
  description TEXT,
  image_url TEXT,
  sop_url TEXT,
  total_qty INTEGER NOT NULL DEFAULT 1,
  available_qty INTEGER NOT NULL DEFAULT 1,
  health_status TEXT DEFAULT 'available' CHECK (health_status = ANY (ARRAY['available'::text, 'in_use'::text, 'maintenance'::text, 'retired'::text])),
  last_maintained TIMESTAMP WITH TIME ZONE,
  qr_code_data TEXT UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 4. PROJECTS
CREATE TABLE public.projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  club_id UUID REFERENCES public.clubs(id),
  status TEXT DEFAULT 'ideation' CHECK (status = ANY (ARRAY['ideation'::text, 'in_progress'::text, 'completed'::text, 'showcase'::text])),
  created_by UUID REFERENCES public.users(id),
  visibility TEXT DEFAULT 'public' CHECK (visibility = ANY (ARRAY['public'::text, 'club'::text, 'private'::text])),
  showcase_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 5. TOOL_BOOKINGS
CREATE TABLE public.tool_bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tool_id UUID REFERENCES public.tools(id),
  user_id UUID REFERENCES public.users(id),
  project_id UUID REFERENCES public.projects(id),
  slot_start TIMESTAMP WITH TIME ZONE NOT NULL,
  slot_end TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status = ANY (ARRAY['pending'::text, 'approved'::text, 'active'::text, 'returned'::text, 'cancelled'::text, 'rejected'::text])),
  approved_by UUID REFERENCES public.users(id),
  approved_at TIMESTAMP WITH TIME ZONE,
  checkout_at TIMESTAMP WITH TIME ZONE,
  returned_at TIMESTAMP WITH TIME ZONE,
  return_reminder_sent BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 6. LAB_SESSIONS
CREATE TABLE public.lab_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id),
  checkin_time TIMESTAMP WITH TIME ZONE DEFAULT now(),
  checkout_time TIMESTAMP WITH TIME ZONE,
  purpose TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 7. EVENTS
CREATE TABLE public.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  event_type TEXT DEFAULT 'workshop' CHECK (event_type = ANY (ARRAY['workshop'::text, 'hackathon'::text, 'talk'::text, 'competition'::text, 'open_lab'::text, 'other'::text])),
  club_id UUID REFERENCES public.clubs(id),
  event_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE,
  venue TEXT,
  capacity INTEGER,
  rsvp_count INTEGER DEFAULT 0,
  image_url TEXT,
  created_by UUID REFERENCES public.users(id),
  status TEXT DEFAULT 'upcoming' CHECK (status = ANY (ARRAY['upcoming'::text, 'ongoing'::text, 'completed'::text, 'cancelled'::text])),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 8. RSVPS
CREATE TABLE public.rsvps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id),
  qr_ticket_data TEXT UNIQUE,
  checked_in_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 9. PROJECT_MEMBERS
CREATE TABLE public.project_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES public.projects(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id),
  role TEXT DEFAULT 'member' CHECK (role = ANY (ARRAY['admin'::text, 'lead'::text, 'member'::text, 'mentor'::text])),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 10. NOTIFICATIONS
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id),
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT,
  related_id UUID,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 11. KNOWLEDGE_ARTICLES
CREATE TABLE public.knowledge_articles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  tags TEXT[],
  author_id UUID REFERENCES public.users(id),
  upvotes INTEGER DEFAULT 0,
  is_approved BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
