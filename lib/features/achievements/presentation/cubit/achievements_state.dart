part of 'achievements_cubit.dart';

enum AchievementsStatus { initial, loading, success, failure }

class AchievementsState extends Equatable {
  const AchievementsState({
    this.status = AchievementsStatus.initial,
    this.items = const [],
    this.error,
  });

  final AchievementsStatus status;
  final List<Achievement> items;
  final String? error;

  AchievementsState copyWith({
    AchievementsStatus? status,
    List<Achievement>? items,
    String? error,
  }) {
    return AchievementsState(
      status: status ?? this.status,
      items: items ?? this.items,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, items, error];
}
