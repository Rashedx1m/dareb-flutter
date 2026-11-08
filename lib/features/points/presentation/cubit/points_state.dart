part of 'points_cubit.dart';

enum PointsStatus { initial, loading, success, failure }

class PointsState extends Equatable {
  const PointsState({
    this.status = PointsStatus.initial,
    this.items = const [],
    this.error,
  });

  final PointsStatus status;
  final List<PointRecord> items;

  /// يُعرض فقط مع `failure`.
  final String? error;

  /// مجموع نقاط السجل المعروض، لترويسة الصفحة.
  int get total => items.fold(0, (sum, item) => sum + item.points);

  PointsState copyWith({
    PointsStatus? status,
    List<PointRecord>? items,
    String? error,
  }) {
    return PointsState(
      status: status ?? this.status,
      items: items ?? this.items,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, items, error];
}
