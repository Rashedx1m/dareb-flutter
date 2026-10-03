import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/features/support/domain/entities/contact_links.dart';
import 'package:educational_app/features/support/domain/entities/contact_message.dart';
import 'package:educational_app/features/support/domain/repositories/support_repository.dart';
import 'package:educational_app/features/support/domain/usecases/get_contact_links.dart';
import 'package:educational_app/features/support/presentation/cubit/about_cubit.dart';
import 'package:educational_app/features/support/presentation/widgets/about_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

const _links = ContactLinks(
  facebook: 'https://www.facebook.com/dareb',
  instagram: 'https://www.instagram.com/dareb',
  telegram: 'https://t.me/dareb',
  whatsapp: 'https://wa.me/963993571184',
);

class _FakeSupportRepository implements SupportRepository {
  /// رد `infos/all` لا يصل إلا بعد إكماله.
  final gate = Completer<void>();

  @override
  Future<Either<Failure, ContactLinks>> getContactLinks() async {
    await gate.future;
    return const Right(_links);
  }

  @override
  Future<Either<Failure, void>> sendContactMessage(ContactMessage message) => throw UnimplementedError();
}

void main() {
  late _FakeSupportRepository repository;
  late List<Uri> opened;

  Future<void> pumpSheet(WidgetTester tester, {bool canOpen = true}) async {
    repository = _FakeSupportRepository();
    opened = [];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (_) => AboutCubit(GetContactLinks(repository))..load(),
            child: AboutSheet(
              openLink: (uri) async {
                opened.add(uri);
                return canOpen;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder link(String label) => find.bySemanticsLabel(label);

  testWidgets('الأيقونات معطّلة إلى أن تصل الروابط، ثم تفتح رابط كل حساب', (tester) async {
    await pumpSheet(tester);

    await tester.tap(link(AppStrings.facebook), warnIfMissed: false);
    expect(opened, isEmpty);

    repository.gate.complete();
    await tester.pumpAndSettle();

    await tester.tap(link(AppStrings.facebook));
    await tester.tap(link(AppStrings.whatsapp));
    expect(opened, [Uri.parse(_links.facebook!), Uri.parse(_links.whatsapp!)]);
    expect(find.text(AppStrings.linkOpenError), findsNothing);
  });

  testWidgets('تعذّر فتح الرابط يظهر رسالة داخل الورقة', (tester) async {
    await pumpSheet(tester, canOpen: false);
    repository.gate.complete();
    await tester.pumpAndSettle();

    await tester.tap(link(AppStrings.telegram));
    await tester.pump();

    expect(opened, [Uri.parse(_links.telegram!)]);
    expect(find.text(AppStrings.linkOpenError), findsOneWidget);
  });
}
