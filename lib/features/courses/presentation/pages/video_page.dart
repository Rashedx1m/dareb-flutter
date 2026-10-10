import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/semester.dart';
import '../cubit/course_details_cubit.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key, required this.courseId, required this.lessonId});

  final String courseId;
  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final details = context.select((CourseDetailsCubit c) => c.state.details);
    final course = details?.course;
    final lessons = [for (final semester in details?.semesters ?? const <Semester>[]) ...semester.lessons];
    final lesson = lessons.where((l) => l.id == lessonId).firstOrNull;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(lesson?.title ?? AppStrings.lesson),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: AppColors.videoBackground,
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
                  const Text(AppStrings.courseContent, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...lessons.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        item.id == lessonId ? Icons.pause_circle_filled : Icons.play_circle_outline,
                        color: AppColors.primary,
                      ),
                      title: Text(item.title),
                      trailing: Text(item.duration ?? '', style: const TextStyle(color: AppColors.textMuted)),
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
