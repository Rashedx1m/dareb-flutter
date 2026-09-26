import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/courses_bloc.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key, this.initialId});

  final String? initialId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.categories)),
      body: BlocBuilder<CoursesBloc, CoursesState>(
        builder: (context, state) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.15,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.categories.length,
            itemBuilder: (context, i) {
              final cat = state.categories[i];
              final selected = initialId == cat.id;
              return InkWell(
                onTap: () {
                  context.read<CoursesBloc>().add(CoursesCategoryFiltered(cat.id));
                  context.go('/courses');
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primarySoft : AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.category_outlined, color: AppColors.primary, size: 32),
                      const SizedBox(height: 8),
                      Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text('${cat.coursesCount} دورة', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
