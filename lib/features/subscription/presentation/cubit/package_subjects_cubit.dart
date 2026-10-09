import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/subscription_package.dart';
import '../../domain/usecases/get_package_subjects.dart';

part 'package_subjects_state.dart';

/// مواد باقة واحدة لنافذة «المواد المتاحة».
class PackageSubjectsCubit extends Cubit<PackageSubjectsState> {
  PackageSubjectsCubit(this._getPackageSubjects) : super(const PackageSubjectsState());

  final GetPackageSubjects _getPackageSubjects;

  Future<void> load(String packageId) async {
    emit(const PackageSubjectsState(status: SubjectsStatus.loading));
    final result = await _getPackageSubjects(packageId);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => PackageSubjectsState(status: SubjectsStatus.failure, error: failure.message),
        (subjects) => PackageSubjectsState(status: SubjectsStatus.success, subjects: subjects),
      ),
    );
  }
}
