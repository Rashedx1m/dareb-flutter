import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/course_card.dart';
import '../bloc/courses_bloc.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.courses),
        actions: [
          IconButton(onPressed: () => context.push('/search'), icon: const Icon(Icons.search)),
        ],
      ),
      body: BlocBuilder<CoursesBloc, CoursesState>(
        builder: (context, state) {
          if (state.status == CoursesStatus.loading && state.filtered.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              SizedBox(
                height: 46,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _Chip(
                      label: 'الكل',
                      selected: state.selectedCategoryId == null,
                      onTap: () => context.read<CoursesBloc>().add(const CoursesCategoryFiltered(null)),
                    ),
                    ...state.subjects.map(
                      (c) => _Chip(
                        label: c.name,
                        selected: state.selectedCategoryId == c.id,
                        onTap: () => context.read<CoursesBloc>().add(CoursesCategoryFiltered(c.id)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: state.filtered.length,
                  itemBuilder: (context, i) {
                    final course = state.filtered[i];
                    return CourseCard(
                      course: course,
                      onTap: () => context.push('/courses/${course.id}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
