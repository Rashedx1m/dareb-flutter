import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/plan.dart';
import '../../domain/usecases/get_plans.dart';

part 'plans_state.dart';

/// باقات الاشتراك والباقة المختارة، تشترك فيه صفحة الاشتراك وصفحة الدفع.
class PlansCubit extends Cubit<PlansState> {
  PlansCubit(this._getPlans) : super(const PlansState());

  final GetPlans _getPlans;

  /// يحمّل الباقات ويختار [preferredId] إن وُجد، وإلا الباقة المميّزة
  /// (أو الأولى إن لم تُميَّز أي باقة).
  Future<void> load({String? preferredId}) async {
    emit(state.copyWith(status: PlansStatus.loading));
    final result = await _getPlans(const NoParams());
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: PlansStatus.failure, error: f.message),
        (plans) => state.copyWith(
          status: PlansStatus.success,
          plans: plans,
          selectedId: _initialSelection(plans, preferredId),
        ),
      ),
    );
  }

  void select(String planId) => emit(state.copyWith(selectedId: planId));

  static String? _initialSelection(List<Plan> plans, String? preferredId) {
    if (plans.isEmpty) return null;
    if (plans.any((p) => p.id == preferredId)) return preferredId;
    return plans.firstWhere((p) => p.highlighted, orElse: () => plans.first).id;
  }
}
