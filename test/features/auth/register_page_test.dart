import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/auth/domain/entities/lookup_option.dart';
import 'package:educational_app/features/auth/domain/entities/registration_details.dart';
import 'package:educational_app/features/auth/domain/entities/user.dart';
import 'package:educational_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:educational_app/features/auth/domain/repositories/registration_options_repository.dart';
import 'package:educational_app/features/auth/domain/usecases/get_registration_options.dart';
import 'package:educational_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:educational_app/features/auth/domain/usecases/request_otp_usecase.dart';
import 'package:educational_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:educational_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:educational_app/features/auth/presentation/cubit/registration_options_cubit.dart';
import 'package:educational_app/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository extends Fake implements AuthRepository {
  RegistrationDetails? submitted;

  @override
  Future<Either<Failure, User>> register(RegistrationDetails details) async {
    submitted = details;
    return const Right(User(id: '30', name: 'Rashed Eybo', phone: '0930000000'));
  }
}

class _FakeOptionsRepository implements RegistrationOptionsRepository {
  final schoolQueries = <(SchoolKind?, String?)>[];

  @override
  Future<Either<Failure, List<LookupOption>>> getGovernorates() async => const Right([
        LookupOption(id: 'damascus', name: 'دمشق'),
        LookupOption(id: 'aleppo', name: 'حلب'),
      ]);

  @override
  Future<Either<Failure, List<LookupOption>>> getBranches() async =>
      const Right([LookupOption(id: '1', name: 'علمي'), LookupOption(id: '2', name: 'أدبي')]);

  @override
  Future<Either<Failure, List<LookupOption>>> getSchools({
    SchoolKind? kind,
    String? governorateId,
  }) async {
    schoolQueries.add((kind, governorateId));
    return Right(governorateId == 'damascus' ? const [LookupOption(id: '7', name: 'مدرسة يامن')] : const []);
  }
}

void main() {
  late _FakeAuthRepository auth;
  late _FakeOptionsRepository options;

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view
      // خط الاختبار يعطي كل حرف عرضاً يساوي حجمه، فالنص العربي أعرض منه على الجهاز.
      ..physicalSize = const Size(1800, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    auth = _FakeAuthRepository();
    options = _FakeOptionsRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => AuthCubit(
                requestOtpUseCase: RequestOtpUseCase(auth),
                registerUseCase: RegisterUseCase(auth),
                verifyOtpUseCase: VerifyOtpUseCase(auth),
              ),
            ),
            BlocProvider(
              create: (_) => RegistrationOptionsCubit(
                getGovernorates: GetGovernorates(options),
                getSchools: GetSchools(options),
                getBranches: GetBranches(options),
              )..load(),
            ),
          ],
          child: const RegisterPage(phone: '0930000000'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) => tap(tester, find.text(AppStrings.next));

  testWidgets('يُكمل التسجيل بمعرّفات المدرسة والفرع من الخادم', (tester) async {
    await pumpPage(tester);

    // البيانات الأساسية + الموافقة على الشروط.
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Rashed');
    await tester.enterText(fields.at(1), 'Eybo');
    await tester.enterText(fields.at(2), 'test@example.com');
    await next(tester);
    await tap(tester, find.text(AppStrings.termsAccept));
    await next(tester);

    await tap(tester, find.text(AppStrings.sourceFacebook));
    await next(tester);

    await tap(tester, find.text(AppStrings.schoolKindSchool));
    await next(tester);

    // خطوة المدرسة: لا مدارس قبل اختيار المحافظة.
    expect(find.text(AppStrings.pickGovernorateFirst), findsOneWidget);
    await tap(tester, find.widgetWithText(TextField, AppStrings.governorateHint));
    await tap(tester, find.text('دمشق'));
    expect(options.schoolQueries.last, (SchoolKind.school, 'damascus'));
    await tap(tester, find.text('مدرسة يامن'));
    await next(tester);

    await tap(tester, find.text(AppStrings.male));
    await next(tester);
    await next(tester); // العمر الافتراضي

    await tap(tester, find.text('أدبي'));
    await tap(tester, find.text(AppStrings.confirm));

    expect(find.text(AppStrings.congrats), findsOneWidget);
    expect(
      auth.submitted,
      const RegistrationDetails(
        firstName: 'Rashed',
        lastName: 'Eybo',
        email: 'test@example.com',
        source: AppSource.facebook,
        schoolId: '7',
        gender: Gender.male,
        age: 26,
        branchId: '2',
      ),
    );
  });

  testWidgets('محافظة بلا مدارس تعرض رسالة ولا تسمح بالمتابعة', (tester) async {
    await pumpPage(tester);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Rashed');
    await tester.enterText(fields.at(1), 'Eybo');
    await tester.enterText(fields.at(2), 'test@example.com');
    await next(tester);
    await tap(tester, find.text(AppStrings.termsAccept));
    await next(tester);
    await tap(tester, find.text(AppStrings.sourceFacebook));
    await next(tester);
    await tap(tester, find.text(AppStrings.schoolKindInstitute));
    await next(tester);

    await tap(tester, find.widgetWithText(TextField, AppStrings.governorateHint));
    await tap(tester, find.text('حلب'));

    expect(options.schoolQueries.last, (SchoolKind.institute, 'aleppo'));
    expect(find.text(AppStrings.noSchoolsFound), findsOneWidget);
    final nextButton = tester.widget<ElevatedButton>(
      find.ancestor(of: find.text(AppStrings.next), matching: find.byType(ElevatedButton)),
    );
    expect(nextButton.onPressed, isNull);
  });
}
