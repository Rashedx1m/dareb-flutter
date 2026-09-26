import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/widgets/auth_widgets.dart';
import '../cubit/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _requestOtp() {
    context.read<AuthCubit>().requestOtp(_phone.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.otpRequested) {
            context.push('/otp', extra: _phone.text.trim());
          }
          final error = state.error;
          if (state.status == AuthStatus.failure && error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(error)));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const AuthHeader(height: 200),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  children: [
                    AuthFormCard(
                      child: Column(
                        children: [
                          const Text.rich(
                            TextSpan(
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                              children: [
                                TextSpan(text: AppStrings.loginTitle, style: TextStyle(color: AppColors.primary)),
                                TextSpan(text: AppStrings.txtAccount, style: TextStyle(color: AppColors.accentBlue)),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            AppStrings.loginSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 13),
                          ),
                          const SizedBox(height: 18),
                          AuthField(
                            hint: AppStrings.phoneHint,
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            leading: const Icon(PhosphorIconsRegular.phone, color: AppColors.iconBlue, size: 20),
                          ),
                          const SizedBox(height: 18),
                          AuthPrimaryButton(
                            label: AppStrings.login,
                            loading: state.isLoading,
                            onPressed: _requestOtp,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
