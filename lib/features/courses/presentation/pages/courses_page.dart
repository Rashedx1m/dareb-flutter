import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/course_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/course.dart';
import '../cubit/courses_cubit.dart';

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
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) => switch (state.status) {
          CoursesStatus.failure => ErrorView(message: state.error, onRetry: context.read<CoursesCubit>().load),
          CoursesStatus.success when state.courses.isEmpty => const EmptyView(message: AppStrings.noCourses),
          CoursesStatus.success => _CoursesGrid(courses: state.courses),
          _ => const LoadingView(),
        },
      ),
    );
  }
}

class _CoursesGrid extends StatelessWidget {
  const _CoursesGrid({required this.courses});

  final List<Course> courses;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: courses.length,
      itemBuilder: (context, i) {
        final course = courses[i];
        return CourseCard(
          course: course,
          onTap: () => context.push('/courses/${course.id}'),
        );
      },
    );
  }
}
