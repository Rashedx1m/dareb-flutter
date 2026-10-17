import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:educational_app/core/error/failures.dart';
import 'package:educational_app/core/network/api_client.dart';
import 'package:educational_app/features/gallery/data/datasources/gallery_remote_data_source.dart';
import 'package:educational_app/features/gallery/data/models/gallery_album_model.dart';
import 'package:educational_app/features/gallery/data/repositories/gallery_repository_impl.dart';
import 'package:educational_app/features/gallery/domain/entities/gallery_album.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http_adapter.dart';

/// ألبوم Tamkeen كما أعاده `galleries/all` في 2026-10-16: `{id, name, images}`.
const _json = {
  'id': 14,
  'name': 'Tamkeen',
  'images': [
    'https://training.tamkeen-dev.com/dareb/public/storage/1/gallery-a.jpg',
    'https://training.tamkeen-dev.com/dareb/public/storage/1/gallery-b.jpg',
  ],
};

void main() {
  test('fromJson على الرد الحقيقي', () {
    final album = GalleryAlbumModel.fromJson(_json);

    expect(album.id, '14');
    expect(album.title, 'Tamkeen');
    expect(album.cover, 'https://training.tamkeen-dev.com/dareb/public/storage/1/gallery-a.jpg');
    expect(album.photos, hasLength(2));
    expect(album.count, 2);
  });

  test('ألبوم بلا صور يبقى غلافه فارغاً', () {
    final album = GalleryAlbumModel.fromJson({..._json, 'images': <Object>[]});

    expect(album.cover, '');
    expect(album.photos, isEmpty);
  });

  group('المصدر والمستودع', () {
    late FakeHttpAdapter adapter;
    late GalleryRepositoryImpl repository;

    setUp(() {
      adapter = FakeHttpAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api'))..httpClientAdapter = adapter;
      repository = GalleryRepositoryImpl(
        GalleryRemoteDataSourceImpl(ApiClient(readToken: () => '30|abc', dio: dio)),
      );
    });

    test('القائمة من galleries/all بتوكن الجلسة', () async {
      adapter.on('/galleries/all', body: {'message': 'تمت العملية بنجاح', 'data': [_json]});

      final albums = (await repository.getAlbums()).getOrElse(() => throw StateError('expected albums'));

      expect(albums.single.id, '14');
      expect(albums.single.title, 'Tamkeen');
      expect(adapter.requests.single.headers['Authorization'], 'Bearer 30|abc');
    });

    test('تفاصيل الألبوم تُبحث في القائمة لأن galleries/details يعيد 404', () async {
      adapter.on('/galleries/all', body: {'message': 'ok', 'data': [_json]});

      final album = (await repository.getAlbum('14')).getOrElse(() => throw StateError('expected album'));

      expect(album.id, '14');
      expect(adapter.requests.single.path, '/galleries/all');
    });

    test('ألبوم غير موجود يصل كـ ServerFailure', () async {
      adapter.on('/galleries/all', body: {'message': 'ok', 'data': [_json]});

      expect(
        await repository.getAlbum('99'),
        const Left<Failure, GalleryAlbum>(ServerFailure('الألبوم غير موجود')),
      );
    });
  });
}
