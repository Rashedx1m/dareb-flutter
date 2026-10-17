import 'package:dartz/dartz.dart';
import 'package:educational_app/core/constants/app_strings.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/widgets/error_view.dart';
import 'package:educational_app/features/gallery/domain/entities/gallery_album.dart';
import 'package:educational_app/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:educational_app/features/gallery/domain/usecases/get_album.dart';
import 'package:educational_app/features/gallery/domain/usecases/get_albums.dart';
import 'package:educational_app/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:educational_app/features/gallery/presentation/pages/album_page.dart';
import 'package:educational_app/features/gallery/presentation/pages/gallery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _album = GalleryAlbum(
  id: '14',
  title: 'Tamkeen',
  cover: 'assets/images/gallery/photo_1.png',
  photos: [
    'assets/images/gallery/photo_1.png',
    'assets/images/gallery/photo_2.png',
  ],
);

class _FakeGalleryRepository extends Fake implements GalleryRepository {
  _FakeGalleryRepository({this.albums = const [_album], this.failure});

  final List<GalleryAlbum> albums;
  final Failure? failure;

  @override
  Future<Either<Failure, List<GalleryAlbum>>> getAlbums() async =>
      failure != null ? Left(failure!) : Right(albums);

  @override
  Future<Either<Failure, GalleryAlbum>> getAlbum(String id) async {
    if (failure != null) return Left(failure!);
    for (final album in albums) {
      if (album.id == id) return Right(album);
    }
    return const Left(ServerFailure('الألبوم غير موجود'));
  }
}

GalleryCubit _cubit(_FakeGalleryRepository repository) => GalleryCubit(
      getAlbums: GetAlbums(repository),
      getAlbum: GetAlbum(repository),
    );

Future<void> _pumpGallery(WidgetTester tester, GalleryCubit cubit) async {
  tester.view
    ..physicalSize = const Size(1200, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: '/gallery',
    routes: [
      GoRoute(
        path: '/gallery',
        builder: (_, _) => BlocProvider.value(value: cubit, child: const GalleryPage()),
      ),
      GoRoute(path: '/notifications', builder: (_, _) => const SizedBox()),
    ],
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
}

Future<void> _pumpAlbum(WidgetTester tester, GalleryCubit cubit) async {
  tester.view
    ..physicalSize = const Size(1200, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: '/gallery/14',
    routes: [
      GoRoute(
        path: '/gallery/:id',
        builder: (_, _) => BlocProvider.value(value: cubit, child: const AlbumPage(albumId: '14')),
      ),
      GoRoute(path: '/notifications', builder: (_, _) => const SizedBox()),
    ],
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('تعرض الألبومات بالاسم والعدد', (tester) async {
    await _pumpGallery(tester, _cubit(_FakeGalleryRepository())..loadAlbums());

    expect(find.text('Tamkeen ( 2 )'), findsOneWidget);
  });

  testWidgets('القائمة الفارغة تعرض الرسالة', (tester) async {
    await _pumpGallery(tester, _cubit(_FakeGalleryRepository(albums: const []))..loadAlbums());

    expect(find.text(AppStrings.galleryNoAlbums), findsOneWidget);
  });

  testWidgets('الفشل يعرض الرسالة وزر إعادة المحاولة', (tester) async {
    await _pumpGallery(
      tester,
      _cubit(_FakeGalleryRepository(failure: const ServerFailure('تعذر جلب المعرض')))..loadAlbums(),
    );

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('تعذر جلب المعرض'), findsOneWidget);
  });

  testWidgets('الألبوم يعرض صوره', (tester) async {
    await _pumpAlbum(tester, _cubit(_FakeGalleryRepository())..loadAlbum('14'));

    expect(find.byType(GestureDetector), findsWidgets);
  });
}
