import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../courses/domain/entities/course.dart';
import '../cubit/achievements_cubit.dart';
import '../widgets/subject_progress.dart';

/// إنجازاتي كما في التصميم: الملف وإحصاءاته ثم تقدّم كل مادة مشترك بها.
class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  static const _subjectIcons = [
    PhosphorIconsRegular.bookOpen,
    PhosphorIconsRegular.exam,
    PhosphorIconsRegular.chalkboardTeacher,
    PhosphorIconsRegular.books,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PageHeader(
            title: AppStrings.achievements,
            onBack: () => context.pop(),
            onNotifications: () => context.push('/notifications'),
          ),
          Expanded(
            child: BlocBuilder<AchievementsCubit, AchievementsState>(
              builder: (context, state) {
                return switch (state.status) {
                  AchievementsStatus.initial || AchievementsStatus.loading => const LoadingView(),
                  AchievementsStatus.failure => ErrorView(
                      message: state.error,
                      onRetry: () => context.read<AchievementsCubit>().load(),
                    ),
                  AchievementsStatus.success => _Body(
                      user: state.user,
                      courses: state.courses,
                      lessonsCount: state.lessonsCount,
                      icons: _subjectIcons,
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.user,
    required this.courses,
    required this.lessonsCount,
    required this.icons,
  });

  final User? user;
  final List<Course> courses;
  final int lessonsCount;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        _ProfileBlock(user: user, lessonsCount: lessonsCount),
        const SizedBox(height: 28),
        if (courses.isEmpty)
          const EmptyView(message: AppStrings.achievementsEmpty)
        else
          for (var i = 0; i < courses.length; i++)
            SubjectProgress(course: courses[i], icon: icons[i % icons.length]),
      ],
    );
  }
}

class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock({required this.user, required this.lessonsCount});

  final User? user;
  final int lessonsCount;

  static const _avatarSize = 120.0;

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    return Column(
      children: [
        _Avatar(url: user?.avatarUrl, size: _avatarSize),
        const SizedBox(height: 14),
        Text(
          user?.name ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.nameDark, fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 18),
        IntrinsicHeight(
          child: Row(
            children: [
              _Stat(value: user?.semestersCount ?? 0, label: AppStrings.statSemesters),
              const _StatDivider(),
              _Stat(value: user?.points ?? 0, label: AppStrings.statPoints),
              const _StatDivider(),
              _Stat(value: user?.enrolledCoursesCount ?? 0, label: AppStrings.statCourses),
              const _StatDivider(),
              _Stat(value: lessonsCount, label: AppStrings.statLessons),
              const _StatDivider(),
              _Stat(value: user?.medalsCount ?? 0, label: AppStrings.statMedals),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    const placeholder = Image(image: AssetImage(AppAssets.studentWriting), fit: BoxFit.cover);
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: ColoredBox(
          color: AppColors.avatarBg,
          child: url == null
              ? placeholder
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => placeholder,
                  errorWidget: (_, _, _) => placeholder,
                ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontFamily: 'Lato',
              color: AppColors.statTeal,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.statLabel, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return const VerticalDivider(width: 1, thickness: 1, indent: 4, endIndent: 4, color: AppColors.statDivider);
  }
}
