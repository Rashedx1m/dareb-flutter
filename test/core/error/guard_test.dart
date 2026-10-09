import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/exceptions.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/error/guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('يعيد النتيجة في Right عند النجاح', () async {
    expect(await guard(() async => 42), const Right<Failure, int>(42));
  });

  test('يحوّل كل استثناء بيانات إلى Failure المقابل برسالته', () async {
    expect(
      await guard<int>(() async => throw const ServerException('الخادم متوقف')),
      const Left<Failure, int>(ServerFailure('الخادم متوقف')),
    );
    expect(
      await guard<int>(() async => throw const CacheException()),
      const Left<Failure, int>(CacheFailure()),
    );
    expect(
      await guard<int>(() async => throw const AuthException('انتهت الجلسة')),
      const Left<Failure, int>(AuthFailure('انتهت الجلسة')),
    );
  });

  test('أي استثناء آخر يصير ServerFailure عاماً بدل أن يُعلّق الشاشة', () async {
    expect(
      await guard<int>(() async => throw const FormatException('bad prefs')),
      const Left<Failure, int>(ServerFailure('حدث خطأ غير متوقع')),
    );
  });

  test('لا يبتلع الأخطاء البرمجية غير المتوقعة', () {
    expect(guard<int>(() async => throw StateError('bug')), throwsStateError);
  });
}
