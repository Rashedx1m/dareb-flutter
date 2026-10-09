import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/lookup_option.dart';
import '../../domain/usecases/get_branches.dart';
import '../../domain/usecases/get_governorates.dart';
import '../../domain/usecases/get_schools.dart';

part 'registration_options_state.dart';

/// قوائم خطوات التسجيل من الخادم: المحافظات والفروع، ومدارس الاختيار الحالي.
class RegistrationOptionsCubit extends Cubit<RegistrationOptionsState> {
  RegistrationOptionsCubit({
    required this._getGovernorates,
    required this._getSchools,
    required this._getBranches,
  }) : super(const RegistrationOptionsState());

  final GetGovernorates _getGovernorates;
  final GetSchools _getSchools;
  final GetBranches _getBranches;

  /// المحافظات والفروع لا تتغير أثناء التسجيل، فتُحمَّل مرة واحدة معاً.
  Future<void> load() async {
    emit(state.copyWith(status: OptionsStatus.loading));
    final (governorates, branches) = await (
      _getGovernorates(const NoParams()),
      _getBranches(const NoParams()),
    ).wait;
    if (isClosed) return;

    final lists = governorates.flatMap((g) => branches.map((b) => (governorates: g, branches: b)));
    emit(
      lists.fold(
        (f) => state.copyWith(status: OptionsStatus.failure, error: f.message),
        (data) => state.copyWith(
          status: OptionsStatus.success,
          governorates: data.governorates,
          branches: data.branches,
        ),
      ),
    );
  }

  /// مدارس النوع والمحافظة المختارين، ويُعاد طلبها عند تغيّر أيّ منهما.
  Future<void> loadSchools(SchoolsQuery query) async {
    emit(state.copyWith(schoolsStatus: OptionsStatus.loading, schoolsQuery: query, schools: const []));
    final result = await _getSchools(query);
    // ردّ متأخر لاختيار سابق (غيّر المستخدم المحافظة قبل وصوله) لا يُعرض.
    if (isClosed || state.schoolsQuery != query) return;
    emit(
      result.fold(
        (f) => state.copyWith(schoolsStatus: OptionsStatus.failure, schoolsError: f.message),
        (schools) => state.copyWith(schoolsStatus: OptionsStatus.success, schools: schools),
      ),
    );
  }
}
