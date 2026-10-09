import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/network/api_client.dart';
import 'package:educational_app/features/subscription/data/datasources/subscription_remote_data_source.dart';
import 'package:educational_app/features/subscription/data/models/payment_method_model.dart';
import 'package:educational_app/features/subscription/data/models/subscription_package_model.dart';
import 'package:educational_app/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:educational_app/features/subscription/domain/entities/subscription_package.dart';
import 'package:educational_app/features/subscription/presentation/package_format.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http_adapter.dart';

/// رد `payment-methods/all` كما أعاده خادم التدريب في 2026-10-03.
const _methodsJson = [
  {
    'id': 1,
    'name': 'باسل',
    'phone': '0993571184',
    'governorate': 'دمشق',
    'method': 'الهرم',
    'image': 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
  },
];

/// شكل الباقة المتوقع (لا باقات على خادم التدريب بعد)، بمواد بشكل `subjects/all`.
const _packageJson = {
  'id': 1,
  'name': 'سنة واحدة',
  'description': 'لتحصل على جميع ميزات التطبيق',
  'price': 55000,
  'duration': 365,
  'subjects': [
    {'id': 16, 'name': 'Chemistry', 'image': 'https://x/7.png', 'is_free': false},
  ],
};

void main() {
  group('القراءة', () {
    test('الباقة بكل حقولها ومعها موادها', () {
      expect(
        SubscriptionPackageModel.fromJson(_packageJson),
        // Equatable يقارن النوع أيضاً، فالمتوقَّع Model لا Entity.
        const SubscriptionPackageModel(
          id: '1',
          name: 'سنة واحدة',
          description: 'لتحصل على جميع ميزات التطبيق',
          price: 55000,
          durationDays: 365,
          subjects: [PackageSubject(id: '16', name: 'Chemistry', imageUrl: 'https://x/7.png')],
        ),
      );
    });

    test('قراءة متسامحة: سعر ومدة نصيّان، و title بدل name، ولا مواد', () {
      final package = SubscriptionPackageModel.fromJson({'id': 2, 'title': 'مجاني', 'price': '0', 'days': '7'});

      expect(package.name, 'مجاني');
      expect(package.price, 0);
      expect(package.isFree, isTrue);
      expect(package.durationDays, 7);
      expect(package.subjects, isEmpty);
    });

    test('وكيل الدفع بشكل رد الخادم الفعلي: name اسم الوكيل وmethod الشركة', () {
      expect(
        PaymentMethodModel.fromJson(_methodsJson.first),
        const PaymentMethodModel(
          id: '1',
          method: 'الهرم',
          agentName: 'باسل',
          phone: '0993571184',
          governorate: 'دمشق',
          imageUrl: 'https://training.tamkeen-dev.com/dareb/public/assets/img/avatars/1.png',
        ),
      );
    });
  });

  group('مصدر البيانات والمستودع', () {
    late FakeHttpAdapter adapter;
    late SubscriptionRepositoryImpl repository;

    setUp(() {
      adapter = FakeHttpAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))..httpClientAdapter = adapter;
      repository = SubscriptionRepositoryImpl(
        SubscriptionRemoteDataSourceImpl(ApiClient(readToken: () => '30|abc', dio: dio)),
      );
    });

    test('الباقات من packages/all، والقائمة الفارغة ليست خطأً', () async {
      adapter.on('/packages/all', body: {'message': 'الباقات الموجودة', 'data': []});

      expect(await repository.getPackages(), isA<Right<Failure, List<SubscriptionPackage>>>());
      expect((await repository.getPackages()).getOrElse(() => [_dummy]), isEmpty);
    });

    test('مواد الباقة من packages/details?id=', () async {
      adapter.on('/packages/details', body: {'message': 'ok', 'data': _packageJson});

      final subjects = (await repository.getPackageSubjects('1')).getOrElse(() => []);

      expect(subjects.single.name, 'Chemistry');
      expect(adapter.requests.single.queryParameters, {'id': '1'});
    });

    test('باقة غير موجودة (404) تصل برسالة عربية', () async {
      adapter.on('/packages/details', status: 404, body: {'message': r'No query results for model [App\Models\Package] 9'});

      expect(
        await repository.getPackageSubjects('9'),
        const Left<Failure, List<PackageSubject>>(ServerFailure('المحتوى المطلوب غير موجود')),
      );
    });

    test('وكلاء الدفع من payment-methods/all', () async {
      adapter.on('/payment-methods/all', body: {'message': 'المعلومات الموجودة', 'data': _methodsJson});

      final methods = (await repository.getPaymentMethods()).getOrElse(() => []);

      expect(methods.single.method, 'الهرم');
    });

    test('التفعيل يرسل الكود منظّفاً إلى subscriptions/add', () async {
      adapter.on('/subscriptions/add', body: {'message': 'تمت العملية بنجاح', 'data': []});

      expect((await repository.subscribeWithCode('  cXJBj6 ')).isRight(), isTrue);
      expect(formFields(adapter.requests.single), {'code': 'cXJBj6'});
    });

    test('كود فارغ يُرفض دون الاتصال بالخادم، والكود الخاطئ برسالة الخادم', () async {
      expect(
        await repository.subscribeWithCode('   '),
        const Left<Failure, void>(ValidationFailure(AppStrings.errorCodeRequired)),
      );
      expect(adapter.requests, isEmpty);

      adapter.on('/subscriptions/add', status: 422, body: {
        'message': 'الحقل الكود لاغٍ',
        'errors': {
          'code': ['الحقل الكود لاغٍ'],
        },
      });
      expect(
        await repository.subscribeWithCode('ZZZZZZ'),
        const Left<Failure, void>(ValidationFailure('الحقل الكود لاغٍ')),
      );
    });
  });

  group('تنسيق السعر', () {
    test('الآلاف الكاملة بكلمة «ألف»، والكسور بخانتين', () {
      expect(formatPrice(55000), '55 ألف');
      expect(formatPrice(255.55), '255.55');
      expect(formatPrice(1500), '1500');
      expect(formatPrice(0), '0');
    });

    test('سعر الباقة مع مدتها، والمجانية «تجربة»', () {
      expect(packagePriceLabel(const SubscriptionPackage(id: '1', name: 'x', price: 55000, durationDays: 365)), '55 ألف ل.س/ سنة');
      expect(packagePriceLabel(const SubscriptionPackage(id: '2', name: 'x', price: 0, durationDays: 7)), '0 ل.س/ 7 أيام تجربة');
      expect(packagePriceLabel(const SubscriptionPackage(id: '3', name: 'x', price: 9000)), '9 ألف ل.س');
    });
  });
}

const _dummy = SubscriptionPackage(id: '0', name: '', price: 0);
