import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/courses/domain/entities/subject.dart';
import 'package:educational_app/features/courses/domain/repositories/courses_repository.dart';
import 'package:educational_app/features/courses/domain/usecases/search_subjects.dart';
import 'package:educational_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _subject = Subject(id: '1', name: 'ناردين الشطناوي', imageUrl: 'x', isFree: false, isSubscribed: false);

/// كل نص يُرد عليه بما يُضبط له، أو بالمادة إن لم يُضبط.
class _FakeRepository extends Fake implements CoursesRepository {
  final responses = <String, Completer<Either<Failure, List<Subject>>>>{};
  final queries = <String>[];

  @override
  Future<Either<Failure, List<Subject>>> searchSubjects(String query) {
    queries.add(query);
    final response = responses[query];
    return response == null ? Future.value(const Right([_subject])) : response.future;
  }
}

void main() {
  late _FakeRepository repository;
  late SearchCubit cubit;

  setUp(() {
    repository = _FakeRepository();
    cubit = SearchCubit(SearchSubjects(repository));
  });

  test('يبدأ idle، ثم loading، ثم success بالمواد', () async {
    expect(cubit.state, const SearchState());

    final states = expectLater(
      cubit.stream,
      emitsInOrder([
        const SearchState(status: SearchStatus.loading, query: 'نار'),
        const SearchState(status: SearchStatus.success, query: 'نار', results: [_subject]),
      ]),
    );
    await cubit.search('نار');
    await states;
  });

  test('مسح النص يعيد idle دون طلب', () async {
    await cubit.search('نار');

    await cubit.search('  ');

    expect(cubit.state, const SearchState(query: '  '));
    expect(repository.queries, ['نار']);
  });

  test('ردّ متأخر لنص سابق لا يغطي نتيجة النص الأحدث', () async {
    final slow = Completer<Either<Failure, List<Subject>>>();
    repository.responses['ن'] = slow;

    final first = cubit.search('ن');
    await cubit.search('نار');
    slow.complete(const Right([]));
    await first;

    expect(cubit.state, const SearchState(status: SearchStatus.success, query: 'نار', results: [_subject]));
  });

  test('الفشل يصل برسالته، وإعادة المحاولة تبحث بالنص نفسه وتمسحها', () async {
    repository.responses['نار'] = Completer()..complete(const Left(ServerFailure('تعذّر الاتصال')));
    await cubit.search('نار');
    expect(cubit.state, const SearchState(status: SearchStatus.failure, query: 'نار', error: 'تعذّر الاتصال'));

    repository.responses.remove('نار');
    await cubit.retry();

    expect(cubit.state, const SearchState(status: SearchStatus.success, query: 'نار', results: [_subject]));
  });

  test('إغلاق الصفحة قبل وصول الرد لا يرمي خطأ', () async {
    final response = Completer<Either<Failure, List<Subject>>>();
    repository.responses['نار'] = response;

    final searching = cubit.search('نار');
    await cubit.close();
    response.complete(const Right([_subject]));

    await expectLater(searching, completes);
  });
}
