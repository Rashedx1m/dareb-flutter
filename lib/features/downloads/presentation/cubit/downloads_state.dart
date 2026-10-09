part of 'downloads_cubit.dart';

enum DownloadsStatus { initial, loading, success, failure }

class DownloadsState extends Equatable {
  const DownloadsState({this.status = DownloadsStatus.initial, this.items = const [], this.error});

  final DownloadsStatus status;
  final List<DownloadedFile> items;
  final String? error;

  @override
  List<Object?> get props => [status, items, error];
}
