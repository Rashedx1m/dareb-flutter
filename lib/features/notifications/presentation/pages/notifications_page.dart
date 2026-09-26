import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/mock_catalog.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.notifications)),
      body: ListView.separated(
        itemCount: MockCatalog.notifications.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final item = MockCatalog.notifications[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primarySoft,
              child: Icon(item.isRead ? Icons.notifications_none : Icons.notifications_active, color: AppColors.primary),
            ),
            title: Text(item.title, style: TextStyle(fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800)),
            subtitle: Text(item.body),
            trailing: Text(item.time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          );
        },
      ),
    );
  }
}
