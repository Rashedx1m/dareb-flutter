import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/subject_details.dart';
import '../cubit/subject_details_cubit.dart';
import '../widgets/content_cards.dart';
import '../widgets/header_search_field.dart';
import '../widgets/segmented_tabs.dart';

enum _Tab { content, exams, activities }

/// صفحة المادة: اسمها في الترويسة مع حقل بحث يصفّي التبويب المفتوح، ثم تبويبات
/// المحتوى (دورة المادة) والاختبارات والنشاطات اليومية.
class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key, required this.subjectId});

  final String subjectId;

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  _Tab _tab = _Tab.content;
  String _query = '';

  bool _matches(List<String> fields) {
    final q = _query.trim();
    return q.isEmpty || fields.any((field) => field.contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final title = context.select((SubjectDetailsCubit cubit) => cubit.state.details?.course.subjectName) ?? '';
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PageHeader(
            title: title,
            onBack: () => Navigator.of(context).maybePop(),
            onNotifications: () => context.push('/notifications'),
            bottom: HeaderSearchField(onChanged: (v) => setState(() => _query = v)),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 17, end: 15),
            child: SegmentedTabs(
              tabs: const {
                _Tab.content: AppStrings.tabContent,
                _Tab.exams: AppStrings.tabExams,
                _Tab.activities: AppStrings.tabActivities,
              },
              selected: _tab,
              onSelect: (tab) => setState(() => _tab = tab),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<SubjectDetailsCubit, SubjectDetailsState>(
              builder: (context, state) => switch (state.status) {
                SubjectDetailsStatus.failure => ErrorView(
                    message: state.error,
                    onRetry: () => context.read<SubjectDetailsCubit>().load(widget.subjectId),
                  ),
                SubjectDetailsStatus.success => _tabView(state.details!),
                _ => const LoadingView(),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabView(SubjectDetails details) {
    final course = details.course;
    final List<Widget> cards;
    final String empty;
    switch (_tab) {
      case _Tab.content:
        cards = [
          if (_matches([course.title, course.subjectName, course.instructor]))
            CourseContentCard(course: course, pointsCount: details.pointsCount),
        ];
        empty = AppStrings.noCourses;
      case _Tab.exams:
        cards = [
          for (final exam in details.exams)
            if (_matches([exam.title, exam.instructor])) ExamContentCard(exam: exam, icon: AppAssets.icQuiz),
        ];
        empty = AppStrings.noSubjectExams;
      case _Tab.activities:
        cards = [
          for (final activity in details.activities)
            if (_matches([activity.title, activity.instructor]))
              ExamContentCard(exam: activity, icon: AppAssets.icActivity),
        ];
        empty = AppStrings.noSubjectActivities;
    }
    if (cards.isEmpty) return EmptyView(message: _query.trim().isEmpty ? empty : AppStrings.noMatches);
    return ListView.separated(
      padding: EdgeInsetsDirectional.fromSTEB(17, 0, 16, MediaQuery.paddingOf(context).bottom + 24),
      itemCount: cards.length,
      separatorBuilder: (_, _) => const SizedBox(height: 26),
      itemBuilder: (_, i) => cards[i],
    );
  }
}
