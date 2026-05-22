import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.navy;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
        ),
        actions: [
          if (user != null)
            notificationsAsync.maybeWhen(
              data: (list) {
                final hasUnread = list.any((n) => !n.isRead);
                if (!hasUnread) return const SizedBox.shrink();
                return TextButton(
                  onPressed: () async {
                    await ref
                        .read(notificationRepositoryProvider)
                        .markAllAsRead(user.id);
                    ref.invalidate(notificationsProvider);
                  },
                  child: Text(
                    'MARK ALL READ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Your inbox is empty',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll notify you when something happens.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          // Group notifications by date
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(notificationsProvider.notifier).refresh();
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200) {
                  ref.read(notificationsProvider.notifier).loadMore();
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSizes.lg),
                itemCount: notifications.length +
                    (ref.watch(notificationsProvider.notifier).hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == notifications.length) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSizes.md),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final notification = notifications[index];
                  return _NotificationTile(notification: notification);
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});
  final NotificationModel notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: NeoCard(
        color: Theme.of(context).colorScheme.surface,
        borderColor: notification.isRead
            ? (isDark ? Colors.white24 : AppColors.navy)
            : AppColors.yellow,
        onTap: () {
          if (!notification.isRead) {
            ref
                .read(notificationRepositoryProvider)
                .markAsRead(notification.id)
                .then(
                    (_) => ref.read(notificationsProvider.notifier).refresh());
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? (isDark ? Colors.white12 : AppColors.background)
                      : AppColors.yellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notification.isRead
                      ? Icons.notifications_none_rounded
                      : Icons.notifications_active_rounded,
                  size: 20,
                  color: notification.isRead
                      ? AppColors.textSecondary
                      : (isDark ? Colors.white : AppColors.navy),
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
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : AppColors.navy,
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.w500,
                            color: isDark
                                ? Colors.white70
                                : AppColors.navy.withValues(alpha: 0.8),
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        _buildTypeTag(context, notification.type),
                        Text(
                          notification.createdAt
                              .toLocal()
                              .toString()
                              .substring(5, 16),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.6),
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

  Widget _buildTypeTag(BuildContext context, String type) {
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
        color = Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppColors.navy;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          Icon(icon, size: 10, color: color),
          Text(
            type.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
