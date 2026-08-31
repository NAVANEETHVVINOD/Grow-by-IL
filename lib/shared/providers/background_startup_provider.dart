import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_logger.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/profile/domain/rc5_profile_providers.dart';
import '../../features/projects/domain/project_providers.dart';

final backgroundStartupProvider = FutureProvider<void>((ref) async {
  AppLogger.info(
    LogCategory.system,
    'BACKGROUND_STARTUP | Initiating non-critical background warmups',
  );

  // 1. Await currentUser to ensure user details are populated
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    AppLogger.info(
      LogCategory.system,
      'BACKGROUND_STARTUP | No authenticated user, skipping prefetch',
    );
    return;
  }

  // 2. Migration scan & Profile prefetch & Cache warmup
  // By fetching rc5ProfileHeaderProvider, we check/trigger migration in the background
  // and populate/cache the profile data.
  try {
    AppLogger.info(
      LogCategory.system,
      'BACKGROUND_STARTUP | Prefetching profile header and checking migrations',
    );
    await ref.read(rc5ProfileHeaderProvider.future);
  } catch (e, st) {
    AppLogger.error(
      LogCategory.system,
      'BACKGROUND_STARTUP | Profile prefetch / migration scan failed',
      error: e,
      stack: st,
    );
  }

  // 3. User Projects prefetch & Cache warmup
  try {
    AppLogger.info(
      LogCategory.system,
      'BACKGROUND_STARTUP | Prefetching user projects',
    );
    await ref.read(userProjectsProvider.future);
  } catch (e, st) {
    AppLogger.error(
      LogCategory.system,
      'BACKGROUND_STARTUP | User projects prefetch failed',
      error: e,
      stack: st,
    );
  }

  // 4. Public Projects prefetch
  try {
    AppLogger.info(
      LogCategory.system,
      'BACKGROUND_STARTUP | Prefetching public projects',
    );
    await ref.read(publicProjectsProvider.future);
  } catch (e, st) {
    AppLogger.error(
      LogCategory.system,
      'BACKGROUND_STARTUP | Public projects prefetch failed',
      error: e,
      stack: st,
    );
  }

  AppLogger.success(
    LogCategory.system,
    'BACKGROUND_STARTUP | Background warmups completed successfully',
  );
});
