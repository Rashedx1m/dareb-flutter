import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../courses/presentation/widgets/header_search_field.dart';
import '../../../courses/presentation/widgets/segmented_tabs.dart';
import '../../domain/entities/quiz.dart';
import '../cubit/tests_cubit.dart';
import '../widgets/quiz_card.dart';

/// شاشة «اختباراتي»: ترويسة بحقل بحث، تبويبان، وقائمة من `/exams/my` أو النشاطات.
class TestsPage extends StatefulWidget {
  const TestsPage({super.key});

  @override
  State<TestsPage> createState() => _TestsPageState();
}

class _TestsPageState extends State<TestsPage> {
  QuizKind _tab = QuizKind.test;
  String _query = '';

  List<Quiz> _filter(List<Quiz> items) {
    final q = _query.trim();
    if (q.isEmpty) return items;
    return [for (final quiz in items) if (quiz.title.contains(q) || quiz.instructor.contains(q)) quiz];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PageHeader(
            title: AppStrings.myTests,
            onBack: () => context.canPop() ? context.pop() : context.go('/home'),
            onNotifications: () => context.push('/notifications'),
            bottom: HeaderSearchField(onChanged: (v) => setState(() => _query = v)),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedTabs(
              tabs: const {
                QuizKind.test: AppStrings.tabExams,
                QuizKind.activity: AppStrings.tabActivities,
              },
              selected: _tab,
              onSelect: (tab) => setState(() => _tab = tab),
              trackColor: AppColors.tabTrack,
              labelColor: AppColors.tabLabel,
            ),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: BlocBuilder<TestsCubit, TestsState>(
              builder: (context, state) {
                final source = _tab == QuizKind.test ? state.exams : state.activities;
                final items = _filter(source);
                return switch (state.status) {
                  TestsStatus.failure => ErrorView(
                      message: state.error,
                      onRetry: context.read<TestsCubit>().load,
                    ),
                  TestsStatus.success when source.isEmpty => EmptyView(
                      message: _tab == QuizKind.test ? AppStrings.noMyExams : AppStrings.noMyActivities,
                      icon: PhosphorIconsRegular.exam,
                    ),
                  TestsStatus.success when items.isEmpty => const EmptyView(
                      message: AppStrings.noTestsFound,
                      icon: PhosphorIconsRegular.magnifyingGlass,
                    ),
                  TestsStatus.success => ListView.separated(
                      padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, MediaQuery.paddingOf(context).bottom + 24),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 24),
                      itemBuilder: (context, i) => QuizCard(
                        quiz: items[i],
                        onTap: () => context.push('/quiz/${items[i].id}'),
                      ),
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
