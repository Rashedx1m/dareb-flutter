import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/usecases/search_courses.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._searchCourses) : super(const SearchState());

  final SearchCourses _searchCourses;

  Future<void> search(String query) async {
    emit(state.copyWith(query: query, status: SearchStatus.loading));
    if (query.trim().isEmpty) {
      emit(state.copyWith(status: SearchStatus.idle, results: const []));
      return;
    }
    final result = await _searchCourses(query);
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(status: SearchStatus.failure, error: f.message)),
      (list) => emit(state.copyWith(status: SearchStatus.success, results: list)),
    );
  }
}
