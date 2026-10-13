import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../domain/entities/lesson.dart';
import '../lesson_path.dart';

/// مساحة الدرس أعلى الصفحة: تمتد تحت شريط الحالة بزوايا سفلية دائرية.
class LessonMediaFrame extends StatelessWidget {
  const LessonMediaFrame({super.key, required this.child});

  final Widget child;

  /// ارتفاعها تحت شريط الحالة.
  static const height = 275.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.paddingOf(context).top + height,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: ColoredBox(color: AppColors.videoBackground, child: child),
      ),
    );
  }
}

/// غلاف درس الفيديو قبل تشغيله كما في التصميم: صورة الفيديو، ومدته، وزر التشغيل في
/// الوسط، ونسبة الإكمال، وزر المشاركة. الضغط على الصورة أو الزر يشغّله.
class VideoCover extends StatelessWidget {
  const VideoCover({super.key, required this.lesson, required this.videoId, required this.onPlay, required this.onShare});

  final Lesson lesson;
  final String videoId;
  final VoidCallback onPlay;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final duration = lesson.duration;
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
          fit: BoxFit.cover,
          errorWidget: (_, _, _) => const SizedBox.shrink(),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, AppColors.overlay60],
              stops: [0.45, 1],
            ),
          ),
        ),
        Material(
          type: MaterialType.transparency,
          child: InkWell(onTap: onPlay, child: const SizedBox.expand()),
        ),
        if (duration != null)
          PositionedDirectional(
            top: top - 22,
            start: 25,
            child: _GlassPill(child: Text(lessonDurationLabel(duration), style: _whiteText(16))),
          ),
        // مركز الزر في التصميم أعلى من منتصف المساحة.
        Align(
          alignment: const Alignment(0, -0.22),
          child: Tooltip(
              message: AppStrings.playLesson,
              child: InkWell(
                onTap: onPlay,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.overlay40),
                  child: const Icon(PhosphorIconsRegular.play, color: Colors.white, size: 30),
                ),
              ),
            ),
        ),
        PositionedDirectional(
          start: 25,
          end: 25,
          bottom: 98,
          child: _Progress(percent: lesson.isAttended ? 100 : 0, duration: duration),
        ),
        PositionedDirectional(
          end: 25,
          bottom: 23,
          child: MediaRoundButton(icon: PhosphorIconsRegular.shareNetwork, tooltip: AppStrings.shareLesson, onTap: onShare),
        ),
      ],
    );
  }
}

/// غلاف درس الملف: أيقونة PDF في الوسط وزر التنزيل، وكلاهما يفتح الملف.
class FileCover extends StatelessWidget {
  const FileCover({super.key, required this.onOpen, required this.onShare});

  final VoidCallback onOpen;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onOpen,
            child: const Align(
              alignment: Alignment(0, -0.1),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                child: Icon(PhosphorIconsFill.filePdf, color: Colors.white, size: 36),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          end: 25,
          bottom: 23,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MediaRoundButton(icon: PhosphorIconsRegular.downloadSimple, tooltip: AppStrings.openFile, onTap: onOpen),
              const SizedBox(width: 16),
              MediaRoundButton(icon: PhosphorIconsRegular.shareNetwork, tooltip: AppStrings.shareLesson, onTap: onShare),
            ],
          ),
        ),
      ],
    );
  }
}

/// غلاف الدرس المقفل.
class LockedCover extends StatelessWidget {
  const LockedCover({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(PhosphorIconsRegular.lock, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          Text(AppStrings.subscribersOnlyLesson, style: _whiteText(16, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// حين لا يعمل المشغّل داخل التطبيق: زر يفتح الفيديو في يوتيوب.
class WatchOnYoutubeCover extends StatelessWidget {
  const WatchOnYoutubeCover({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.1),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(PhosphorIconsRegular.youtubeLogo),
        label: const Text(AppStrings.watchOnYoutube),
      ),
    );
  }
}

/// زر دائري أبيض في أسفل مساحة الدرس (المشاركة والتنزيل).
class MediaRoundButton extends StatelessWidget {
  const MediaRoundButton({super.key, required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(width: 46, height: 46, child: Icon(icon, color: AppColors.textPrimary, size: 20)),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: AppColors.overlay40, borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }
}

/// نسبة الإكمال ومدة الدرس، وشريط يمتلئ من البداية.
class _Progress extends StatelessWidget {
  const _Progress({required this.percent, required this.duration});

  final int percent;
  final String? duration;

  @override
  Widget build(BuildContext context) {
    final clock = duration == null ? null : lessonDurationLabel(duration!).split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('$percent% ${AppStrings.completedWord}', style: _whiteText(12)),
            const Spacer(),
            if (clock != null) Text('$clock ${AppStrings.totalDuration}', style: _whiteText(12)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 5,
            color: AppColors.stepKnob,
            backgroundColor: AppColors.tabTrack,
          ),
        ),
      ],
    );
  }
}

TextStyle _whiteText(double size, {FontWeight weight = FontWeight.w400}) =>
    TextStyle(color: Colors.white, fontSize: size, fontWeight: weight);
