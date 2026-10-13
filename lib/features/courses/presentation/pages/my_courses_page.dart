import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/course.dart';
import '../cubit/my_courses_cubit.dart';
import '../widgets/my_subject_card.dart';
import '../widgets/outlined_search_field.dart';
import '../widgets/pill_tabs.dart';

enum _Tab { subjects, semesters, packages }

/// صفحة «موادي» في تبويب الكتب كما في التصميم: الترويسة، ثم حقل البحث، ثم ثلاثة
/// تبويبات منفصلة. «المواد» من `subscriptions/my`. الخادم لا يعيد فيه فصولاً ولا
/// باقات، فتبويباهما فارغان.
class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  _Tab _tab = _Tab.subjects;
  String _query = '';

  /// البحث حالة عرض محلية تُطبَّق على المواد المحمّلة في [MyCoursesCubit].
  List<Course> _filter(List<Course> courses) {
    final q = _query.trim();
    if (q.isEmpty) return courses;
    return [
      for (final c in courses)
        if (c.title.contains(q) || c.subjectName.contains(q) || c.instructor.contains(q)) c,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PageHeader(
            title: AppStrings.mySubjects,
            titleIcon: PhosphorIconsFill.books,
            onNotifications: () => context.push('/notifications'),
            short: true,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 17, 16, 21),
            child: OutlinedSearchField(onChanged: (v) => setState(() => _query = v)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PillTabs(
              tabs: const {
                _Tab.subjects: AppStrings.subjects,
                _Tab.semesters: AppStrings.tabSemesters,
                _Tab.packages: AppStrings.tabPackages,
              },
              selected: _tab,
              onSelect: (t) => setState(() => _tab = t),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              _Tab.subjects => _SubjectsTab(filter: _filter, searching: _query.trim().isNotEmpty),
              _Tab.semesters => const EmptyView(message: AppStrings.noMySemesters),
              _Tab.packages => const EmptyView(message: AppStrings.noMyPackages),
            },
          ),
        ],
      ),
    );
  }
}

class _SubjectsTab extends StatelessWidget {
  const _SubjectsTab({required this.filter, required this.searching});

  final List<Course> Function(List<Course>) filter;
  final bool searching;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyCoursesCubit, MyCoursesState>(
      builder: (context, state) {
        final courses = filter(state.courses);
        return switch (state.status) {
          MyCoursesStatus.initial || MyCoursesStatus.loading => const LoadingView(),
          MyCoursesStatus.failure => ErrorView(
              message: state.error,
              onRetry: () => context.read<MyCoursesCubit>().load(),
            ),
          MyCoursesStatus.success when courses.isEmpty =>
            EmptyView(message: searching ? AppStrings.noSearchResults : AppStrings.noMyCourses),
          // الظل يحتاج مساحة حول البطاقات، فالمسافة العلوية داخل القائمة لا فوقها.
          MyCoursesStatus.success => ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              itemCount: courses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 28),
              itemBuilder: (context, i) {
                final course = courses[i];
                return MySubjectCard(
                  course: course,
                  onContinue: () => context.push('/courses/${course.id}'),
                );
              },
            ),
        };
      },
    );
  }
}
