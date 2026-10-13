import '../../domain/entities/comment.dart';

/// تعليق من `comments` في رد `lessions/details`.
///
/// لم يظهر بعد تعليق واحد على خادم التدريب (والقائمة `comments/get-by-lession`
/// تحتاج توكناً)، فشكل الحقول غير مؤكد: النص في `comment` كما في طلب
/// `comments/add-comment`، أو `body`/`text`، والكاتب في `user` أو `user_id`.
/// تعليق بلا نص يُتخطى.
class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.text,
    required super.authorId,
    required super.authorName,
    super.authorImageUrl,
    super.createdAt,
  });

  static CommentModel? tryFromJson(Map<String, dynamic> json) {
    final text = (json['comment'] ?? json['body'] ?? json['text']) as String?;
    if (text == null || text.trim().isEmpty) return null;
    final user = json['user'] as Map<String, dynamic>?;
    final name = [user?['f_name'], user?['l_name']].whereType<String>().join(' ').trim();
    return CommentModel(
      id: '${json['id']}',
      text: text.trim(),
      authorId: '${user?['id'] ?? json['user_id'] ?? ''}',
      authorName: name.isNotEmpty ? name : (user?['name'] as String? ?? ''),
      authorImageUrl: user?['image'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}
