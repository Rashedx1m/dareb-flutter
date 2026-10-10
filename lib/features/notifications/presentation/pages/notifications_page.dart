import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/app_notification.dart';
import '../cubit/notifications_cubit.dart';
import '../notification_date.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          return Column(
            children: [
              PageHeader(
                title: AppStrings.notifications,
                onBack: () => context.pop(),
                // في صفحة الإشعارات نفسها يحل عدد غير المقروء محل زر الجرس.
                trailing: _UnreadBadge(count: state.unreadCount),
              ),
              Expanded(
                child: switch (state.status) {
                  NotificationsStatus.failure => ErrorView(
                      message: state.error,
                      onRetry: context.read<NotificationsCubit>().load,
                    ),
                  NotificationsStatus.success when state.items.isEmpty => const _EmptyView(),
                  NotificationsStatus.success => ListView.separated(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) => const Divider(height: 4, thickness: 4, color: AppColors.divider),
                      itemBuilder: (_, i) => _NotificationTile(notification: state.items[i]),
                    ),
                  _ => const LoadingView(),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// عدد غير المقروء في دائرة بيضاء، ولا شيء إن قُرئت كلها.
class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Semantics(
      label: AppStrings.unreadNotifications,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Text(
          '$count',
          style: const TextStyle(
            fontFamily: 'Lato',
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// إشعار كما في التصميم: صورة دائرية، ثم العنوان والتاريخ والنص. نص غير
/// المقروء فيروزي ليلفت النظر، والمقروء رمادي.
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Avatar(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(color: AppColors.blueStrong, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  notificationDateLabel(notification.createdAt),
                  style: const TextStyle(color: AppColors.hint, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  notification.body,
                  style: TextStyle(
                    color: notification.isRead ? AppColors.listText : AppColors.primary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// الخادم لا يرسل صورة للإشعار، فكلها بأيقونة مكبّر الصوت كما في التصميم.
class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppColors.shadowStrong, blurRadius: 4, offset: Offset(0, 4))],
      ),
      // الأيقونة في الخط تتجه عكس التصميم، فتُقلب أفقياً.
      child: Transform.flip(
        flipX: true,
        child: const Icon(PhosphorIconsFill.megaphoneSimple, color: AppColors.iconBlue, size: 34),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 70, 24, 24),
      child: Column(
        children: [
          Icon(PhosphorIconsRegular.bell, color: AppColors.textMuted, size: 48),
          SizedBox(height: 12),
          Text(
            AppStrings.noNotifications,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
