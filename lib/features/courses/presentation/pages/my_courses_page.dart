import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/course_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../cubit/my_courses_cubit.dart';

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myCourses)),
      body: BlocBuilder<MyCoursesCubit, MyCoursesState>(
        builder: (context, state) {
          return switch (state.status) {
            MyCoursesStatus.initial || MyCoursesStatus.loading => const LoadingView(),
            MyCoursesStatus.failure => ErrorView(
                message: state.error,
                onRetry: () => context.read<MyCoursesCubit>().load(),
              ),
            MyCoursesStatus.success when state.courses.isEmpty => const EmptyView(message: AppStrings.noMyCourses),
            MyCoursesStatus.success => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.courses.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, i) {
                  final course = state.courses[i];
                  return CourseCard(
                    course: course,
                    horizontal: true,
                    onTap: () => context.push('/courses/${course.id}'),
                  );
                },
              ),
          };
        },
      ),
    );
  }
}
