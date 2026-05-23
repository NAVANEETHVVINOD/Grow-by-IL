-- ============================================================
-- RC4.3 Migration: Backend Authority Transfer
-- Run this in the Supabase Dashboard SQL Editor
-- ============================================================

-- ========================
-- PART 1: BOOKING INTEGRITY
-- ========================

-- Enable btree_gist extension (required for exclusion constraints with mixed types)
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Prevent double-booking at the database level
-- No two bookings for the same tool can have overlapping time ranges
-- when either booking is in an active status.
ALTER TABLE public.tool_bookings
  ADD CONSTRAINT no_overlapping_tool_bookings
  EXCLUDE USING gist (
    tool_id WITH =,
    tstzrange(slot_start, slot_end, '[)') WITH &&
  )
  WHERE (status IN ('pending', 'approved', 'active'));

-- Composite index for booking slot queries (used by toolBookingsForDayProvider)
CREATE INDEX IF NOT EXISTS idx_tool_bookings_tool_slot
  ON public.tool_bookings (tool_id, slot_start, slot_end)
  WHERE status IN ('pending', 'approved', 'active');

-- Index for user+status queries (my bookings filtered by status)
CREATE INDEX IF NOT EXISTS idx_tool_bookings_user_status
  ON public.tool_bookings (user_id, status);

-- ========================
-- PART 2: RSVP SCHEMA ALIGNMENT
-- ========================

-- Production Flutter code writes and reads RSVP status.
ALTER TABLE public.rsvps
  ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'going';

UPDATE public.rsvps
SET status = 'going'
WHERE status IS NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'rsvps_status_check'
      AND conrelid = 'public.rsvps'::regclass
  ) THEN
    ALTER TABLE public.rsvps
      ADD CONSTRAINT rsvps_status_check
      CHECK (status IN ('going', 'cancelled', 'checked_in'));
  END IF;
END $$;

-- Required by EventRepository.upsert(... onConflict: 'event_id, user_id').
-- If this fails, duplicate RSVP rows already exist and must be merged first.
CREATE UNIQUE INDEX IF NOT EXISTS idx_rsvps_event_user_unique
  ON public.rsvps (event_id, user_id);

-- ========================
-- PART 3: NOTIFICATION TRIGGERS
-- ========================

-- Keep privileged notification fanout out of client-callable RPCs.
CREATE SCHEMA IF NOT EXISTS private;
REVOKE ALL ON SCHEMA private FROM PUBLIC;
REVOKE ALL ON SCHEMA private FROM anon;
REVOKE ALL ON SCHEMA private FROM authenticated;

CREATE OR REPLACE FUNCTION private.notify_booking_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  notification_title TEXT;
  notification_message TEXT;
  notification_type TEXT;
BEGIN
  IF NEW.status = OLD.status THEN
    RETURN NEW;
  END IF;

  IF NEW.status = 'approved' THEN
    notification_type := 'tool_booking_approved';
    notification_title := 'Booking Approved!';
    notification_message := 'Your equipment reservation has been approved.';
  ELSIF NEW.status = 'rejected' THEN
    notification_type := 'tool_booking_rejected';
    notification_title := 'Booking Rejected';
    notification_message := 'Your equipment reservation was not approved.';
  ELSE
    RETURN NEW;
  END IF;

  INSERT INTO public.notifications (user_id, type, title, message, related_id)
  VALUES (
    NEW.user_id,
    notification_type,
    notification_title,
    notification_message,
    NEW.id
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_booking_status_change ON public.tool_bookings;
CREATE TRIGGER trg_notify_booking_status_change
AFTER UPDATE OF status ON public.tool_bookings
FOR EACH ROW
EXECUTE FUNCTION private.notify_booking_status_change();

CREATE OR REPLACE FUNCTION private.notify_project_member_join()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  owner_id UUID;
  project_title TEXT;
BEGIN
  SELECT created_by, title
  INTO owner_id, project_title
  FROM public.projects
  WHERE id = NEW.project_id;

  IF owner_id IS NULL OR owner_id = NEW.user_id THEN
    RETURN NEW;
  END IF;

  INSERT INTO public.notifications (user_id, type, title, message, related_id)
  VALUES (
    owner_id,
    'project_join',
    'New Team Member',
    'Someone just joined "' || COALESCE(project_title, 'your project') || '".',
    NEW.project_id
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_project_member_join ON public.project_members;
CREATE TRIGGER trg_notify_project_member_join
AFTER INSERT ON public.project_members
FOR EACH ROW
EXECUTE FUNCTION private.notify_project_member_join();

-- ========================
-- PART 4: ADDITIONAL INDEXES
-- ========================

-- RSVP queries (my RSVPs)
CREATE INDEX IF NOT EXISTS idx_rsvps_user
  ON public.rsvps (user_id);

-- Notification list sorting + unread filter
CREATE INDEX IF NOT EXISTS idx_notifications_user_created
  ON public.notifications (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_user_unread
  ON public.notifications (user_id, created_at DESC)
  WHERE is_read = false;

-- Project creator index (admin queries)
CREATE INDEX IF NOT EXISTS idx_projects_creator
  ON public.projects (created_by);
