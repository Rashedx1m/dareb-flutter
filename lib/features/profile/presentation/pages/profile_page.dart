import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../auth/domain/entities/profile_image.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../support/presentation/widgets/about_sheet.dart';
import '../../../support/presentation/widgets/contact_sheet.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/edit_profile_sheet.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// صورة من المعرض، مصغّرة قبل الرفع. الضغط بجودة أقل من 100 يجعل الناتج JPEG.
  Future<void> _pickAvatar(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return;
    cubit.changeAvatar(ProfileImage(bytes: await file.readAsBytes(), fileName: file.name));
  }

  Future<void> _logout(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final confirmed = await showConfirmDialog(context, title: AppStrings.logoutConfirm);
    if (confirmed) cubit.logout();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) =>
          previous.loggedOut != current.loggedOut || previous.avatarStatus != current.avatarStatus,
      listener: (context, state) {
        if (state.loggedOut) {
          context.go('/login');
          return;
        }
        switch (state.avatarStatus) {
          case SaveStatus.saved:
            _showMessage(context, AppStrings.avatarUpdated);
          case SaveStatus.failure:
            _showMessage(context, state.avatarError ?? AppStrings.loadError);
          case SaveStatus.idle || SaveStatus.saving:
            break;
        }
      },
      builder: (context, state) {
        final user = state.user;
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              PageHeader(
                title: AppStrings.profileTitle,
                titleIcon: PhosphorIconsFill.graduationCap,
                onNotifications: () => context.push('/notifications'),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _ProfileCard(
                      user: user,
                      uploading: state.avatarStatus == SaveStatus.saving,
                      onAvatarTap: () => _pickAvatar(context),
                    ),
                    const Divider(height: 1, thickness: 1, color: AppColors.divider),
                    const _SectionTitle(AppStrings.supportSection),
                    _MenuItem(PhosphorIconsRegular.question, AppStrings.faq, () => context.push('/faq')),
                    _MenuItem(
                      PhosphorIconsRegular.headset,
                      AppStrings.contact,
                      () => showContactSheet(context, user: user),
                    ),
                    _MenuItem(
                      PhosphorIconsRegular.envelopeSimpleOpen,
                      AppStrings.subscription,
                      () => context.push('/subscription'),
                    ),
                    _MenuItem(PhosphorIconsRegular.medal, AppStrings.achievements, () => context.push('/achievements')),
                    _MenuItem(PhosphorIconsRegular.info, AppStrings.about, () => showAboutSheet(context)),
                    _MenuItem(PhosphorIconsRegular.fileText, AppStrings.privacyPolicy, () => context.push('/privacy')),
                    _MenuItem(
                      PhosphorIconsRegular.bookOpenUser,
                      AppStrings.downloadedCourses,
                      () => context.push('/downloads'),
                    ),
                    _MenuItem(PhosphorIconsRegular.scroll, AppStrings.usagePolicy, () => context.push('/usage-policy')),
                    _MenuItem(PhosphorIconsRegular.exam, AppStrings.myTests, () => context.push('/tests')),
                    const SizedBox(height: 12),
                    const ColoredBox(color: AppColors.divider, child: SizedBox(height: 4, width: double.infinity)),
                    const _SectionTitle(AppStrings.settingsSection),
                    _MenuItem(
                      PhosphorIconsRegular.notePencil,
                      AppStrings.editProfileItem,
                      () => showEditProfileSheet(context),
                    ),
                    _MenuItem(PhosphorIconsRegular.signOut, AppStrings.logout, () => _logout(context)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// بطاقة الصورة والاسم والإحصاءات. الصورة تتجاوز حافة البطاقة العليا كما في التصميم.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user, required this.uploading, required this.onAvatarTap});

  final User? user;
  final bool uploading;
  final VoidCallback onAvatarTap;

  static const _avatarSize = 160.0;

  /// الجزء الظاهر من الصورة فوق البطاقة.
  static const _overlap = 41.0;

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: _overlap),
            padding: const EdgeInsets.fromLTRB(10, _avatarSize - _overlap + 10, 10, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Text(
                  user?.name ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.nameDark, fontSize: 23, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1, color: AppColors.cardBorder),
                const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      _Stat(value: user?.semestersCount ?? 0, label: AppStrings.statSemesters),
                      const _StatDivider(),
                      _Stat(value: user?.points ?? 0, label: AppStrings.statPoints),
                      const _StatDivider(),
                      _Stat(value: user?.enrolledCoursesCount ?? 0, label: AppStrings.statCourses),
                      const _StatDivider(),
                      // الخادم لا يعيد عدد الدروس بعد.
                      const _Stat(value: 0, label: AppStrings.statLessons),
                      const _StatDivider(),
                      _Stat(value: user?.medalsCount ?? 0, label: AppStrings.statMedals),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _Avatar(url: user?.avatarUrl, size: _avatarSize, uploading: uploading, onTap: onAvatarTap),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.size, required this.uploading, required this.onTap});

  final String? url;
  final double size;
  final bool uploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    const placeholder = Image(image: AssetImage(AppAssets.studentWriting), fit: BoxFit.cover);
    return Semantics(
      button: true,
      label: AppStrings.editProfile,
      child: GestureDetector(
        onTap: uploading ? null : onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipOval(
                  child: ColoredBox(
                    color: AppColors.avatarBg,
                    child: url == null
                        ? placeholder
                        : CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => placeholder,
                            errorWidget: (_, _, _) => placeholder,
                          ),
                  ),
                ),
              ),
              if (uploading)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Color(0x66000000), shape: BoxShape.circle),
                    child: Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
                ),
              // التصميم لا يحدد مكاناً لتغيير الصورة، فأُضيفت شارة صغيرة تدل عليه.
              PositionedDirectional(
                bottom: 8,
                end: 8,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(PhosphorIconsFill.camera, color: Colors.white, size: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontFamily: 'Lato',
              color: AppColors.statTeal,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.statLabel, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return const VerticalDivider(width: 1, thickness: 1, indent: 4, endIndent: 4, color: AppColors.statDivider);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.listText, fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 47,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.iconBlue, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label, style: const TextStyle(color: AppColors.listText, fontSize: 16)),
              ),
              const Icon(PhosphorIconsRegular.caretLeft, color: AppColors.listText, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
