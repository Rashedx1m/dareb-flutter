import 'package:dartz/dartz.dart';

import 'exceptions.dart';
import 'failures.dart';

/// ينفّذ استدعاء مصدر البيانات ويحوّل استثناءاته إلى [Failure]، حتى لا يتكرر
/// `try/catch` في كل دالة من دوال المستودعات.
Future<Either<Failure, T>> guard<T>(Future<T> Function() action) async {
  try {
    return Right(await action());
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on CacheException catch (e) {
    return Left(CacheFailure(e.message));
  } on AuthException catch (e) {
    return Left(AuthFailure(e.message));
  } on ValidationException catch (e) {
    return Left(ValidationFailure(e.message));
  }
}
