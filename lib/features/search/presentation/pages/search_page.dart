import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../cubit/search_cubit.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('البحث')),
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
              builder: (context, state) {
                if (state.status == SearchStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.results.isEmpty) {
                  return const Center(child: Text('ابدأ البحث عن دورة أو مادة'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.results.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, i) {
                    final subject = state.results[i];
                    return ListTile(
                      title: Text(subject.name),
                      onTap: () => context.push('/courses/${subject.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
