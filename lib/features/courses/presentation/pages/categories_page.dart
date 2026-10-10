import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/subject.dart';
import '../cubit/subjects_cubit.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key, this.initialId});

  final String? initialId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.categories)),
      body: BlocBuilder<SubjectsCubit, SubjectsState>(
        builder: (context, state) => switch (state.status) {
          SubjectsStatus.failure =>
            ErrorView(message: state.error, onRetry: context.read<SubjectsCubit>().load),
          SubjectsStatus.success when state.subjects.isEmpty => const EmptyView(message: AppStrings.noSubjects),
          SubjectsStatus.success => _SubjectsGrid(subjects: state.subjects, selectedId: initialId),
          _ => const LoadingView(),
        },
      ),
    );
  }
}

class _SubjectsGrid extends StatelessWidget {
  const _SubjectsGrid({required this.subjects, required this.selectedId});

  final List<Subject> subjects;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.15,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, i) {
        final subject = subjects[i];
        final selected = selectedId == subject.id;
        return InkWell(
          // دورة المادة تحمل معرّف المادة نفسه.
          onTap: () => context.push('/courses/${subject.id}'),
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
                Text(subject.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        );
      },
    );
  }
}
