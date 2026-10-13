import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/comment.dart';

/// «النقاشات» تحت الدرس: أول تعليقين و«أظهر الكل» لبقيتها، ثم حقل التعليق.
class LessonDiscussions extends StatefulWidget {
  const LessonDiscussions({
    super.key,
    required this.comments,
    required this.user,
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final List<Comment> comments;

  /// صاحب الجلسة: صورته في الحقل، وتعليقاته تظهر بلون مختلف.
  final User? user;
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  State<LessonDiscussions> createState() => _LessonDiscussionsState();
}

class _LessonDiscussionsState extends State<LessonDiscussions> {
  static const _preview = 2;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final comments = widget.comments;
    final visible = _expanded ? comments : comments.take(_preview);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 13, end: 16),
          child: Row(
            children: [
              const Icon(PhosphorIconsRegular.chats, color: AppColors.primary, size: 24),
              const SizedBox(width: 6),
              const Text(
                AppStrings.discussions,
                style: TextStyle(color: AppColors.pathTitle, fontSize: 21, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              if (comments.length > _preview)
                _ShowAllPill(
                  label: _expanded ? AppStrings.showLess : AppStrings.showAll,
                  onTap: () => setState(() => _expanded = !_expanded),
                ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        if (comments.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              AppStrings.noComments,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        for (final comment in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 27),
            child: _CommentRow(comment: comment, own: widget.user != null && comment.authorId == widget.user!.id),
          ),
        const SizedBox(height: 6),
        _Composer(
          controller: widget.controller,
          avatarUrl: widget.user?.avatarUrl,
          sending: widget.sending,
          onSend: widget.onSend,
        ),
      ],
    );
  }
}

/// تعليق غيره بطاقة بيضاء في البداية وصورة كاتبه بعدها، وتعليقه هو بطاقة فيروزية
/// فاتحة تسبقها صورته، كما في التصميم.
class _CommentRow extends StatelessWidget {
  const _CommentRow({required this.comment, required this.own});

  final Comment comment;
  final bool own;

  @override
  Widget build(BuildContext context) {
    final avatar = _Avatar(url: comment.authorImageUrl, radius: 19);
    final card = Expanded(child: _CommentCard(comment: comment, own: own));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: own
          ? [const SizedBox(width: 13), avatar, const SizedBox(width: 71), card, const SizedBox(width: 16)]
          : [const SizedBox(width: 58), card, const SizedBox(width: 17), avatar, const SizedBox(width: 52)],
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment, required this.own});

  final Comment comment;
  final bool own;

  @override
  Widget build(BuildContext context) {
    final date = comment.createdAt;
    return Container(
      // تعليق الطالب أضيق نصاً في التصميم: هامش أكبر في بدايته.
      padding: EdgeInsetsDirectional.fromSTEB(own ? 44 : 16, 14, 16, 16),
      decoration: BoxDecoration(
        color: own ? AppColors.commentOwnFill : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: own ? AppColors.primary : AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  comment.authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: own ? AppColors.primary : AppColors.sheetTitle, fontSize: 16),
                ),
              ),
              if (date != null)
                Text(
                  '${date.year}/${date.month}/${date.day}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Lato'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.text,
            style: TextStyle(
              color: own ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.avatarUrl, required this.sending, required this.onSend});

  final TextEditingController controller;
  final String? avatarUrl;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      margin: const EdgeInsetsDirectional.only(start: 13, end: 16),
      padding: const EdgeInsetsDirectional.only(start: 14, end: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          _Avatar(url: avatarUrl, radius: 16),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !sending,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(color: AppColors.sheetTitle, fontSize: 14),
              // حدود الحقل في الثيم العام لا تظهر هنا: الإطار للحاوية كلها.
              decoration: const InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: AppStrings.writeComment,
                hintStyle: TextStyle(color: AppColors.hint, fontSize: 14),
              ),
            ),
          ),
          Tooltip(
            message: AppStrings.sendComment,
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: sending ? null : onSend,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: sending
                      ? const Padding(
                          padding: EdgeInsets.all(11),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      // السهم يشير إلى جهة الإرسال في الواجهة العربية.
                      : Transform.flip(
                          flipX: Directionality.of(context) == TextDirection.rtl,
                          child: const Icon(PhosphorIconsRegular.paperPlaneRight, color: Colors.white, size: 20),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowAllPill extends StatelessWidget {
  const _ShowAllPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.iconTileBlue,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Text(label, style: const TextStyle(color: AppColors.blueStrong, fontSize: 11)),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.radius});

  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.avatarBg,
      child: Icon(PhosphorIconsFill.user, color: AppColors.blueStrong, size: radius),
    );
    final image = url;
    if (image == null || image.isEmpty) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: image,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}
