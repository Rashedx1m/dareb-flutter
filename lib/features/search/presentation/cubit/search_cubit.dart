import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../courses/domain/entities/subject.dart';
import '../../../courses/domain/usecases/search_subjects.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._searchSubjects) : super(const SearchState());

  final SearchSubjects _searchSubjects;

  Future<void> search(String query) async {
    emit(state.copyWith(query: query, status: SearchStatus.loading));
    if (query.trim().isEmpty) {
      emit(state.copyWith(status: SearchStatus.idle, results: const []));
      return;
    }
    final result = await _searchSubjects(query);
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(status: SearchStatus.failure, error: f.message)),
      (list) => emit(state.copyWith(status: SearchStatus.success, results: list)),
    );
  }
}
