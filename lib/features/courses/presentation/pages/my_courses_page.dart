import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/course.dart';
import '../cubit/my_courses_cubit.dart';
import '../widgets/my_subject_card.dart';

enum _Tab { subjects, semesters, packages }

/// صفحة «موادي» في تبويب الكتب: بحث وثلاثة تبويبات. «المواد» من
/// `subscriptions/my`. الخادم لا يعيد فيه فصولاً ولا باقات، فتبويباهما فارغان.
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
            onNotifications: () => context.push('/notifications'),
            bottom: _SearchField(onChanged: (v) => setState(() => _query = v)),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _Tabs(selected: _tab, onSelect: (t) => setState(() => _tab = t)),
          ),
          const SizedBox(height: 18),
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
          MyCoursesStatus.success => ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: courses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: AppStrings.searchHere,
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(PhosphorIconsRegular.magnifyingGlass, color: AppColors.iconBlue, size: 22),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.selected, required this.onSelect});

  final _Tab selected;
  final ValueChanged<_Tab> onSelect;

  static const _labels = {
    _Tab.subjects: AppStrings.subjects,
    _Tab.semesters: AppStrings.tabSemesters,
    _Tab.packages: AppStrings.tabPackages,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: AppColors.tabTrack, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          for (final tab in _Tab.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(tab),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tab == selected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _labels[tab]!,
                    style: TextStyle(
                      color: tab == selected ? Colors.white : AppColors.tabLabel,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
