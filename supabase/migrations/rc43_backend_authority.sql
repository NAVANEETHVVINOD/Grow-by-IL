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
-- PART 2: NOTIFICATION RPC
-- ========================

-- Server-side function to create notifications for ANY user.
-- Runs with SECURITY DEFINER so it bypasses RLS.
-- Only callable by authenticated users.
CREATE OR REPLACE FUNCTION public.notify_user(
  p_user_id UUID,
  p_type TEXT,
  p_title TEXT,
  p_message TEXT,
  p_related_id UUID DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.notifications (user_id, type, title, message, related_id)
  VALUES (p_user_id, p_type, p_title, p_message, p_related_id);
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.notify_user TO authenticated;

-- ========================
-- PART 3: ADDITIONAL INDEXES
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
