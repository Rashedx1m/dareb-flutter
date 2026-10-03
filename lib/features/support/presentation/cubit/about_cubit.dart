import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/contact_links.dart';
import '../../domain/usecases/get_contact_links.dart';

/// روابط التواصل لورقة «حول التطبيق»: `null` إلى أن تصل. فشل جلبها يُبقيها
/// `null` فتبقى الأيقونات معطّلة، لأن باقي الورقة لا يعتمد عليها.
class AboutCubit extends Cubit<ContactLinks?> {
  AboutCubit(this._getContactLinks) : super(null);

  final GetContactLinks _getContactLinks;

  Future<void> load() async {
    final result = await _getContactLinks(const NoParams());
    if (isClosed) return;
    result.forEach(emit);
  }
}
