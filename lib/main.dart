import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/constants/supabase_keys.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    AppLogger.info(
      LogCategory.system,
      'FIREBASE_INITIALIZATION_START | '
      'projectId=${DefaultFirebaseOptions.android.projectId} '
      'appId=${DefaultFirebaseOptions.android.appId}',
    );
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.success(LogCategory.system, 'FIREBASE_INITIALIZATION_SUCCESS');
  } catch (e, st) {
    AppLogger.error(
      LogCategory.system,
      'FIREBASE_INITIALIZATION_FAILED',
      error: e,
      stack: st,
    );
  }

  AppLogger.printStartupBanner();

  if (!SupabaseKeys.isConfigured) {
    debugPrint('\n[CONFIG ERROR] Supabase keys are missing!');
    debugPrint(
      'Please run with: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...\n',
    );
  }

  await Supabase.initialize(
    url: SupabaseKeys.url,
    anonKey: SupabaseKeys.anonKey,
  );

  runApp(const ProviderScope(child: GrowApp()));
}

class GrowApp extends StatelessWidget {
  const GrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Grow~',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: goRouter,
    );
  }
}
