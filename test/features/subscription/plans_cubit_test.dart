import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/subscription/domain/entities/plan.dart';
import 'package:educational_app/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:educational_app/features/subscription/domain/usecases/get_plans.dart';
import 'package:educational_app/features/subscription/presentation/cubit/plans_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _monthly = Plan(id: 'monthly', name: 'شهري', price: 49, period: 'شهرياً', features: []);
const _yearly = Plan(
  id: 'yearly',
  name: 'سنوي',
  price: 399,
  period: 'سنوياً',
  features: [],
  highlighted: true,
);

class _FakeSubscriptionRepository implements SubscriptionRepository {
  _FakeSubscriptionRepository({this.plans = const [_monthly, _yearly], this.failure});

  final List<Plan> plans;
  final Failure? failure;

  @override
  Future<Either<Failure, List<Plan>>> getPlans() async =>
      failure != null ? Left(failure!) : Right(plans);
}

PlansCubit _cubit([_FakeSubscriptionRepository? repository]) =>
    PlansCubit(GetPlans(repository ?? _FakeSubscriptionRepository()));

void main() {
  test('يختار الباقة المميّزة افتراضياً', () async {
    final cubit = _cubit();
    await cubit.load();

    expect(cubit.state.status, PlansStatus.success);
    expect(cubit.state.selected, _yearly);
  });

  test('يختار الباقة المطلوبة إن وُجدت', () async {
    final cubit = _cubit();
    await cubit.load(preferredId: 'monthly');

    expect(cubit.state.selected, _monthly);
  });

  test('يتجاهل معرّفاً غير موجود ويعود للباقة المميّزة', () async {
    final cubit = _cubit();
    await cubit.load(preferredId: 'weekly');

    expect(cubit.state.selected, _yearly);
  });

  test('يختار الأولى إن لم تُميَّز أي باقة', () async {
    final cubit = _cubit(_FakeSubscriptionRepository(plans: const [_monthly]));
    await cubit.load();

    expect(cubit.state.selected, _monthly);
  });

  test('select يغيّر الباقة المختارة', () async {
    final cubit = _cubit();
    await cubit.load();
    cubit.select('monthly');

    expect(cubit.state.selected, _monthly);
  });

  test('الفشل يضبط الحالة failure ويحمل الرسالة', () async {
    final cubit = _cubit(_FakeSubscriptionRepository(failure: const ServerFailure('خطأ')));
    await cubit.load();

    expect(cubit.state.status, PlansStatus.failure);
    expect(cubit.state.error, 'خطأ');
  });
}
