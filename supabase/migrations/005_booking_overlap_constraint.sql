-- ============================================================
-- 005_booking_overlap_constraint.sql
-- Overlap Prevention Constraint for Tool Bookings
-- ============================================================

-- Enable btree_gist extension (required for GIST on UUID and Timestamptz)
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Drop constraint if it already exists to allow re-runs
ALTER TABLE public.tool_bookings
  DROP CONSTRAINT IF EXISTS tool_bookings_no_overlap;

-- Add exclusion constraint to prevent overlapping tool bookings
ALTER TABLE public.tool_bookings
  ADD CONSTRAINT tool_bookings_no_overlap EXCLUDE USING gist (
    tool_id WITH =,
    tstzrange(slot_start, slot_end) WITH &&
  ) WHERE (status != 'cancelled' AND status != 'rejected');
