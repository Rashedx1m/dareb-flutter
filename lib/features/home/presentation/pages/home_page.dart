import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/data/mock_catalog.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../courses/domain/entities/course.dart';
import '../../domain/entities/news_item.dart';
import '../cubit/home_cubit.dart';
import '../widgets/complete_account.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<HomeCubit>().load(),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _HomeHeader(
                    name: MockCatalog.user.name,
                    points: MockCatalog.user.points,
                    coursesCount: MockCatalog.user.enrolledCoursesCount,
                    onSearch: () => context.push('/search'),
                    onNotify: () => context.push('/notifications'),
                    onAchievements: () => context.push('/achievements'),
                  ),
                  _HomeBody(state: state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == HomeStatus.loading && state.courses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 90),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (state.status == HomeStatus.failure && state.courses.isEmpty) {
      return _ErrorBody(
        message: state.error ?? AppStrings.homeLoadError,
        onRetry: () => context.read<HomeCubit>().load(),
      );
    }

    final progress = state.progress;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProgressCard(
            progress: progress,
            coursesCount: state.curriculumCoursesCount,
            onDetails: () => context.push('/my-courses'),
          ),
          const SizedBox(height: 16),
          _TestsEntryCard(onTap: () => context.push('/tests')),
          const SizedBox(height: 16),
          _PromoBanner(onCheckAccount: () => showCompleteAccountDialog(context)),
          const SizedBox(height: 14),
          const _BannerDots(),
          const SizedBox(height: 18),
          _SubjectsSection(
            categories: state.categories,
            onShowAll: () => context.push('/categories'),
          ),
          if (state.news.isNotEmpty) ...[
            const SizedBox(height: 22),
            _NewsSection(news: state.news),
          ],
          if (state.courses.isNotEmpty) ...[
            const SizedBox(height: 22),
            _FeaturedCoursesSection(
              courses: state.courses,
              onCourseTap: (c) => context.push('/courses/${c.id}'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.name,
    required this.points,
    required this.coursesCount,
    required this.onSearch,
    required this.onNotify,
    required this.onAchievements,
  });

  final String name;
  final int points;
  final int coursesCount;
  final VoidCallback onSearch;
  final VoidCallback onNotify;
  final VoidCallback onAchievements;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, top + 10, 20, 22),
      decoration: const BoxDecoration(
        color: AppColors.headerTeal,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: Image.asset(AppAssets.studentWriting, fit: BoxFit.contain),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(text: AppStrings.welcomeBack),
                                TextSpan(text: name),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(PhosphorIconsRegular.handWaving, color: Colors.white, size: 18),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(PhosphorIconsRegular.medal, color: Colors.white, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          '$points ${AppStrings.pointsLabel}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                        const Icon(PhosphorIconsRegular.bookOpen, color: Colors.white, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          '$coursesCount ${AppStrings.coursesCountLabel}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _HeaderIconButton(
                tooltip: AppStrings.achievements,
                onTap: onAchievements,
                child: const Icon(PhosphorIconsRegular.trophy, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 8),
              _HeaderIconButton(
                tooltip: AppStrings.notifications,
                onTap: onNotify,
                child: SvgPicture.asset(
                  AppAssets.icNotification,
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: AppStrings.searchHint,
            child: GestureDetector(
              onTap: onSearch,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Row(
                  children: [
                    Icon(PhosphorIconsRegular.magnifyingGlass, color: AppColors.textMuted, size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.searchHint,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.child,
    required this.onTap,
    required this.tooltip,
  });

  final Widget child;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.progress,
    required this.coursesCount,
    required this.onDetails,
  });

  final double progress;
  final int coursesCount;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final percent = (progress.clamp(0, 1) * 100).toInt();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEF2F6)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        AppStrings.curriculumProgress,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onDetails,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        AppStrings.details,
                        style: TextStyle(
                          color: AppColors.accentBlue.withValues(alpha: 0.95),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.progressSubtitle,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  '$coursesCount ${AppStrings.coursesCount}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CircularPercentIndicator(
            radius: 46,
            lineWidth: 8,
            percent: progress.clamp(0, 1),
            animation: true,
            progressColor: AppColors.primary,
            backgroundColor: const Color(0xFFE8EEF2),
            circularStrokeCap: CircularStrokeCap.round,
            center: Text(
              '$percent%',
              style: const TextStyle(
                color: Color(0xFF8A9AA8),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Lato',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestsEntryCard extends StatelessWidget {
  const _TestsEntryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEF2F6)),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: SvgPicture.asset(AppAssets.icQuiz, fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.myTests,
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 3),
                  Text(
                    AppStrings.myTestsEntrySubtitle,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_left, color: AppColors.textMuted, size: 24),
          ],
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.onCheckAccount});

  final VoidCallback onCheckAccount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 148,
      decoration: BoxDecoration(
        color: AppColors.headerTeal,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 8, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.bannerTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: const Color(0xFFE7F7F7),
                    borderRadius: BorderRadius.circular(22),
                    child: InkWell(
                      onTap: onCheckAccount,
                      borderRadius: BorderRadius.circular(22),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        child: Text(
                          AppStrings.checkAccount,
                          style: TextStyle(
                            color: AppColors.headerTeal,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, end: 12),
            child: Container(
              width: 118,
              height: 118,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF8F8),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.asset(AppAssets.studentWriting, fit: BoxFit.contain),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerDots extends StatelessWidget {
  const _BannerDots();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Dot(active: true),
          SizedBox(width: 6),
          _Dot(),
          SizedBox(width: 6),
          _Dot(),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 22 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : const Color(0xFFD9DEE5),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.onShowAll, this.underline = false});

  final String title;
  final VoidCallback? onShowAll;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (underline) ...[
              const SizedBox(height: 4),
              const SizedBox(
                width: 42,
                child: Divider(color: AppColors.primary, thickness: 2, height: 8),
              ),
            ],
          ],
        ),
        const Spacer(),
        if (onShowAll != null)
          GestureDetector(
            onTap: onShowAll,
            child: const Text(
              AppStrings.showAll,
              style: TextStyle(
                color: AppColors.accentBlue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _SubjectsSection extends StatelessWidget {
  const _SubjectsSection({required this.categories, required this.onShowAll});

  final List<Category> categories;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final shown = categories.take(3).toList();
    return Column(
      children: [
        _SectionTitle(title: AppStrings.subjects, onShowAll: onShowAll),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.chipBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    shown[i].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final subject in shown)
              _SubjectImage(imageKey: subject.icon),
          ],
        ),
      ],
    );
  }
}

class _SubjectImage extends StatelessWidget {
  const _SubjectImage({required this.imageKey});

  final String imageKey;

  @override
  Widget build(BuildContext context) {
    final path = AppAssets.subjectImage(imageKey);
    if (path == null) {
      return const SizedBox(
        height: 78,
        width: 78,
        child: Icon(PhosphorIconsRegular.bookOpen, color: AppColors.chipBlue, size: 40),
      );
    }
    return Image.asset(path, height: 78, fit: BoxFit.contain);
  }
}

class _NewsSection extends StatelessWidget {
  const _NewsSection({required this.news});

  final List<NewsItem> news;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: AppStrings.latestNews, underline: true),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: news.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _NewsCard(item: news[i]),
          ),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item});

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 300,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => const ColoredBox(color: AppColors.primarySoft),
              errorWidget: (_, _, _) => const ColoredBox(
                color: AppColors.primarySoft,
                child: Icon(Icons.image_outlined, color: AppColors.primary, size: 36),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                  stops: [0.45, 1],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.date,
                    style: const TextStyle(color: Color(0xFFE0E6EC), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCoursesSection extends StatelessWidget {
  const _FeaturedCoursesSection({required this.courses, required this.onCourseTap});

  final List<Course> courses;
  final ValueChanged<Course> onCourseTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: AppStrings.featuredCourses,
          onShowAll: () => context.push('/courses'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 232,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: courses.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _FeaturedCourseCard(
              course: courses[i],
              onTap: () => onCourseTap(courses[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedCourseCard extends StatelessWidget {
  const _FeaturedCourseCard({required this.course, required this.onTap});

  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 186,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 6))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: course.imageUrl,
                  height: 108,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const ColoredBox(color: AppColors.primarySoft),
                  errorWidget: (_, _, _) => const ColoredBox(
                    color: AppColors.primarySoft,
                    child: Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 34),
                  ),
                ),
                PositionedDirectional(
                  top: 8,
                  start: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xB3000000),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          '${course.studentsCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(PhosphorIconsRegular.bookOpen, color: AppColors.chipBlue, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          course.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course.instructor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${course.chaptersCount} ${AppStrings.chaptersLabel} , ${course.lessonsCount} ${AppStrings.lessonsLabel}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
