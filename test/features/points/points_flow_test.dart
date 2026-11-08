import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/widgets/error_view.dart';
import 'package:educational_app/features/points/domain/entities/point_record.dart';
import 'package:educational_app/features/points/domain/repositories/points_repository.dart';
import 'package:educational_app/features/points/domain/usecases/get_points_history.dart';
import 'package:educational_app/features/points/presentation/cubit/points_cubit.dart';
import 'package:educational_app/features/points/presentation/pages/points_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

final _exam = PointRecord(id: 'p1', points: 10, reason: 'إنهاء اختبار الرياضيات', date: DateTime(2026, 10, 30));
final _noReason = PointRecord(id: 'p2', points: 5, date: DateTime(2026, 10, 29));
const _noDate = PointRecord(id: 'p3', points: 5, reason: 'مشاهدة درس');

/// مستودع مزيّف يُرجع النتائج بالترتيب، نتيجة لكل طلب.
class _FakeRepository implements PointsRepository {
  _FakeRepository(this.results);
  final List<Either<Failure, List<PointRecord>>> results;

  @override
  Future<Either<Failure, List<PointRecord>>> getPointsHistory() async => results.removeAt(0);
}

Future<void> _pumpPage(WidgetTester tester, List<Either<Failure, List<PointRecord>>> results) async {
  tester.view
    // خط الاختبار يعطي كل حرف عرضاً يساوي حجمه، فالنص العربي أعرض منه على الجهاز.
    ..physicalSize = const Size(1800, 3600)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider(
        create: (_) => PointsCubit(GetPointsHistory(_FakeRepository(results)))..load(),
        child: const PointsPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('تعرض المجموع والسجل، ونصاً عاماً لسجل بلا سبب، ولا تاريخ لسجل بلا تاريخ', (tester) async {
    await _pumpPage(tester, [Right([_exam, _noReason, _noDate])]);

    expect(find.text('20'), findsOneWidget);
    expect(find.text('+10'), findsOneWidget);
    expect(find.text('إنهاء اختبار الرياضيات'), findsOneWidget);
    expect(find.text('30 أكتوبر 2026'), findsOneWidget);
    expect(find.text(AppStrings.pointsEarned), findsOneWidget);
    expect(find.text('29 أكتوبر 2026'), findsOneWidget);
    expect(find.text('مشاهدة درس'), findsOneWidget);
    expect(find.textContaining('2026'), findsNWidgets(2));
  });

  testWidgets('سجل فارغ يعرض رسالة الفراغ لا قائمة', (tester) async {
    await _pumpPage(tester, [const Right([])]);

    expect(find.text(AppStrings.noPointsYet), findsOneWidget);
    expect(find.text(AppStrings.pointsTotal), findsNothing);
  });

  testWidgets('الفشل يعرض رسالته، وإعادة المحاولة تحمّل السجل', (tester) async {
    await _pumpPage(tester, [const Left(ServerFailure('تعذّر الاتصال')), const Right([_noDate])]);

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('تعذّر الاتصال'), findsOneWidget);

    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsNothing);
    expect(find.text('مشاهدة درس'), findsOneWidget);
  });
}
