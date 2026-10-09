import 'package:dartz/dartz.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/subscription/domain/entities/payment_method.dart';
import 'package:educational_app/features/subscription/domain/entities/subscription_package.dart';
import 'package:educational_app/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:educational_app/features/subscription/domain/usecases/get_package_subjects.dart';
import 'package:educational_app/features/subscription/domain/usecases/get_packages.dart';
import 'package:educational_app/features/subscription/domain/usecases/get_payment_methods.dart';
import 'package:educational_app/features/subscription/domain/usecases/subscribe_with_code.dart';
import 'package:educational_app/features/subscription/presentation/cubit/checkout_cubit.dart';
import 'package:educational_app/features/subscription/presentation/cubit/package_subjects_cubit.dart';
import 'package:educational_app/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _year = SubscriptionPackage(id: '1', name: 'سنة واحدة', price: 55000, durationDays: 365);
const _free = SubscriptionPackage(id: '2', name: 'مجاني', price: 0, durationDays: 7);
const _haram = PaymentMethod(id: '1', method: 'الهرم', agentName: 'باسل', phone: '0993571184');

class _FakeRepository implements SubscriptionRepository {
  _FakeRepository({
    this.packages = const Right([_year, _free]),
    this.methods = const Right([_haram]),
    this.activation = const Right(null),
  });

  final Either<Failure, List<SubscriptionPackage>> packages;
  final Either<Failure, List<PaymentMethod>> methods;
  final Either<Failure, void> activation;
  String? activatedCode;

  @override
  Future<Either<Failure, List<SubscriptionPackage>>> getPackages() async => packages;

  @override
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods() async => methods;

  @override
  Future<Either<Failure, List<PackageSubject>>> getPackageSubjects(String packageId) async =>
      const Right([PackageSubject(id: '16', name: 'Chemistry')]);

  @override
  Future<Either<Failure, void>> subscribeWithCode(String code) async {
    activatedCode = code;
    return activation;
  }
}

SubscriptionCubit _subscription(_FakeRepository repository) =>
    SubscriptionCubit(getPackages: GetPackages(repository), subscribeWithCode: SubscribeWithCode(repository));

CheckoutCubit _checkout(_FakeRepository repository) =>
    CheckoutCubit(getPackages: GetPackages(repository), getPaymentMethods: GetPaymentMethods(repository));

void main() {
  group('SubscriptionCubit', () {
    test('يختار أول باقة كما في التصميم', () async {
      final cubit = _subscription(_FakeRepository());
      await cubit.load();

      expect(cubit.state.status, PackagesStatus.success);
      expect(cubit.state.selectedPackageId, '1');
      expect(cubit.state.selectedCode, isNull);
    });

    test('بلا باقات تُختار خانة الكود الأولى', () async {
      final cubit = _subscription(_FakeRepository(packages: const Right([])));
      await cubit.load();

      expect(cubit.state.selectedPackageId, isNull);
      expect(cubit.state.selectedCode, CodeOption.subjectOrCurriculum);
    });

    test('اختيار كود يلغي الباقة، واختيار باقة يلغي الكود', () async {
      final cubit = _subscription(_FakeRepository());
      await cubit.load();

      cubit.selectCode(CodeOption.multipleSubjects);
      expect((cubit.state.selectedPackageId, cubit.state.selectedCode), (null, CodeOption.multipleSubjects));

      cubit.selectPackage('2');
      expect((cubit.state.selectedPackageId, cubit.state.selectedCode), ('2', null));
    });

    test('التفعيل: sending ثم done، والفشل برسالة الخادم', () async {
      final repository = _FakeRepository();
      final cubit = _subscription(repository);

      final statuses = cubit.stream.map((s) => s.activation).take(2).toList();
      await cubit.activate('cXJBj6');
      expect(await statuses, [ActivationStatus.sending, ActivationStatus.done]);
      expect(repository.activatedCode, 'cXJBj6');

      final failing = _subscription(_FakeRepository(activation: const Left(ValidationFailure('الحقل الكود لاغٍ'))));
      await failing.activate('ZZZZZZ');
      expect(failing.state.activation, ActivationStatus.failure);
      expect(failing.state.activationError, 'الحقل الكود لاغٍ');
    });

    test('فشل تحميل الباقات يضبط failure', () async {
      final cubit = _subscription(_FakeRepository(packages: const Left(ServerFailure('تعذّر الاتصال'))));
      await cubit.load();

      expect(cubit.state.status, PackagesStatus.failure);
      expect(cubit.state.error, 'تعذّر الاتصال');
    });
  });

  group('CheckoutCubit', () {
    test('يجد الباقة بمعرّفها ويختار أول وكيل', () async {
      final cubit = _checkout(_FakeRepository());
      await cubit.load('1');

      expect(cubit.state.status, CheckoutStatus.success);
      expect(cubit.state.package, _year);
      expect(cubit.state.selectedMethod, _haram);
    });

    test('بلا وكلاء يُختار الدفع نقداً', () async {
      final cubit = _checkout(_FakeRepository(methods: const Right([])));
      await cubit.load('1');

      expect(cubit.state.selectedMethodId, CheckoutState.cashId);
      expect(cubit.state.selectedMethod, isNull);
    });

    test('اختيار الدفع نقداً ثم وكيل', () async {
      final cubit = _checkout(_FakeRepository());
      await cubit.load('1');

      cubit.selectMethod(CheckoutState.cashId);
      expect(cubit.state.selectedMethod, isNull);
      cubit.selectMethod('1');
      expect(cubit.state.selectedMethod, _haram);
    });

    test('باقة غير موجودة أو فشل أحد الطلبين يضبط failure، وretry يعيد التحميل', () async {
      final cubit = _checkout(_FakeRepository());
      await cubit.load('99');
      expect(cubit.state.status, CheckoutStatus.failure);

      final failing = _checkout(_FakeRepository(methods: const Left(ServerFailure('x'))));
      await failing.load('1');
      expect(failing.state.status, CheckoutStatus.failure);
      expect(failing.state.error, 'x');

      await cubit.retry();
      expect(cubit.state.status, CheckoutStatus.failure);
    });
  });

  test('PackageSubjectsCubit يحمّل مواد الباقة', () async {
    final cubit = PackageSubjectsCubit(GetPackageSubjects(_FakeRepository()));
    await cubit.load('1');

    expect(cubit.state.status, SubjectsStatus.success);
    expect(cubit.state.subjects.single.name, 'Chemistry');
  });
}
