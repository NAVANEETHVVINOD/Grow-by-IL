import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/neo_card.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../lab/domain/lab_providers.dart';

import '../domain/notification_providers.dart';
import '../../../../shared/models/notification_model.dart';

class NotificationInboxScreen extends ConsumerWidget {
  const NotificationInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Inbox',
          style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.navy),
        ),
        actions: [
          if (user != null)
            TextButton(
              onPressed: () => ref.read(notificationRepositoryProvider).markAllAsRead(user.id).then((_) => ref.invalidate(notificationsProvider)),
              child: Text(
                'MARK ALL READ',
                style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.cobalt),
              ),
            ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: AppSizes.md),
                  Text('Your inbox is empty', style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          final unread = notifications.where((n) => !n.isRead).toList();
          final earlier = notifications.where((n) => n.isRead).toList();

          return ListView(
            padding: const EdgeInsets.all(AppSizes.lg),
            children: [
              if (unread.isNotEmpty) ...[
                _buildSectionHeader('NEW'),
                const SizedBox(height: AppSizes.md),
                ...unread.map((n) => _NotificationTile(notification: n)),
                const SizedBox(height: AppSizes.xl),
              ],
              if (earlier.isNotEmpty) ...[
                _buildSectionHeader('EARLIER'),
                const SizedBox(height: AppSizes.md),
                ...earlier.map((n) => _NotificationTile(notification: n)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});
  final NotificationModel notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: NeoCard(
        color: notification.isRead ? Colors.white : AppColors.yellow.withOpacity(0.05),
        borderColor: notification.isRead ? AppColors.navy : AppColors.yellow,
        onTap: () {
          if (!notification.isRead) {
            ref.read(notificationRepositoryProvider).markAsRead(notification.id).then((_) => ref.invalidate(notificationsProvider));
          }
          // TODO: Handle action_url navigation
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeIcon(notification.type),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.createdAt.toLocal().toString().substring(5, 16),
                      style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                const CircleAvatar(radius: 4, backgroundColor: AppColors.yellow),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(String type) {
    IconData icon;
    Color color;
    switch (type) {
      case 'alert':
        icon = Icons.warning_amber_rounded;
        color = AppColors.red;
        break;
      case 'reminder':
        icon = Icons.alarm_rounded;
        color = AppColors.cobalt;
        break;
      case 'invite':
        icon = Icons.mail_outline_rounded;
        color = AppColors.green;
        break;
      case 'milestone':
        icon = Icons.workspace_premium_rounded;
        color = AppColors.orange;
        break;
      default:
        icon = Icons.notifications_active_outlined;
        color = AppColors.navy;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

