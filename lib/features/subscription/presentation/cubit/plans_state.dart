part of 'plans_cubit.dart';

enum PlansStatus { initial, loading, success, failure }

class PlansState extends Equatable {
  const PlansState({
    this.status = PlansStatus.initial,
    this.plans = const [],
    this.selectedId,
    this.error,
  });

  final PlansStatus status;
  final List<Plan> plans;
  final String? selectedId;
  final String? error;

  Plan? get selected {
    for (final plan in plans) {
      if (plan.id == selectedId) return plan;
    }
    return null;
  }

  PlansState copyWith({
    PlansStatus? status,
    List<Plan>? plans,
    String? selectedId,
    String? error,
  }) {
    return PlansState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      selectedId: selectedId ?? this.selectedId,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, plans, selectedId, error];
}
