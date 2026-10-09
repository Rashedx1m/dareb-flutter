import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/di/injection.dart';
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
import 'package:educational_app/features/subscription/presentation/pages/checkout_page.dart';
import 'package:educational_app/features/subscription/presentation/pages/subscription_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _year = SubscriptionPackage(
  id: '1',
  name: 'سنة واحدة',
  description: 'لتحصل على جميع ميزات التطبيق',
  price: 55000,
  durationDays: 365,
);
const _haram = PaymentMethod(
  id: '1',
  method: 'الهرم',
  agentName: 'باسل',
  phone: '0993571184',
  governorate: 'دمشق',
);

class _FakeRepository implements SubscriptionRepository {
  String? activatedCode;

  @override
  Future<Either<Failure, List<SubscriptionPackage>>> getPackages() async => const Right([_year]);

  @override
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods() async => const Right([_haram]);

  @override
  Future<Either<Failure, List<PackageSubject>>> getPackageSubjects(String packageId) async => const Right([
        PackageSubject(id: '16', name: 'Chemistry'),
        PackageSubject(id: '17', name: 'English'),
      ]);

  @override
  Future<Either<Failure, void>> subscribeWithCode(String code) async {
    activatedCode = code;
    return const Right(null);
  }
}

void main() {
  late _FakeRepository repository;

  setUp(() {
    repository = _FakeRepository();
    sl.registerFactory(() => PackageSubjectsCubit(GetPackageSubjects(repository)));
  });
  tearDown(sl.reset);

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view
      // خط الاختبار يعطي كل حرف عرضاً يساوي حجمه، فالنص العربي أعرض منه على الجهاز.
      ..physicalSize = const Size(1800, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/start',
      routes: [
        GoRoute(path: '/start', builder: (_, _) => const Scaffold(body: Text('start'))),
        GoRoute(
          path: '/subscription',
          builder: (_, _) => BlocProvider(
            create: (_) => SubscriptionCubit(
              getPackages: GetPackages(repository),
              subscribeWithCode: SubscribeWithCode(repository),
            )..load(),
            child: const SubscriptionPage(),
          ),
        ),
        GoRoute(
          path: '/checkout',
          builder: (_, state) => BlocProvider(
            create: (_) => CheckoutCubit(
              getPackages: GetPackages(repository),
              getPaymentMethods: GetPaymentMethods(repository),
            )..load(state.uri.queryParameters['package']),
            child: const CheckoutPage(),
          ),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.push('/subscription');
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('الباقة الأولى مختارة بسعرها، والتفاصيل تعرض موادها', (tester) async {
    await pumpApp(tester);

    expect(find.text('سنة واحدة'), findsOneWidget);
    expect(find.text('55 ألف ل.س/ سنة'), findsOneWidget);

    await tap(tester, find.text(AppStrings.packageDetails));
    expect(find.text(AppStrings.availableSubjects), findsOneWidget);
    expect(find.text('Chemistry'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('الباقة ← إتمام الشراء ← تفاصيل الوكيل ← العودة لإدخال الكود وتفعيله', (tester) async {
    await pumpApp(tester);

    await tap(tester, find.text(AppStrings.subscribe));
    expect(find.text(AppStrings.choosePaymentMethod), findsOneWidget);
    expect(find.text('الهرم'), findsOneWidget);
    expect(find.text(AppStrings.cashWithAdmin), findsOneWidget);
    expect(find.text('55 ألف ل.س'), findsOneWidget);

    await tap(tester, find.widgetWithText(ElevatedButton, AppStrings.checkout));
    expect(find.text(AppStrings.paymentDetails), findsOneWidget);
    expect(find.text('باسل'), findsOneWidget);
    expect(find.text('0993571184'), findsOneWidget);

    await tap(tester, find.text(AppStrings.enterCode));
    // عادت صفحة الاشتراكات وقد اختارت خانة الكود الأولى.
    expect(find.text(AppStrings.choosePaymentMethod), findsNothing);
    await tester.enterText(find.widgetWithText(TextField, AppStrings.codeForSubject), ' cXJBj6 ');
    await tap(tester, find.text(AppStrings.subscribe));

    expect(repository.activatedCode, ' cXJBj6 ');
    expect(find.text(AppStrings.subscriptionActivated), findsOneWidget);
    expect(find.text('start'), findsOneWidget);
  });

  testWidgets('الدفع نقداً يعرض تعليمات التواصل مع الإدارة', (tester) async {
    await pumpApp(tester);

    await tap(tester, find.text(AppStrings.subscribe));
    await tap(tester, find.text(AppStrings.cashWithAdmin));
    await tap(tester, find.widgetWithText(ElevatedButton, AppStrings.checkout));

    expect(find.text('ادفع مبلغ 55 ألف ل.س نقداً للإدارة.'), findsOneWidget);
    expect(find.text(AppStrings.cashInstructions), findsOneWidget);
  });
}
