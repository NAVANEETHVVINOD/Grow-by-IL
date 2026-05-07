/// Supabase project credentials.
///
/// Replace with real values from your Supabase dashboard:
/// Settings → API → Project URL / anon key.
class SupabaseKeys {
  SupabaseKeys._();

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://huftzhfqnnslvnfzvbex.supabase.co',
  );

  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh1ZnR6aGZxbm5zbHZuZnp2YmV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc3ODE5MjMsImV4cCI6MjA5MzM1NzkyM30.27XddK7F21nbD3ghwBf8Hzt1I8vj5CLRH6PtZrMxkNk',
  );
}
