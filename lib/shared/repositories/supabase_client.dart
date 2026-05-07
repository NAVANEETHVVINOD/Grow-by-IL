import 'package:supabase_flutter/supabase_flutter.dart';

/// Global Supabase client accessor.
///
/// Use after `Supabase.initialize()` has been called in main.dart.
final supabase = Supabase.instance.client;
