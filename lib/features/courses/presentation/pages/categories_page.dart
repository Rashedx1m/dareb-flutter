import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/subject.dart';
import '../cubit/subjects_cubit.dart';

/// «كل الفئات»: المواد على ثلاثة أعمدة، لكل مادة زر باسمها وصورتها تحته. الضغط
/// يفتح صفحة المادة بتبويباتها.
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PageHeader(
            title: AppStrings.allCategories,
            onBack: () => Navigator.of(context).maybePop(),
            onNotifications: () => context.push('/notifications'),
          ),
          Expanded(
            child: BlocBuilder<SubjectsCubit, SubjectsState>(
              builder: (context, state) => switch (state.status) {
                SubjectsStatus.failure =>
                  ErrorView(message: state.error, onRetry: context.read<SubjectsCubit>().load),
                SubjectsStatus.success when state.subjects.isEmpty => const EmptyView(message: AppStrings.noSubjects),
                SubjectsStatus.success => _SubjectsGrid(subjects: state.subjects),
                _ => const LoadingView(),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectsGrid extends StatelessWidget {
  const _SubjectsGrid({required this.subjects});

  final List<Subject> subjects;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(15, 29, 15, MediaQuery.paddingOf(context).bottom + 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 23,
        mainAxisExtent: 118,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, i) => _SubjectTile(subject: subjects[i]),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/categories/${subject.id}'),
      borderRadius: BorderRadius.circular(10),
      child: Column(
        children: [
          Container(
            height: 40,
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: AppColors.accentBlue, borderRadius: BorderRadius.circular(10)),
            child: Text(
              subject.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 64,
            child: CachedNetworkImage(
              imageUrl: subject.imageUrl,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => const Icon(PhosphorIconsFill.bookOpen, color: AppColors.iconBlue, size: 44),
            ),
          ),
        ],
      ),
    );
  }
}
