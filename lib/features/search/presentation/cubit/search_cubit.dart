import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../courses/domain/entities/subject.dart';
import '../../../courses/domain/usecases/search_subjects.dart';

part 'search_state.dart';

/// صفحة البحث في المواد، يُطلب مع كل تغيّر في النص.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._searchSubjects) : super(const SearchState());

  final SearchSubjects _searchSubjects;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchState(query: query));
      return;
    }
    emit(state.copyWith(query: query, status: SearchStatus.loading));
    final result = await _searchSubjects(query);
    // ردّ متأخر لنص سابق (كتب المستخدم بعده) لا يُعرض.
    if (isClosed || state.query != query) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: SearchStatus.failure, error: f.message),
        (subjects) => state.copyWith(status: SearchStatus.success, results: subjects),
      ),
    );
  }

  Future<void> retry() => search(state.query);
}
