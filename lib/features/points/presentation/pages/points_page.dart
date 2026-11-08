import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/point_record.dart';
import '../cubit/points_cubit.dart';

/// سجل نقاطي: من أين جاءت نقاط الطالب. لا إطار له في التصميم، فيتبع صفحة
/// الإشعارات: ترويسة، ثم قائمة بحالاتها الأربع.
class PointsPage extends StatelessWidget {
  const PointsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PageHeader(
            title: AppStrings.pointsHistory,
            onBack: () => context.pop(),
            onNotifications: () => context.push('/notifications'),
          ),
          Expanded(
            child: BlocBuilder<PointsCubit, PointsState>(
              builder: (context, state) {
                return switch (state.status) {
                  PointsStatus.failure => ErrorView(
                      message: state.error,
                      onRetry: context.read<PointsCubit>().load,
                    ),
                  PointsStatus.success when state.items.isEmpty =>
                    const EmptyView(message: AppStrings.noPointsYet, icon: PhosphorIconsRegular.coins),
                  PointsStatus.success => ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        _TotalCard(total: state.total),
                        const SizedBox(height: 8),
                        for (final record in state.items) _RecordTile(record: record),
                      ],
                    ),
                  _ => const LoadingView(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// مجموع نقاط السجل المعروض، فوق القائمة.
class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(PhosphorIconsRegular.coins, color: AppColors.primary, size: 24),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              AppStrings.pointsTotal,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '$total',
            style: const TextStyle(
              fontFamily: 'Lato',
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// سطر في السجل: النقاط، ثم السبب أو نص عام إن لم يُرسَل، والتاريخ إن وُجد.
class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final PointRecord record;

  @override
  Widget build(BuildContext context) {
    final date = record.date;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: Text(
              '+${record.points}',
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontFamily: 'Lato',
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.reason ?? AppStrings.pointsEarned,
                  style: const TextStyle(color: AppColors.listText, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                if (date != null) ...[
                  const SizedBox(height: 4),
                  Text(_dateLabel(date), style: const TextStyle(color: AppColors.hint, fontSize: 13)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// «30 أكتوبر 2026»، بأسماء الأشهر نفسها في الإشعارات.
  static String _dateLabel(DateTime date) => '${date.day} ${AppStrings.months[date.month - 1]} ${date.year}';
}
