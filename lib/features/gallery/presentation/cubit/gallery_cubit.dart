import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/gallery_album.dart';
import '../../domain/usecases/get_album.dart';
import '../../domain/usecases/get_albums.dart';

part 'gallery_state.dart';

/// قائمة الألبومات لشاشة المعرض، أو ألبوم واحد لشاشتي الألبوم وعارض الصور.
class GalleryCubit extends Cubit<GalleryState> {
  GalleryCubit({required this._getAlbums, required this._getAlbum}) : super(const GalleryState());

  final GetAlbums _getAlbums;
  final GetAlbum _getAlbum;

  Future<void> loadAlbums() async {
    emit(state.copyWith(status: GalleryStatus.loading));
    final result = await _getAlbums(const NoParams());
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: GalleryStatus.failure, error: f.message),
        (albums) => state.copyWith(status: GalleryStatus.success, albums: albums),
      ),
    );
  }

  Future<void> loadAlbum(String id) async {
    emit(state.copyWith(status: GalleryStatus.loading));
    final result = await _getAlbum(id);
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: GalleryStatus.failure, error: f.message),
        (album) => state.copyWith(status: GalleryStatus.success, album: album),
      ),
    );
  }
}
