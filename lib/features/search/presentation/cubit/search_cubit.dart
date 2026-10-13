import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../courses/domain/entities/search_results.dart';
import '../../../courses/domain/usecases/search_content.dart';

part 'search_state.dart';

/// صفحة البحث في المواد والاختبارات والنشاطات. الكتابة لا ترسل طلباً مع كل حرف: [queryChanged] ينتظر
/// توقف الكتابة [debounce] ثم يبحث.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._search, {this.debounce = const Duration(milliseconds: 400)})
      : super(const SearchState());

  final SearchContent _search;

  /// يُقصَّر في الاختبارات.
  final Duration debounce;
  Timer? _timer;

  /// مع كل تغيّر في حقل البحث. مسح النص يعيد الحالة فوراً بلا طلب.
  void queryChanged(String query) {
    _timer?.cancel();
    if (query.trim().isEmpty) {
      emit(SearchState(query: query));
      return;
    }
    _timer = Timer(debounce, () => search(query));
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchState(query: query));
      return;
    }
    emit(state.copyWith(query: query, status: SearchStatus.loading));
    final result = await _search(query);
    // ردّ متأخر لنص سابق (كتب المستخدم بعده) لا يُعرض.
    if (isClosed || state.query != query) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: SearchStatus.failure, error: f.message),
        (results) => state.copyWith(status: SearchStatus.success, results: results),
      ),
    );
  }

  Future<void> retry() => search(state.query);

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
