import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../courses/domain/entities/subject.dart';
import '../cubit/search_cubit.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.searchTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: AppStrings.search,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: context.read<SearchCubit>().search,
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) => switch (state.status) {
                SearchStatus.idle => const Center(child: Text(AppStrings.searchPrompt)),
                SearchStatus.loading => const LoadingView(),
                SearchStatus.failure => ErrorView(message: state.error, onRetry: context.read<SearchCubit>().retry),
                SearchStatus.success when state.results.isEmpty =>
                  const EmptyView(message: AppStrings.noSearchResults, icon: PhosphorIconsRegular.magnifyingGlass),
                SearchStatus.success => _Results(subjects: state.results),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.subjects});

  final List<Subject> subjects;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: subjects.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, i) {
        final subject = subjects[i];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: subject.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              placeholder: (_, _) => const _ImageFallback(),
              errorWidget: (_, _, _) => const _ImageFallback(),
            ),
          ),
          title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          trailing: const Icon(Icons.chevron_left),
          // دورة المادة تحمل معرّف المادة نفسه.
          onTap: () => context.push('/courses/${subject.id}'),
        );
      },
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 56,
      height: 56,
      child: ColoredBox(
        color: AppColors.primarySoft,
        child: Icon(PhosphorIconsRegular.bookOpen, color: AppColors.primary),
      ),
    );
  }
}
