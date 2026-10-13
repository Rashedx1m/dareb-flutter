import 'package:equatable/equatable.dart';

/// تعليق في «النقاشات» تحت الدرس.
class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorName,
    this.authorImageUrl,
    this.createdAt,
  });

  final String id;
  final String text;

  /// يميّز تعليقات الطالب نفسه عن تعليقات غيره.
  final String authorId;
  final String authorName;
  final String? authorImageUrl;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, text, authorId, authorName, authorImageUrl, createdAt];
}

/// تعليق يكتبه الطالب على درس.
class NewComment extends Equatable {
  const NewComment({required this.lessonId, required this.text});

  final String lessonId;
  final String text;

  @override
  List<Object?> get props => [lessonId, text];
}
