import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/features/auth/data/auth_repository.dart';

/// Single source of truth for role checks in UI.
/// DO NOT duplicate role logic anywhere else.

/// Exposes current user role for UI gating.
final currentRoleProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return user?.role ?? 'student';
});

/// True if the current user is lab_admin or super_admin.
final isLabAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(currentRoleProvider);
  return role == 'lab_admin' || role == 'super_admin';
});

/// True if the current user is super_admin.
final isSuperAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(currentRoleProvider);
  return role == 'super_admin';
});
