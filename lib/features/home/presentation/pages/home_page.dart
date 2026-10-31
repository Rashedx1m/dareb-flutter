import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/utils/external_link.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/refresh_on_return.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/entities/subject.dart';
import '../../domain/entities/home_banner.dart';
import '../../domain/entities/news_item.dart';
import '../cubit/home_cubit.dart';
import '../widgets/complete_account.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.openLink = openExternalLink});

  /// يفتح رابط السلايدر أو الخبر خارج التطبيق، ويُستبدل في الاختبارات.
  final LinkOpener openLink;

  @override
  Widget build(BuildContext context) {
    return RefreshOnReturn(
      // النسبة وعدد الكورسات يتغيّران بعد مشاهدة درس أو تفعيل كود.
      onReturn: () => context.read<HomeCubit>().load(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Colors.white,
              body: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => context.read<HomeCubit>().load(),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _HomeHeader(
                      name: state.user?.name ?? '',
                      points: state.points,
                      coursesCount: state.user?.enrolledCoursesCount ?? 0,
                      onSearch: () => context.push('/search'),
                      onNotify: () => context.push('/notifications'),
                      onAchievements: () => context.push('/achievements'),
                    ),
                    _HomeBody(state: state, openLink: openLink),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.state, required this.openLink});

  final HomeState state;
  final LinkOpener openLink;

  @override
  Widget build(BuildContext context) {
    if (state.status == HomeStatus.loading && state.courses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 90),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (state.status == HomeStatus.failure && state.courses.isEmpty) {
      return ErrorView(
        message: state.error,
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
            onDetails: () => context.go('/my-courses'),
          ),
          const SizedBox(height: 16),
          _PromoCarousel(
            sliders: state.sliders,
            onCheckAccount: () => showCompleteAccountDialog(context),
            openLink: openLink,
          ),
          if (state.subjects.isNotEmpty) ...[
            const SizedBox(height: 18),
            _SubjectsSection(
              subjects: state.subjects,
              onShowAll: () => context.push('/categories'),
            ),
          ],
          if (state.news.isNotEmpty) ...[
            const SizedBox(height: 22),
            _NewsSection(news: state.news, openLink: openLink),
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
                child: Image.asset(
                  'assets/icons/trophy.png',
                  width: 100,
                  height: 100,

                ),
              ),
              const SizedBox(width: 8),
              _HeaderIconButton(
                tooltip: AppStrings.notifications,
                onTap: onNotify,
                child: Image.asset(
                  'assets/icons/icNotification.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: AppStrings.searchHere,
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
                        AppStrings.searchHere,
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
        // color: Colors.white.withValues(alpha: 0.22),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
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
        border: Border.all(color: AppColors.cardBorderSoft),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowSoft, blurRadius: 18, offset: Offset(0, 8)),
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
            // التحديث عند العودة يحرّك الدائرة من النسبة السابقة لا من الصفر.
            animateFromLastPercent: true,
            progressColor: AppColors.primary,
            backgroundColor: AppColors.progressTrack,
            circularStrokeCap: CircularStrokeCap.round,
            center: Text(
              '$percent%',
              style: const TextStyle(
                color: AppColors.progressText,
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

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel({
    required this.sliders,
    required this.onCheckAccount,
    required this.openLink,
  });

  final List<HomeBanner> sliders;
  final VoidCallback onCheckAccount;
  final LinkOpener openLink;

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  var _page = 0;

  Future<void> _open(String? link) async {
    if (link == null) return;
    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasScheme) return;
    await widget.openLink(uri);
  }

  @override
  Widget build(BuildContext context) {
    // بلا سلايدر من الخادم تبقى بانر فيجما؛ النقاط للشريحات الحقيقية فقط.
    if (widget.sliders.isEmpty) {
      return _PromoBanner(onCheckAccount: widget.onCheckAccount);
    }

    return Column(
      children: [
        SizedBox(
          height: 148,
          child: PageView.builder(
            itemCount: widget.sliders.length,
            onPageChanged: (index) => setState(() => _page = index),
            itemBuilder: (context, index) {
              final slide = widget.sliders[index];
              return GestureDetector(
                onTap: () => _open(slide.link),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: slide.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (_, _) => const ColoredBox(color: AppColors.primarySoft),
                    errorWidget: (_, _, _) => const ColoredBox(
                      color: AppColors.headerTeal,
                      child: Icon(Icons.image_outlined, color: Colors.white, size: 36),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.sliders.length > 1) ...[
          const SizedBox(height: 14),
          _BannerDots(count: widget.sliders.length, index: _page),
        ],
      ],
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
                    color: AppColors.primarySoft,
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
                color: AppColors.primarySoft,
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
  const _BannerDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            _Dot(active: i == index),
          ],
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
        color: active ? AppColors.primary : AppColors.dotInactive,
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
  const _SubjectsSection({required this.subjects, required this.onShowAll});

  final List<Subject> subjects;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final shown = subjects.take(3).toList();
    return Column(
      children: [
        _SectionTitle(title: AppStrings.subjects, onShowAll: onShowAll),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < shown.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                // زر المادة وصورتها يفتحان صفحتها بتبويباتها.
                child: Material(
                  color: AppColors.chipBlue,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => context.push('/categories/${shown[i].id}'),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
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
              GestureDetector(
                onTap: () => context.push('/categories/${subject.id}'),
                child: _SubjectImage(imageUrl: subject.imageUrl),
              ),
          ],
        ),
      ],
    );
  }
}

class _SubjectImage extends StatelessWidget {
  const _SubjectImage({required this.imageUrl});

  final String imageUrl;

  static const _fallback = SizedBox(
    height: 78,
    width: 78,
    child: Icon(PhosphorIconsRegular.bookOpen, color: AppColors.chipBlue, size: 40),
  );

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 78,
      width: 78,
      fit: BoxFit.contain,
      placeholder: (_, _) => _fallback,
      errorWidget: (_, _, _) => _fallback,
    );
  }
}

class _NewsSection extends StatelessWidget {
  const _NewsSection({required this.news, required this.openLink});

  final List<NewsItem> news;
  final LinkOpener openLink;

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
            itemBuilder: (context, i) => _NewsCard(item: news[i], openLink: openLink),
          ),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item, required this.openLink});

  final NewsItem item;
  final LinkOpener openLink;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final uri = Uri.tryParse(item.link);
        if (uri == null || !uri.hasScheme) return;
        openLink(uri);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 300,
          child: CachedNetworkImage(
            imageUrl: item.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) => const ColoredBox(color: AppColors.primarySoft),
            errorWidget: (_, _, _) => const ColoredBox(
              color: AppColors.primarySoft,
              child: Icon(Icons.image_outlined, color: AppColors.primary, size: 36),
            ),
          ),
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
                      color: AppColors.overlay70,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          '${course.subscriptionsCount}',
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
                    '${course.semestersCount} ${AppStrings.chaptersLabel} , ${course.lessonsCount} ${AppStrings.lessonsLabel}',
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
