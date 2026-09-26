import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/usecases/get_courses.dart';

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
    result.fold(
      (f) => emit(state.copyWith(status: SearchStatus.failure, error: f.message)),
      (list) => emit(state.copyWith(status: SearchStatus.success, results: list)),
    );
  }
}

enum SearchStatus { idle, loading, success, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.idle,
    this.query = '',
    this.results = const [],
    this.error,
  });

  final SearchStatus status;
  final String query;
  final List<Course> results;
  final String? error;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Course>? results,
    String? error,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, query, results, error];
}
