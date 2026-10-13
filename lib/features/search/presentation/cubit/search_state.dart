part of 'search_cubit.dart';

/// `idle` قبل الكتابة أو بعد مسح النص.
enum SearchStatus { idle, loading, success, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.idle,
    this.query = '',
    this.results = SearchResults.empty,
    this.error,
  });

  final SearchStatus status;
  final String query;
  final SearchResults results;

  /// يُعرض فقط مع `failure`.
  final String? error;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    SearchResults? results,
    String? error,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, query, results, error];
}
