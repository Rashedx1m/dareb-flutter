import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../courses/domain/entities/search_results.dart';
import '../../../courses/presentation/widgets/content_cards.dart';
import '../../../courses/presentation/widgets/outlined_search_field.dart';
import '../cubit/search_cubit.dart';

/// «نتائج البحث» كما في التصميم: حقل بإطار أزرق تحت الترويسة، ثم النتائج مجمّعة:
/// النشاطات، ثم الدورات، ثم الاختبارات.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PageHeader(
            title: AppStrings.searchResults,
            onBack: () => Navigator.of(context).maybePop(),
            onNotifications: () => context.push('/notifications'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 8, 13, 0),
            child: OutlinedSearchField(
              onChanged: context.read<SearchCubit>().queryChanged,
              borderColor: AppColors.searchCardBorder,
              autofocus: true,
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) => switch (state.status) {
                SearchStatus.idle => const Center(child: Text(AppStrings.searchPrompt)),
                SearchStatus.loading => const LoadingView(),
                SearchStatus.failure => ErrorView(message: state.error, onRetry: context.read<SearchCubit>().retry),
                SearchStatus.success when state.results.isEmpty =>
                  const EmptyView(message: AppStrings.noMatches, icon: PhosphorIconsRegular.magnifyingGlass),
                SearchStatus.success => _Results(results: state.results),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.results});

  final SearchResults results;

  @override
  Widget build(BuildContext context) {
    const border = AppColors.searchCardBorder;
    final sections = [
      if (results.activities.isNotEmpty)
        (
          AppStrings.sectionActivities,
          [
            for (final activity in results.activities)
              ExamContentCard(exam: activity, icon: AppAssets.icActivity, borderColor: border),
          ]
        ),
      if (results.subjects.isNotEmpty)
        (
          AppStrings.sectionCourses,
          [for (final subject in results.subjects) SubjectContentCard(subject: subject, borderColor: border)]
        ),
      if (results.exams.isNotEmpty)
        (
          AppStrings.sectionExams,
          [for (final exam in results.exams) ExamContentCard(exam: exam, icon: AppAssets.icQuiz, borderColor: border)]
        ),
    ];
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(14, 0, 16, MediaQuery.paddingOf(context).bottom + 24),
      children: [
        for (final (title, cards) in sections) ...[
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 22, bottom: 12, start: 2),
            child: Text(title, style: const TextStyle(color: AppColors.primary, fontSize: 15)),
          ),
          for (final (i, card) in cards.indexed) ...[if (i > 0) const SizedBox(height: 17), card],
        ],
      ],
    );
  }
}
