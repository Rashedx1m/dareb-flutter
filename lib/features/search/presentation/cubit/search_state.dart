part of 'search_cubit.dart';

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
