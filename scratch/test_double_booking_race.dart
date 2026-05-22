import 'package:supabase/supabase.dart';
import 'dart:async';

void main() async {
  // Replace with the actual Supabase URL and ANON Key
  final String supabaseUrl = 'https://huftzhfqnnslvnfzvbex.supabase.co';
  final String supabaseKey = 'sb_publishable_BgMRO_Rnwm4WhHKjuUBQZw_ikqTXH-2';
  
  final client = SupabaseClient(supabaseUrl, supabaseKey);

  print('=========================================');
  print('RACE CONDITION TEST: DOUBLE BOOKING');
  print('=========================================');

  // We need two authenticated users to test the race condition properly, or just use anon/service role if RLS allows it for testing.
  // Assuming RLS allows insert if authenticated, we would normally sign in here.
  // But actually, we can test the DB constraint by just attempting to insert overlapping times if we have a test user.

  // Let's attempt to insert two bookings for the SAME tool at the SAME time.
  // Note: Since we are running from a script, we might not bypass RLS without a token.
  // If this script fails due to RLS, it means RLS is active (Good).
  
  // Example dummy data
  final String toolId = '00000000-0000-0000-0000-000000000000'; // Replace with a valid tool ID from DB
  final String userId1 = '11111111-1111-1111-1111-111111111111'; // Replace with User A ID
  final String userId2 = '22222222-2222-2222-2222-222222222222'; // Replace with User B ID
  
  final now = DateTime.now().toUtc();
  final startTime = now.add(Duration(hours: 1)).toIso8601String();
  final endTime = now.add(Duration(hours: 2)).toIso8601String();

  print('Preparing concurrent requests...');
  
  final future1 = client.from('tool_bookings').insert({
    'tool_id': toolId,
    'user_id': userId1,
    'slot_start': startTime,
    'slot_end': endTime,
    'status': 'pending',
  });

  final future2 = client.from('tool_bookings').insert({
    'tool_id': toolId,
    'user_id': userId2,
    'slot_start': startTime,
    'slot_end': endTime,
    'status': 'pending',
  });

  print('Firing simultaneous inserts...');
  try {
    final results = await Future.wait([
      future1.catchError((e) => print('Request 1 Failed (Expected DB Constraint Error): $e')),
      future2.catchError((e) => print('Request 2 Failed (Expected DB Constraint Error): $e')),
    ]);
    print('Responses received.');
  } catch (e) {
    print('Caught error: $e');
  }
}
