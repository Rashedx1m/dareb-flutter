import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/contact_links.dart';
import '../../domain/usecases/get_contact_links.dart';

part 'about_state.dart';

/// روابط التواصل لورقة «حول التطبيق». فشل جلبها يُبقي الروابط فارغة فتبقى
/// الأيقونات معطّلة، لأن باقي الورقة لا يعتمد عليها.
class AboutCubit extends Cubit<AboutState> {
  AboutCubit(this._getContactLinks) : super(const AboutState());

  final GetContactLinks _getContactLinks;

  Future<void> load() async {
    emit(const AboutState(status: AboutStatus.loading));
    final result = await _getContactLinks(const NoParams());
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => AboutState(status: AboutStatus.failure, error: failure.message),
        (links) => AboutState(status: AboutStatus.success, links: links),
      ),
    );
  }
}
