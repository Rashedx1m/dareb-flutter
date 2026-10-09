import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/subscription_package.dart';
import '../../domain/usecases/get_packages.dart';
import '../../domain/usecases/subscribe_with_code.dart';

part 'subscription_state.dart';

/// صفحة الاشتراكات: الخيار المختار باقةٌ (تُكمل في صفحة الدفع) أو كودٌ يُفعَّل مباشرة.
class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({required this._getPackages, required this._subscribeWithCode})
      : super(const SubscriptionState());

  final GetPackages _getPackages;
  final SubscribeWithCode _subscribeWithCode;

  /// يختار أول باقة كما في التصميم، أو خانة الكود الأولى إن لم توجد باقات.
  Future<void> load() async {
    emit(state.copyWith(status: PackagesStatus.loading));
    final result = await _getPackages(const NoParams());
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(status: PackagesStatus.failure, error: failure.message)),
      (packages) => emit(
        state.copyWith(status: PackagesStatus.success, packages: packages).withChoice(
              packageId: packages.isEmpty ? null : packages.first.id,
              code: packages.isEmpty ? CodeOption.subjectOrCurriculum : null,
            ),
      ),
    );
  }

  void selectPackage(String id) => emit(state.withChoice(packageId: id));

  void selectCode(CodeOption option) => emit(state.withChoice(code: option));

  Future<void> activate(String code) async {
    emit(state.copyWith(activation: ActivationStatus.sending));
    final result = await _subscribeWithCode(code);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => state.copyWith(activation: ActivationStatus.failure, activationError: failure.message),
        (_) => state.copyWith(activation: ActivationStatus.done),
      ),
    );
  }
}
