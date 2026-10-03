import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/exceptions.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/network/api_client.dart';
import 'package:educational_app/features/support/data/datasources/support_remote_data_source.dart';
import 'package:educational_app/features/support/data/repositories/support_repository_impl.dart';
import 'package:educational_app/features/support/domain/entities/contact_links.dart';
import 'package:educational_app/features/support/domain/entities/contact_message.dart';
import 'package:educational_app/features/support/domain/usecases/send_contact_message.dart';
import 'package:educational_app/features/support/presentation/cubit/contact_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http_adapter.dart';

const _message = ContactMessage(
  firstName: ' Rashed ',
  lastName: 'Eybo',
  phone: '093 785-7596',
  text: ' التطبيق رائع ',
);

void main() {
  late FakeHttpAdapter adapter;
  late SupportRepositoryImpl repository;

  setUp(() {
    adapter = FakeHttpAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))..httpClientAdapter = adapter;
    repository = SupportRepositoryImpl(SupportRemoteDataSourceImpl(ApiClient(readToken: () => '30|abc', dio: dio)));
  });

  test('يرسل حقول contact-us/add بعد تنظيفها', () async {
    adapter.on('/contact-us/add', body: {'message': 'تم الإرسال', 'data': []});

    final result = await repository.sendContactMessage(_message);

    expect(result.isRight(), isTrue);
    expect(formFields(adapter.requests.single), {
      'f_name': 'Rashed',
      'l_name': 'Eybo',
      'phone': '0937857596',
      'text': 'التطبيق رائع',
    });
  });

  test('يرفض وصفاً فارغاً أو رقماً خاطئاً دون الاتصال بالخادم', () async {
    const noText = ContactMessage(firstName: 'a', lastName: 'b', phone: '0937857596', text: '  ');
    const badPhone = ContactMessage(firstName: 'a', lastName: 'b', phone: '12', text: 'x');

    expect(
      await repository.sendContactMessage(noText),
      const Left<Failure, void>(ValidationFailure(AppStrings.errorFieldsRequired)),
    );
    expect(
      await repository.sendContactMessage(badPhone),
      const Left<Failure, void>(ValidationFailure(AppStrings.errorPhoneInvalid)),
    );
    expect(adapter.requests, isEmpty);
  });

  test('ContactCubit: الإرسال ثم sent، والفشل يحمل رسالة الخادم', () async {
    adapter.on('/contact-us/add', body: {'message': 'تم الإرسال', 'data': []});
    final cubit = ContactCubit(SendContactMessage(repository));

    final statuses = cubit.stream.map((s) => s.status).take(2).toList();
    await cubit.send(_message);
    expect(await statuses, [ContactStatus.sending, ContactStatus.sent]);

    adapter.on('/contact-us/add', status: 422, body: {
      'message': 'الحقل النص مطلوب.',
      'errors': {
        'text': ['الحقل النص مطلوب.'],
      },
    });
    await cubit.send(_message);
    expect(cubit.state, const ContactState(status: ContactStatus.failure, error: 'الحقل النص مطلوب.'));
  });

  test('روابط التواصل من infos/all، والرابط الفارغ يصير null', () async {
    adapter.on('/infos/all', body: {
      'message': 'المعلومات الموجودة',
      'data': {
        'email': 'a@b.c',
        'facebook': 'https://www.facebook.com/dareb',
        'instagram': ' ',
        'telegram': 'https://t.me/dareb',
        'whatsapp': null,
      },
    });

    final result = await repository.getContactLinks();

    expect(
      result,
      const Right<Failure, ContactLinks>(
        ContactLinks(facebook: 'https://www.facebook.com/dareb', telegram: 'https://t.me/dareb'),
      ),
    );
  });

  test('رد 422 يصل ValidationException من مصدر البيانات', () async {
    adapter.on('/contact-us/add', status: 422, body: {
      'message': 'x',
      'errors': {
        'phone': ['الحقل رقم الهاتف مطلوب.'],
      },
    });
    final remote = SupportRemoteDataSourceImpl(
      ApiClient(readToken: () => null, dio: Dio(BaseOptions(baseUrl: 'https://api.test/api'))..httpClientAdapter = adapter),
    );

    await expectLater(remote.sendContactMessage(_message), throwsA(isA<ValidationException>()));
  });
}
