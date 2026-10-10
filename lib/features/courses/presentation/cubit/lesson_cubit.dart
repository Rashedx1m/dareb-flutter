import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/lesson_details.dart';
import '../../domain/usecases/attend_lesson.dart';
import '../../domain/usecases/get_lesson.dart';

part 'lesson_state.dart';

/// صفحة الدرس (`/courses/:id/video/:lessonId`): تحميل الدرس، وتسجيل حضوره حين
/// يفتحه المستخدم.
class LessonCubit extends Cubit<LessonState> {
  LessonCubit({required this._getLesson, required this._attendLesson}) : super(const LessonState());

  final GetLesson _getLesson;
  final AttendLesson _attendLesson;

  Future<void> load(String lessonId) async {
    emit(state.copyWith(status: LessonStatus.loading));
    final result = await _getLesson(lessonId);
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: LessonStatus.failure, error: f.message),
        (details) => state.copyWith(
          status: LessonStatus.success,
          details: details,
          attendStatus: details.lesson.isAttended ? AttendStatus.done : AttendStatus.idle,
        ),
      ),
    );
  }

  /// مرة واحدة لكل درس: الخادم ينشئ سجل حضور مع الطلب (201)، وأثر تكراره للدرس
  /// نفسه غير معروف. فشله لا يمنع متابعة الدرس، ويُعاد الإرسال عند فتحه مرة أخرى.
  Future<void> attend() async {
    final details = state.details;
    if (details == null || state.attendStatus == AttendStatus.sending || state.attendStatus == AttendStatus.done) {
      return;
    }
    emit(state.copyWith(attendStatus: AttendStatus.sending));
    final result = await _attendLesson(details.lesson.id);
    if (isClosed) return;
    emit(state.copyWith(attendStatus: result.fold((_) => AttendStatus.failure, (_) => AttendStatus.done)));
  }
}
