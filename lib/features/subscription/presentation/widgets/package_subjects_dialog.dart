import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/subscription_package.dart';
import '../cubit/package_subjects_cubit.dart';

/// نافذة «المواد المتاحة» لباقة، تُجلب موادها من `packages/details`.
Future<void> showPackageSubjects(BuildContext context, SubscriptionPackage package) {
  return showDialog<void>(
    context: context,
    builder: (_) => BlocProvider(
      create: (_) => sl<PackageSubjectsCubit>()..load(package.id),
      child: PackageSubjectsDialog(packageId: package.id),
    ),
  );
}

class PackageSubjectsDialog extends StatelessWidget {
  const PackageSubjectsDialog({super.key, required this.packageId});

  final String packageId;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    AppStrings.availableSubjects,
                    style: TextStyle(color: AppColors.sheetTitle, fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                ),
                IconButton(
                  tooltip: AppStrings.exitWord,
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  icon: const Icon(PhosphorIconsRegular.xCircle, color: AppColors.closeIcon, size: 40),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.55),
              child: BlocBuilder<PackageSubjectsCubit, PackageSubjectsState>(
                builder: (context, state) => switch (state.status) {
                  SubjectsStatus.failure => ErrorView(
                      message: state.error,
                      onRetry: () => context.read<PackageSubjectsCubit>().load(packageId),
                    ),
                  SubjectsStatus.success when state.subjects.isEmpty => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text(AppStrings.noPackageSubjects, style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  SubjectsStatus.success => _SubjectsGrid(subjects: state.subjects),
                  SubjectsStatus.initial || SubjectsStatus.loading => const SizedBox(height: 160, child: LoadingView()),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// شبكة من عمودين، وشريط تمرير أزرق على مسار رمادي كما في التصميم.
class _SubjectsGrid extends StatefulWidget {
  const _SubjectsGrid({required this.subjects});

  final List<PackageSubject> subjects;

  @override
  State<_SubjectsGrid> createState() => _SubjectsGridState();
}

class _SubjectsGridState extends State<_SubjectsGrid> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: _scroll,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 6,
      radius: const Radius.circular(3),
      thumbColor: AppColors.accentBlue,
      trackColor: AppColors.controlFill,
      trackRadius: const Radius.circular(3),
      child: GridView.builder(
        controller: _scroll,
        shrinkWrap: true,
        padding: const EdgeInsetsDirectional.only(end: 18),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.55,
        ),
        itemCount: widget.subjects.length,
        itemBuilder: (_, i) => _SubjectCard(subject: widget.subjects[i]),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject});

  final PackageSubject subject;

  @override
  Widget build(BuildContext context) {
    final image = subject.imageUrl;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      decoration: BoxDecoration(color: AppColors.subjectChip, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(
            subject.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.subjectText, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: image == null
                ? const Icon(PhosphorIconsRegular.bookOpen, color: AppColors.accentBlue, size: 36)
                : CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.contain,
                    errorWidget: (_, _, _) =>
                        const Icon(PhosphorIconsRegular.bookOpen, color: AppColors.accentBlue, size: 36),
                  ),
          ),
        ],
      ),
    );
  }
}
