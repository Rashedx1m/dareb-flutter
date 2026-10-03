import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/page_header.dart';
import '../../domain/entities/downloaded_file.dart';
import '../cubit/downloads_cubit.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          PageHeader(
            title: AppStrings.downloadedCourses,
            onBack: () => context.pop(),
            onNotifications: () => context.push('/notifications'),
          ),
          Expanded(
            child: BlocBuilder<DownloadsCubit, DownloadsState>(
              builder: (context, state) {
                return switch (state.status) {
                  DownloadsStatus.failure => ErrorView(
                      message: state.error,
                      onRetry: context.read<DownloadsCubit>().load,
                    ),
                  DownloadsStatus.success when state.items.isEmpty => const Center(
                      child: Text(AppStrings.noDownloads, style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  DownloadsStatus.success => ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 25),
                      itemBuilder: (_, i) => _DownloadTile(file: state.items[i]),
                    ),
                  _ => const LoadingView(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadTile extends StatelessWidget {
  const _DownloadTile({required this.file});

  final DownloadedFile file;

  @override
  Widget build(BuildContext context) {
    final isVideo = file.kind == DownloadKind.video;
    return Row(
      children: [
        Container(
          width: 74,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.iconBlue, borderRadius: BorderRadius.circular(10)),
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Text(
              '${file.chapter}',
              style: const TextStyle(
                fontFamily: 'Lato',
                color: AppColors.iconBlue,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file.title,
                style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    isVideo ? '${file.duration} ${AppStrings.minutesUnit}' : '${file.pages} ${AppStrings.pagesUnit}',
                    style: const TextStyle(color: Color(0xFF5C5C5C), fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isVideo ? PhosphorIconsFill.videoCamera : PhosphorIconsFill.filePdf,
                    color: AppColors.iconBlue,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
        Icon(
          isVideo ? PhosphorIconsFill.playCircle : PhosphorIconsFill.bookOpen,
          color: AppColors.blueStrong,
          size: isVideo ? 44 : 46,
        ),
      ],
    );
  }
}
