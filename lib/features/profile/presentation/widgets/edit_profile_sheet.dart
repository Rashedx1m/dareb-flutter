import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../auth/domain/entities/lookup_option.dart';
import '../../../auth/domain/entities/profile_update.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_registration_options.dart';
import '../../../auth/presentation/cubit/registration_options_cubit.dart';
import '../../../auth/presentation/widgets/lookup_sheet.dart';
import '../cubit/profile_cubit.dart';

/// ورقة «عدل معلوماتك الشخصية». تستخدم Cubit صفحة الملف نفسها، فيظهر الاسم
/// الجديد في الصفحة فور الحفظ.
Future<void> showEditProfileSheet(BuildContext context) async {
  final profile = context.read<ProfileCubit>();
  final user = profile.state.user;
  if (user == null) return;
  final saved = await showAppSheet<bool>(
    context,
    (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: profile),
        BlocProvider.value(value: context.read<RegistrationOptionsCubit>()),
      ],
      child: EditProfileSheet(user: user),
    ),
  );
  if (saved != true || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text(AppStrings.accountSaved)));
}

/// الاسم والكنية والمدرسة، وهي كل ما يقبل الخادم تعديله في `users/update`.
class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key, required this.user});

  final User user;

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final _firstName = TextEditingController(text: widget.user.firstName);
  late final _lastName = TextEditingController(text: widget.user.lastName);
  late final _schoolName = TextEditingController(text: widget.user.school?.name);
  late String? _schoolId = widget.user.school?.id;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _schoolName.dispose();
    super.dispose();
  }

  /// قائمة سفلية تتابع حالة قوائم الخادم، فتعرض التحميل أو الخطأ إن فُتحت قبل وصولها.
  Future<LookupOption?> _pick(LookupSheet Function(RegistrationOptionsState state) sheet) {
    return LookupSheet.show(
      context,
      BlocProvider.value(
        value: context.read<RegistrationOptionsCubit>(),
        child: BlocBuilder<RegistrationOptionsCubit, RegistrationOptionsState>(
          builder: (_, state) => sheet(state),
        ),
      ),
    );
  }

  /// المحافظة أولاً ثم مدارسها، حتى لا تطول القائمة بمدارس كل المحافظات.
  Future<void> _pickSchool() async {
    final options = context.read<RegistrationOptionsCubit>();
    final governorate = await _pick(
      (state) => LookupSheet(
        title: AppStrings.governorateHint,
        status: state.status,
        items: state.governorates,
        error: state.error,
        onRetry: options.load,
      ),
    );
    if (governorate == null || !mounted) return;

    // بلا نوع: المدارس والمعاهد معاً في المحافظة المختارة.
    final query = SchoolsQuery(governorateId: governorate.id);
    final loaded = options.state.schoolsQuery == query && options.state.schoolsStatus != OptionsStatus.failure;
    if (!loaded) options.loadSchools(query);
    final school = await _pick(
      (state) => LookupSheet(
        title: AppStrings.schoolHint,
        status: state.schoolsStatus,
        items: state.schools,
        error: state.schoolsError,
        onRetry: () => options.loadSchools(query),
        emptyMessage: AppStrings.noSchoolsInGovernorate,
      ),
    );
    if (school == null || !mounted) return;
    setState(() {
      _schoolId = school.id;
      _schoolName.text = school.name;
    });
  }

  void _save() {
    final schoolId = _schoolId;
    if (schoolId == null) return;
    // التحقق من الاسم في المستودع، ورسالته تصل كفشل حفظ.
    context.read<ProfileCubit>().save(
          ProfileUpdate(
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            schoolId: schoolId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) => previous.saveStatus != current.saveStatus,
      listener: (context, state) {
        if (state.saveStatus == SaveStatus.saved) Navigator.of(context).pop(true);
      },
      buildWhen: (previous, current) => previous.saveStatus != current.saveStatus,
      builder: (context, state) {
        final error = state.saveError;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHeader(title: AppStrings.editSheetTitle, icon: PhosphorIconsRegular.notePencil),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SheetField(
                    hint: AppStrings.firstNameHint,
                    icon: PhosphorIconsRegular.userCircle,
                    controller: _firstName,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SheetField(
                    hint: AppStrings.lastNameHint,
                    icon: PhosphorIconsRegular.userCircle,
                    controller: _lastName,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SheetField(
              hint: AppStrings.schoolHint,
              icon: PhosphorIconsRegular.graduationCap,
              controller: _schoolName,
              readOnly: true,
              onTap: _pickSchool,
              trailing: const Icon(PhosphorIconsRegular.caretDown, color: AppColors.iconBlue, size: 18),
            ),
            if (state.saveStatus == SaveStatus.failure && error != null) ...[
              const SizedBox(height: 12),
              Text(error, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            ],
            const SizedBox(height: 24),
            SheetActions(
              primaryLabel: AppStrings.editAction,
              // الخادم يشترط المدرسة.
              onPrimary: _schoolId == null ? null : _save,
              loading: state.saveStatus == SaveStatus.saving,
            ),
          ],
        );
      },
    );
  }
}
