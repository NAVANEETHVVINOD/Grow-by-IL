import 'package:flutter_test/flutter_test.dart';
import 'package:grow/core/utils/supabase_error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('explains when Google provider is disabled in Supabase', () {
    final error = AuthException(
      'Unsupported provider',
      statusCode: '400',
      code: 'provider_disabled',
    );

    expect(
      handleSupabaseError(error),
      'Google sign-in is not configured yet. Use email and password for now.',
    );
  });
}
