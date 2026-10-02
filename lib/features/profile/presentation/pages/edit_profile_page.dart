import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/auth_widgets.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/domain/entities/lookup_option.dart';
import '../../../auth/domain/entities/profile_update.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_registration_options.dart';
import '../../../auth/presentation/cubit/registration_options_cubit.dart';
import '../../../auth/presentation/widgets/lookup_sheet.dart';
import '../cubit/profile_cubit.dart';

/// تعديل الاسم والمدرسة عبر `users/update`، وهي كل ما يقبل الخادم تعديله.
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.editProfile)),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) => previous.saveStatus != current.saveStatus,
        listener: (context, state) {
          switch (state.saveStatus) {
            case SaveStatus.saved:
              _showMessage(context, AppStrings.accountSaved);
              context.pop();
            case SaveStatus.failure:
              _showMessage(context, state.saveError ?? AppStrings.loadError);
            case SaveStatus.idle || SaveStatus.saving:
              break;
          }
        },
        builder: (context, state) {
          final user = state.user;
          if (user == null) return const LoadingView();
          return _EditProfileForm(
            // النسخة المحفوظة قد تختلف عمّا يصل من الخادم بعد لحظة (رد auth/active
            // لا يتضمن المدرسة مثلاً)، فيُبنى النموذج من جديد بقيم الخادم.
            key: ValueKey(user),
            user: user,
            saving: state.saveStatus == SaveStatus.saving,
          );
        },
      ),
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  const _EditProfileForm({super.key, required this.user, required this.saving});

  final User user;
  final bool saving;

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  late final _firstName = TextEditingController(text: widget.user.firstName);
  late final _lastName = TextEditingController(text: widget.user.lastName);
  late final _phone = TextEditingController(text: widget.user.phone);
  late final _governorateName = TextEditingController();
  late final _schoolName = TextEditingController(text: widget.user.school?.name);
  late String? _governorateId = widget.user.school?.governorateId;
  late String? _schoolId = widget.user.school?.id;

  @override
  void initState() {
    super.initState();
    // اسم المحافظة من قائمة الخادم، وقد تكون وصلت قبل بناء النموذج.
    _syncGovernorateName(context.read<RegistrationOptionsCubit>().state.governorates);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _governorateName.dispose();
    _schoolName.dispose();
    super.dispose();
  }

  void _syncGovernorateName(List<LookupOption> governorates) {
    for (final governorate in governorates) {
      if (governorate.id == _governorateId) _governorateName.text = governorate.name;
    }
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

  Future<void> _pickGovernorate() async {
    final options = context.read<RegistrationOptionsCubit>();
    final selected = await _pick(
      (state) => LookupSheet(
        title: AppStrings.governorateHint,
        status: state.status,
        items: state.governorates,
        error: state.error,
        onRetry: options.load,
      ),
    );
    if (selected == null || selected.id == _governorateId || !mounted) return;
    setState(() {
      _governorateId = selected.id;
      _governorateName.text = selected.name;
      // مدرسة المحافظة السابقة لم تعد ضمن القائمة.
      _schoolId = null;
      _schoolName.clear();
    });
  }

  Future<void> _pickSchool() async {
    final governorateId = _governorateId;
    if (governorateId == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text(AppStrings.pickGovernorateFirst)));
      return;
    }
    final options = context.read<RegistrationOptionsCubit>();
    // بلا نوع: المدارس والمعاهد معاً في المحافظة المختارة.
    final query = SchoolsQuery(governorateId: governorateId);
    final loaded = options.state.schoolsQuery == query && options.state.schoolsStatus != OptionsStatus.failure;
    if (!loaded) options.loadSchools(query);

    final selected = await _pick(
      (state) => LookupSheet(
        title: AppStrings.studyPlace,
        status: state.schoolsStatus,
        items: state.schools,
        error: state.schoolsError,
        onRetry: () => options.loadSchools(query),
        emptyMessage: AppStrings.noSchoolsInGovernorate,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _schoolId = selected.id;
      _schoolName.text = selected.name;
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
    return BlocListener<RegistrationOptionsCubit, RegistrationOptionsState>(
      listenWhen: (previous, current) => previous.governorates != current.governorates,
      listener: (_, options) => _syncGovernorateName(options.governorates),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        children: [
          const _Label(AppStrings.firstNameHint),
          AuthField(
            hint: AppStrings.firstNameHint,
            controller: _firstName,
            leading: const Icon(PhosphorIconsRegular.userCircle, color: AppColors.iconBlue, size: 20),
          ),
          const SizedBox(height: 14),
          const _Label(AppStrings.lastNameHint),
          AuthField(
            hint: AppStrings.lastNameHint,
            controller: _lastName,
            leading: const Icon(PhosphorIconsRegular.userCircle, color: AppColors.iconBlue, size: 20),
          ),
          const SizedBox(height: 14),
          const _Label(AppStrings.numberHint),
          // الهاتف هوية الحساب، فلا يُعدَّل.
          AuthField(
            hint: AppStrings.numberHint,
            controller: _phone,
            readOnly: true,
            leading: const Icon(PhosphorIconsRegular.phone, color: AppColors.iconBlue, size: 20),
          ),
          const SizedBox(height: 14),
          const _Label(AppStrings.governorateHint),
          AuthField(
            hint: AppStrings.governorateHint,
            controller: _governorateName,
            readOnly: true,
            onTap: _pickGovernorate,
            leading: const Icon(Icons.location_on_outlined, color: AppColors.iconBlue, size: 20),
            trailing: const Icon(PhosphorIconsRegular.caretDown, color: AppColors.iconBlue, size: 18),
          ),
          const SizedBox(height: 14),
          const _Label(AppStrings.studyPlace),
          AuthField(
            hint: AppStrings.pickStudyPlace,
            controller: _schoolName,
            readOnly: true,
            onTap: _pickSchool,
            leading: const Icon(PhosphorIconsRegular.graduationCap, color: AppColors.iconBlue, size: 20),
            trailing: const Icon(PhosphorIconsRegular.caretDown, color: AppColors.iconBlue, size: 18),
          ),
          const SizedBox(height: 28),
          AuthPrimaryButton(
            label: AppStrings.saveChanges,
            loading: widget.saving,
            // تغيير المحافظة يمسح المدرسة، والخادم يشترطها.
            onPressed: _schoolId == null ? null : _save,
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
      ),
    );
  }
}
