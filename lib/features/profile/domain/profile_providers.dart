import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../../../shared/repositories/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for counting total lab sessions for the current user
final userLabVisitsCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return 0;
  
  final response = await supabase
      .from('lab_sessions')
      .select('id', const FetchOptions(count: CountOption.exact))
      .eq('user_id', user.id);
      
  return response.count ?? 0;
});

/// Provider for counting unique tools used and returned by the current user
final userToolsUsedCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return 0;
  
  final response = await supabase
      .from('tool_bookings')
      .select('tool_id')
      .eq('user_id', user.id)
      .eq('status', 'returned');
      
  final toolIds = (response as List).map((row) => row['tool_id'] as String).toSet();
  return toolIds.length;
});

/// Provider for counting total events RSVP'd by the current user
final userEventsCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return 0;
  
  final response = await supabase
      .from('rsvps')
      .select('id', const FetchOptions(count: CountOption.exact))
      .eq('user_id', user.id);
      
  return response.count ?? 0;
});

/// Provider for counting total projects the current user is a member of
final userProjectsCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return 0;
  
  final response = await supabase
      .from('project_members')
      .select('id', const FetchOptions(count: CountOption.exact))
      .eq('user_id', user.id);
      
  return response.count ?? 0;
});
