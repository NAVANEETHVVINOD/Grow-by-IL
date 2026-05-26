import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/constants/supabase_keys.dart';
import 'core/router/app_router.dart';
import 'core/theme/rc5_theme.dart';
import 'core/utils/app_logger.dart';

import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/utils/provider_observer.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();



  // ── Firebase initialization ──────────────────────────────
  try {
    if (DefaultFirebaseOptions.isConfigured) {
      AppLogger.info(
        LogCategory.system,
        'FIREBASE_INITIALIZATION | Using injected --dart-define options',
      );
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      AppLogger.info(
        LogCategory.system,
        'FIREBASE_INITIALIZATION | Using native google-services.json fallback',
      );
      await Firebase.initializeApp();
    }

    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    AppLogger.success(LogCategory.system,
        'FIREBASE_INITIALIZATION_SUCCESS & CRASHLYTICS_SETUP');
  } catch (e, st) {
    AppLogger.error(
      LogCategory.system,
      'FIREBASE_INITIALIZATION_FAILED',
      error: e,
      stack: st,
    );
  }

  AppLogger.printStartupBanner();

  // ── Supabase initialization ──────────────────────────────
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

  runApp(
    ProviderScope(
      observers: [AppProviderObserver()],
      child: const GrowApp(),
    ),
  );
}

class GrowApp extends ConsumerWidget {
  const GrowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Grow~',
      debugShowCheckedModeBanner: false,
      theme: RC5Theme.light,
      routerConfig: router,
    );
  }
}
