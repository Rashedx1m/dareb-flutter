import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../cubit/notifications_cubit.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.notifications)),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          return switch (state.status) {
            NotificationsStatus.initial || NotificationsStatus.loading => const LoadingView(),
            NotificationsStatus.failure => ErrorView(
                message: state.error,
                onRetry: () => context.read<NotificationsCubit>().load(),
              ),
            NotificationsStatus.success => ListView.separated(
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final item = state.items[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primarySoft,
                      child: Icon(item.isRead ? Icons.notifications_none : Icons.notifications_active, color: AppColors.primary),
                    ),
                    title: Text(item.title, style: TextStyle(fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800)),
                    subtitle: Text(item.body),
                    trailing: Text(
                      DateFormat('yyyy/MM/dd HH:mm').format(item.createdAt),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  );
                },
              ),
          };
        },
      ),
    );
  }
}
