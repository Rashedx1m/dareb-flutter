import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/downloaded_file.dart';
import '../../domain/usecases/get_downloads.dart';

enum DownloadsStatus { initial, loading, success, failure }

class DownloadsCubit extends Cubit<DownloadsState> {
  DownloadsCubit(this._getDownloads) : super(const DownloadsState());

  final GetDownloads _getDownloads;

  Future<void> load() async {
    emit(const DownloadsState(status: DownloadsStatus.loading));
    final result = await _getDownloads(const NoParams());
    if (isClosed) return;
    emit(
      result.fold(
        (f) => DownloadsState(status: DownloadsStatus.failure, error: f.message),
        (items) => DownloadsState(status: DownloadsStatus.success, items: items),
      ),
    );
  }
}

class DownloadsState extends Equatable {
  const DownloadsState({this.status = DownloadsStatus.initial, this.items = const [], this.error});

  final DownloadsStatus status;
  final List<DownloadedFile> items;
  final String? error;

  @override
  List<Object?> get props => [status, items, error];
}
