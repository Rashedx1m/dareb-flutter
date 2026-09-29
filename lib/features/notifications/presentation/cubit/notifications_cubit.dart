import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/get_notifications.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._getNotifications) : super(const NotificationsState());

  final GetNotifications _getNotifications;

  Future<void> load() async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    final result = await _getNotifications(const NoParams());
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: NotificationsStatus.failure, error: f.message),
        (items) => state.copyWith(status: NotificationsStatus.success, items: items),
      ),
    );
  }
}
