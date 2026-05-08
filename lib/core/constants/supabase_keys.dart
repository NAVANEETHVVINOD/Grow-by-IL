/// Supabase project credentials.
///
/// Replace with real values from your Supabase dashboard:
/// Settings → API → Project URL / anon key.
class SupabaseKeys {
  SupabaseKeys._();

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
