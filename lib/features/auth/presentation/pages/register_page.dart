import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/auth_widgets.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/auth_validators.dart';
import '../../domain/entities/lookup_option.dart';
import '../../domain/entities/registration_details.dart';
import '../../domain/usecases/get_registration_options.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/registration_options_cubit.dart';
import '../widgets/lookup_sheet.dart';

enum _RegisterStep { info, source, schoolType, school, gender, age, branch, success }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.phone});

  final String? phone;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const _minAge = 10;
  static const _maxAge = 80;

  _RegisterStep _step = _RegisterStep.info;
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _governorateName = TextEditingController();
  bool _acceptedTerms = false;
  AppSource? _source;
  SchoolKind? _schoolKind;
  LookupOption? _governorate;
  String? _schoolId;
  Gender? _gender;
  String? _branchId;
  int _age = 26;

  @override
  void initState() {
    super.initState();
    final phone = widget.phone;
    if (phone != null) _phone.text = phone;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _governorateName.dispose();
    super.dispose();
  }

  void _goTo(_RegisterStep next) => setState(() => _step = next);

  void _goBack() {
    _goTo(switch (_step) {
      _RegisterStep.source => _RegisterStep.info,
      _RegisterStep.schoolType => _RegisterStep.source,
      _RegisterStep.school => _RegisterStep.schoolType,
      _RegisterStep.gender => _RegisterStep.school,
      _RegisterStep.age => _RegisterStep.gender,
      _RegisterStep.branch => _RegisterStep.age,
      _ => _step,
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showTerms() async {
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => TermsSheet(
        onAccept: () => Navigator.pop(sheetContext, true),
      ),
    );
    if (!mounted) return;
    setState(() => _acceptedTerms = accepted ?? false);
  }

  /// يتحقق من خطوة البيانات الأساسية قبل الانتقال إلى بقية الأسئلة.
  void _submitInfo() {
    final error = AuthValidators.name(_firstName.text) ??
        AuthValidators.name(_lastName.text) ??
        AuthValidators.email(_email.text);
    if (error != null) {
      _showError(error);
      return;
    }
    if (!_acceptedTerms) {
      _showTerms();
      return;
    }
    _goTo(_RegisterStep.source);
  }

  void _submit() {
    context.read<AuthCubit>().register(
          RegistrationDetails(
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            email: _email.text.trim(),
            source: _source!,
            schoolId: _schoolId!,
            gender: _gender!,
            age: _age,
            branchId: _branchId!,
          ),
        );
  }

  void _selectSchoolKind(SchoolKind kind) {
    if (kind == _schoolKind) return;
    setState(() {
      _schoolKind = kind;
      // مدرسة من النوع السابق لم تعد ضمن القائمة.
      _schoolId = null;
    });
  }

  /// يطلب مدارس النوع والمحافظة المختارين.
  void _loadSchools() {
    context.read<RegistrationOptionsCubit>().loadSchools(
          SchoolsQuery(kind: _schoolKind, governorateId: _governorate?.id),
        );
  }

  /// حقل المحافظة لا يظهر إلا بعد وصول القائمة، فتُعرض جاهزة.
  Future<void> _pickGovernorate(List<LookupOption> governorates) async {
    final selected = await LookupSheet.show(
      context,
      LookupSheet(
        title: AppStrings.governorateHint,
        status: OptionsStatus.success,
        items: governorates,
        onRetry: context.read<RegistrationOptionsCubit>().load,
      ),
    );
    if (selected == null || selected == _governorate || !mounted) return;
    setState(() {
      _governorate = selected;
      _governorateName.text = selected.name;
      _schoolId = null;
    });
    _loadSchools();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            _goTo(_RegisterStep.success);
          }
          final error = state.error;
          if (state.status == AuthStatus.failure && error != null) {
            _showError(error);
          }
        },
        builder: (context, state) {
          if (_step == _RegisterStep.success) {
            return _SuccessView(onHome: () => context.go('/home'));
          }
          return Column(
            children: [
              AuthHeader(
                onBack: _step == _RegisterStep.info ? () => context.go('/login') : _goBack,
                height: 200,
              ),
              Expanded(
                child: BlocBuilder<RegistrationOptionsCubit, RegistrationOptionsState>(
                  builder: (context, options) => _body(state, options),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _body(AuthState state, RegistrationOptionsState options) {
    return switch (_step) {
      _RegisterStep.info => _infoStep(),
      _RegisterStep.source => _sourceStep(),
      _RegisterStep.schoolType => _schoolTypeStep(),
      _RegisterStep.school => _schoolStep(options),
      _RegisterStep.gender => _genderStep(),
      _RegisterStep.age => _ageStep(),
      _RegisterStep.branch => _branchStep(state, options),
      // تُعالَج في `build` قبل الوصول إلى هنا.
      _RegisterStep.success => const SizedBox.shrink(),
    };
  }

  Widget _registerTitle() {
    return Column(
      children: [
        const Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            children: [
              TextSpan(text: AppStrings.registerTitle, style: TextStyle(color: AppColors.primary)),
              TextSpan(text: AppStrings.registerTitleHighlight, style: TextStyle(color: AppColors.accentBlue)),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          AppStrings.registerSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.primary, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  Widget _infoStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
      children: [
        _registerTitle(),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: AuthField(
                hint: AppStrings.firstNameHint,
                controller: _firstName,
                leading: const Icon(PhosphorIconsRegular.userCircle, color: AppColors.iconBlue, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AuthField(
                hint: AppStrings.lastNameHint,
                controller: _lastName,
                leading: const Icon(PhosphorIconsRegular.userCircle, color: AppColors.iconBlue, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AuthField(
          hint: AppStrings.emailHint,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          leading: const Icon(PhosphorIconsRegular.envelopeSimple, color: AppColors.iconBlue, size: 20),
        ),
        const SizedBox(height: 12),
        // الرقم تحقّق منه الخادم عند إدخال الرمز، فيُعرض للقراءة فقط.
        AuthField(
          hint: AppStrings.numberHint,
          controller: _phone,
          readOnly: true,
          leading: const Icon(PhosphorIconsRegular.phone, color: AppColors.iconBlue, size: 20),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _showTerms,
              child: const Text(
                AppStrings.acceptTerms,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: _acceptedTerms,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                checkColor: Colors.white,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.selected) ? AppColors.success : Colors.white;
                }),
                side: const BorderSide(color: AppColors.success, width: 1.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                // الموافقة لا تتم إلا بعد عرض النص، أما سحبها فمباشر.
                onChanged: (value) {
                  if (value == true) {
                    _showTerms();
                  } else {
                    setState(() => _acceptedTerms = false);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AuthPrimaryButton(label: AppStrings.next, onPressed: _submitInfo),
      ],
    );
  }

  Widget _sourceStep() {
    // شبكة من 3 أعمدة كما في التصميم (المدرسة/صديق/فيسبوك ثم انستا/يوتيوب/غير ذلك).
    const options = <(IconData, String, AppSource)>[
      (PhosphorIconsRegular.graduationCap, AppStrings.sourceSchool, AppSource.school),
      (PhosphorIconsRegular.users, AppStrings.sourceFriend, AppSource.friend),
      (PhosphorIconsRegular.facebookLogo, AppStrings.sourceFacebook, AppSource.facebook),
      (PhosphorIconsRegular.instagramLogo, AppStrings.sourceInstagram, AppSource.instagram),
      (PhosphorIconsRegular.youtubeLogo, AppStrings.sourceYoutube, AppSource.youtube),
      (PhosphorIconsRegular.dotsThreeCircle, AppStrings.sourceOther, AppSource.other),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
      children: [
        const Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            children: [
              TextSpan(text: AppStrings.howDidYouKnow, style: TextStyle(color: AppColors.primary)),
              TextSpan(text: AppStrings.howDidYouKnowHighlight, style: TextStyle(color: AppColors.accentBlue)),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: [
            for (final (icon, label, source) in options)
              SourceChoice(
                label: label,
                icon: icon,
                selected: _source == source,
                onTap: () => setState(() => _source = source),
              ),
          ],
        ),
        const SizedBox(height: 32),
        AuthPrimaryButton(
          label: AppStrings.next,
          onPressed: _source == null ? null : () => _goTo(_RegisterStep.schoolType),
        ),
      ],
    );
  }

  Widget _schoolTypeStep() {
    return StepLayout(children: [
      const RegisterProgress(current: 1),
      _registerTitle(),
      const SizedBox(height: 22),
      ChoiceCard(
        title: AppStrings.schoolKindSchool,
        subtitle: AppStrings.schoolKindSchoolDesc,
        icon: PhosphorIconsRegular.graduationCap,
        selected: _schoolKind == SchoolKind.school,
        onTap: () => _selectSchoolKind(SchoolKind.school),
      ),
      const SizedBox(height: 12),
      ChoiceCard(
        title: AppStrings.schoolKindInstitute,
        subtitle: AppStrings.schoolKindInstituteDesc,
        icon: PhosphorIconsRegular.bank,
        selected: _schoolKind == SchoolKind.institute,
        onTap: () => _selectSchoolKind(SchoolKind.institute),
      ),
      const Spacer(),
      AuthPrimaryButton(
        label: AppStrings.next,
        onPressed: _schoolKind == null
            ? null
            : () {
                _goTo(_RegisterStep.school);
                // إن اختيرت المحافظة سابقاً، تُحدَّث مدارسها بحسب النوع الحالي.
                if (_governorate != null) _loadSchools();
              },
      ),
    ]);
  }

  /// المحافظة ثم مدارسها من النوع المختار في الخطوة السابقة.
  Widget _schoolStep(RegistrationOptionsState options) {
    final kindIcon =
        _schoolKind == SchoolKind.institute ? PhosphorIconsRegular.bank : PhosphorIconsRegular.graduationCap;
    return StepLayout(children: [
      const RegisterProgress(current: 1),
      _registerTitle(),
      const SizedBox(height: 22),
      ...switch (options.status) {
        OptionsStatus.failure => [
            ErrorView(message: options.error, onRetry: context.read<RegistrationOptionsCubit>().load),
          ],
        OptionsStatus.success => [
            AuthField(
              hint: AppStrings.governorateHint,
              controller: _governorateName,
              readOnly: true,
              leading: const Icon(Icons.location_on_outlined, color: AppColors.iconBlue, size: 20),
              trailing: const Icon(PhosphorIconsRegular.caretDown, color: AppColors.iconBlue, size: 18),
              onTap: () => _pickGovernorate(options.governorates),
            ),
            const SizedBox(height: 16),
            ..._schoolChoices(options, kindIcon),
          ],
        _ => [const SizedBox(height: 120, child: LoadingView())],
      },
      const Spacer(),
      AuthPrimaryButton(
        label: AppStrings.next,
        onPressed: _schoolId == null ? null : () => _goTo(_RegisterStep.gender),
      ),
    ]);
  }

  List<Widget> _schoolChoices(RegistrationOptionsState options, IconData icon) {
    if (_governorate == null) return [_hint(AppStrings.pickGovernorateFirst)];
    return switch (options.schoolsStatus) {
      OptionsStatus.failure => [ErrorView(message: options.schoolsError, onRetry: _loadSchools)],
      OptionsStatus.success when options.schools.isEmpty => [_hint(AppStrings.noSchoolsFound)],
      OptionsStatus.success => [
          for (final school in options.schools)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ChoiceCard(
                title: school.name,
                icon: icon,
                selected: _schoolId == school.id,
                onTap: () => setState(() => _schoolId = school.id),
              ),
            ),
        ],
      _ => [const SizedBox(height: 120, child: LoadingView())],
    };
  }

  Widget _hint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
      ),
    );
  }

  Widget _genderStep() {
    return StepLayout(children: [
      const RegisterProgress(current: 2),
      _registerTitle(),
      const SizedBox(height: 28),
      SelectOption(
        title: AppStrings.male,
        icon: PhosphorIconsRegular.genderMale,
        selected: _gender == Gender.male,
        onTap: () => setState(() => _gender = Gender.male),
      ),
      const SizedBox(height: 12),
      SelectOption(
        title: AppStrings.female,
        icon: PhosphorIconsRegular.genderFemale,
        selected: _gender == Gender.female,
        onTap: () => setState(() => _gender = Gender.female),
      ),
      const Spacer(),
      AuthPrimaryButton(
        label: AppStrings.next,
        onPressed: _gender == null ? null : () => _goTo(_RegisterStep.age),
      ),
    ]);
  }

  Widget _ageStep() {
    return StepLayout(children: [
      const RegisterProgress(current: 2),
      _registerTitle(),
      const Spacer(),
      const Text(
        AppStrings.ageLabel,
        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
      ),
      const SizedBox(height: 8),
      Text(
        '$_age',
        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      ),
      const SizedBox(height: 18),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AgeButton(
            icon: Icons.remove,
            onTap: _age > _minAge ? () => setState(() => _age -= 1) : null,
          ),
          const SizedBox(width: 48),
          _AgeButton(
            icon: Icons.add,
            onTap: _age < _maxAge ? () => setState(() => _age += 1) : null,
          ),
        ],
      ),
      const Spacer(),
      Row(
        children: [
          Expanded(
            child: AuthPrimaryButton(
              label: AppStrings.next,
              onPressed: () => _goTo(_RegisterStep.branch),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AuthOutlinedButton(label: AppStrings.back, onPressed: _goBack),
          ),
        ],
      ),
    ]);
  }

  /// الفرع الدراسي من قائمة الخادم (حُمّلت مع المحافظات عند فتح الصفحة).
  Widget _branchStep(AuthState state, RegistrationOptionsState options) {
    return StepLayout(children: [
      const RegisterProgress(current: 2),
      _registerTitle(),
      const SizedBox(height: 22),
      ...switch (options.status) {
        OptionsStatus.failure => [
            ErrorView(message: options.error, onRetry: context.read<RegistrationOptionsCubit>().load),
          ],
        OptionsStatus.success => [
            for (final branch in options.branches)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ChoiceCard(
                  title: branch.name,
                  icon: PhosphorIconsRegular.bookOpen,
                  selected: _branchId == branch.id,
                  onTap: () => setState(() => _branchId = branch.id),
                ),
              ),
          ],
        _ => [const SizedBox(height: 120, child: LoadingView())],
      },
      const Spacer(),
      AuthPrimaryButton(
        label: AppStrings.confirm,
        loading: state.isLoading,
        onPressed: _branchId == null ? null : _submit,
      ),
    ]);
  }
}

class _AgeButton extends StatelessWidget {
  const _AgeButton({required this.icon, required this.onTap});

  final IconData icon;

  /// `null` عند بلوغ حدّ العمر، فيظهر الزر معطّلاً.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = onTap == null ? AppColors.textMuted : AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onHome});
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: StepLayout(
          padding: const EdgeInsets.all(28),
          children: [
            const Spacer(),
            const SuccessBadge(),
            const SizedBox(height: 22),
            const Text(
              AppStrings.congrats,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.sourceSelected),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.congratsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const Spacer(),
            AuthPrimaryButton(label: AppStrings.goHome, onPressed: onHome),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
