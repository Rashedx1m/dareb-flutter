import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/domain/entities/user.dart';
import '../cubit/profile_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.loggedOut) context.go('/login');
      },
      builder: (context, state) {
        final user = state.user;
        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.profile)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (user == null)
                const SizedBox(height: 130, child: LoadingView())
              else
                _ProfileHeader(user: user),
              const SizedBox(height: 20),
              _Item(Icons.edit_outlined, AppStrings.editProfile, () => context.push('/edit-profile')),
              _Item(Icons.menu_book_outlined, AppStrings.myCourses, () => context.push('/my-courses')),
              _Item(Icons.emoji_events_outlined, AppStrings.achievements, () => context.push('/achievements')),
              _Item(Icons.workspace_premium_outlined, AppStrings.subscription, () => context.push('/subscription')),
              _Item(Icons.help_outline, AppStrings.faq, () => context.push('/faq')),
              _Item(Icons.info_outline, AppStrings.about, () => context.push('/about')),
              _Item(Icons.mail_outline, AppStrings.contact, () => context.push('/contact')),
              _Item(Icons.logout, AppStrings.logout, () => context.read<ProfileCubit>().logout(), danger: true),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl;
    return Column(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundImage: avatarUrl == null ? null : NetworkImage(avatarUrl),
          child: avatarUrl == null ? const Icon(Icons.person, size: 40) : null,
        ),
        const SizedBox(height: 10),
        Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        Text(user.phone, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.icon, this.label, this.onTap, {this.danger = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: danger ? AppColors.danger : AppColors.primary),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: danger ? AppColors.danger : null)),
        trailing: const Icon(Icons.chevron_left),
      ),
    );
  }
}
