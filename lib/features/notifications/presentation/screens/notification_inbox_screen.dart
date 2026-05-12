import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grow/core/constants/app_colors.dart';
import 'package:grow/core/constants/app_sizes.dart';
import 'package:grow/shared/widgets/neo_card.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/notifications/domain/notification_providers.dart';
import 'package:grow/shared/models/notification_model.dart';

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
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        actions: [
          notificationsAsync.maybeWhen(
            data: (list) {
              final hasUnread = list.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: () async {
                  if (user == null) return;
                  await ref.read(notificationRepositoryProvider).markAllAsRead(user.id);
                  ref.invalidate(notificationsProvider);
                },
                child: Text(
                  'MARK ALL READ',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cobalt,
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
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
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Your inbox is empty',
                    style: GoogleFonts.dmSans(color: AppColors.textSecondary),
                  ),
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
      style: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary,
      ),
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
        color: Colors.white,
        borderColor: notification.isRead ? AppColors.navy : AppColors.yellow,
        onTap: () {
          if (!notification.isRead) {
            ref
                .read(notificationRepositoryProvider)
                .markAsRead(notification.id)
                .then((_) => ref.invalidate(notificationsProvider));
          }
          // Action navigation logic...
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: notification.isRead ? AppColors.surface : AppColors.yellow.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                  size: 20,
                  color: notification.isRead ? AppColors.textSecondary : AppColors.navy,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.navy,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: const BoxDecoration(
                              color: AppColors.yellow,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500,
                        color: AppColors.navy.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        _buildTypeTag(notification.type),
                        Text(
                          notification.createdAt.toLocal().toString().substring(5, 16),
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTag(String type) {
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
      default:
        icon = Icons.notifications_active_outlined;
        color = AppColors.navy;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              type.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
