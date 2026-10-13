import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/lesson_details.dart';
import '../../domain/usecases/add_comment.dart';
import '../../domain/usecases/attend_lesson.dart';
import '../../domain/usecases/get_lesson.dart';

part 'lesson_state.dart';

/// صفحة الدرس (`/courses/:id/video/:lessonId`): تحميل الدرس، وتسجيل حضوره حين
/// يفتحه المستخدم، والتعليق في «النقاشات».
class LessonCubit extends Cubit<LessonState> {
  LessonCubit({
    required this._getLesson,
    required this._attendLesson,
    required this._addComment,
    required this._getCurrentUser,
  }) : super(const LessonState());

  final GetLesson _getLesson;
  final AttendLesson _attendLesson;
  final AddComment _addComment;
  final GetCurrentUser _getCurrentUser;

  Future<void> load(String lessonId) async {
    emit(state.copyWith(status: LessonStatus.loading));
    final result = await _getLesson(lessonId);
    // الطالب يظهر بصورته في حقل التعليق، وتعليقاته تتميز عن غيرها. فشل قراءته لا
    // يمنع عرض الدرس.
    final user = state.user ?? (await _getCurrentUser(const NoParams())).fold((_) => null, (user) => user);
    if (isClosed) return;
    emit(
      result.fold(
        (f) => state.copyWith(status: LessonStatus.failure, error: f.message, user: user),
        (details) => state.copyWith(
          status: LessonStatus.success,
          details: details,
          user: user,
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

  /// يرسل تعليق الطالب، ثم يجلب الدرس من جديد ليظهر التعليق بين غيره. فشل الجلب
  /// بعد الإرسال يُبقي التعليقات القديمة، والإرسال نفسه نجح.
  Future<void> sendComment(String text) async {
    final details = state.details;
    if (details == null || state.commentStatus == CommentStatus.sending) return;
    emit(state.copyWith(commentStatus: CommentStatus.sending));
    final result = await _addComment(NewComment(lessonId: details.lesson.id, text: text));
    if (isClosed) return;
    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(commentStatus: CommentStatus.failure, commentError: failure.message));
      return;
    }
    final refreshed = await _getLesson(details.lesson.id);
    if (isClosed) return;
    emit(
      state.copyWith(
        commentStatus: CommentStatus.done,
        details: refreshed.fold((_) => details, (fresh) => fresh),
      ),
    );
  }
}
