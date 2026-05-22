-- Test Script for Double Booking Race Condition (23P01 Verification)
-- Paste this entirely into the Supabase SQL Editor.
-- It bypasses RLS and explicitly tests the EXCLUDE USING gist constraint.

DO $$
DECLARE
  test_tool_id UUID;
  test_user_id UUID;
  overlap_start TIMESTAMPTZ := now() + interval '1 day';
  overlap_end TIMESTAMPTZ := now() + interval '1 day 2 hours';
BEGIN
  -- 1. Grab a valid tool and user to satisfy Foreign Key constraints
  SELECT id INTO test_tool_id FROM tools LIMIT 1;
  SELECT id INTO test_user_id FROM auth.users LIMIT 1;
  
  IF test_tool_id IS NULL OR test_user_id IS NULL THEN
    RAISE NOTICE 'Skipping test: No tools or users found in DB.';
    RETURN;
  END IF;

  -- 2. Insert the FIRST booking (should succeed)
  RAISE NOTICE 'Inserting first booking...';
  INSERT INTO tool_bookings (tool_id, user_id, slot_start, slot_end, status)
  VALUES (test_tool_id, test_user_id, overlap_start, overlap_end, 'pending');
  RAISE NOTICE 'First booking inserted successfully!';

  -- 3. Insert the SECOND booking for the EXACT same tool and time
  RAISE NOTICE 'Attempting overlapping booking...';
  BEGIN
    INSERT INTO tool_bookings (tool_id, user_id, slot_start, slot_end, status)
    VALUES (test_tool_id, test_user_id, overlap_start, overlap_end, 'pending');
    
    -- If we get here, the constraint failed to block it!
    RAISE EXCEPTION 'CRITICAL FAILURE: The overlapping booking was allowed!';
  EXCEPTION
    WHEN exclusion_violation THEN
      -- SQLSTATE 23P01
      RAISE NOTICE 'SUCCESS: Caught expected exclusion violation (23P01)! Constraint is active.';
  END;
  
  -- 4. Cleanup the test booking
  DELETE FROM tool_bookings WHERE tool_id = test_tool_id AND slot_start = overlap_start;
  RAISE NOTICE 'Test cleanup complete.';
END $$;
