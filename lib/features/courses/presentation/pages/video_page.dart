import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/courses_bloc.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key, required this.courseId, required this.lessonId});

  final String courseId;
  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final course = context.select((CoursesBloc b) => b.state.selected);
    final lesson = course?.lessons.where((l) => l.id == lessonId).firstOrNull;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(lesson?.title ?? 'الدرس'),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: const Color(0xFF111111),
              child: const Center(
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.background,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(lesson?.title ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(course?.title ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  const Text('محتوى الدورة', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...?course?.lessons.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        item.id == lessonId ? Icons.pause_circle_filled : Icons.play_circle_outline,
                        color: AppColors.primary,
                      ),
                      title: Text(item.title),
                      trailing: Text(item.duration, style: const TextStyle(color: AppColors.textMuted)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
