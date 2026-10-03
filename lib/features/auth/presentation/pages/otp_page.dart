import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/auth_widgets.dart';
import '../../domain/auth_validators.dart';
import '../cubit/auth_cubit.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.phone});

  final String phone;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  /// مهلة إعادة إرسال الرمز بالثواني.
  static const _resendCooldown = 55;

  String _code = '';
  int _seconds = _resendCooldown;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isComplete => _code.length == AuthValidators.otpLength;

  void _append(String value) {
    if (_isComplete) return;
    setState(() => _code += value);
  }

  void _backspace() {
    if (_code.isEmpty) return;
    setState(() => _code = _code.substring(0, _code.length - 1));
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 1) {
        timer.cancel();
        setState(() => _seconds = 0);
        return;
      }
      setState(() => _seconds -= 1);
    });
  }

  void _resend() {
    setState(() {
      _code = '';
      _seconds = _resendCooldown;
    });
    _startTimer();
    context.read<AuthCubit>().requestOtp(widget.phone);
  }

  String get _formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go('/home');
          } else if (state.status == AuthStatus.otpVerified) {
            context.go('/register', extra: widget.phone);
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
              AuthHeader(onBack: () => context.pop(), height: 200),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                        children: [
                          const Text.rich(
                            TextSpan(
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                              children: [
                                TextSpan(text: AppStrings.otpTitle, style: TextStyle(color: AppColors.primary)),
                                TextSpan(text: AppStrings.otpTitleHighlight, style: TextStyle(color: AppColors.accentBlue)),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${AppStrings.otpSubtitle} : ${widget.phone}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 22),
                          _CodeBoxes(code: _code),
                          const SizedBox(height: 14),
                          Text.rich(
                            TextSpan(
                              style: const TextStyle(fontSize: 12),
                              children: [
                                const TextSpan(
                                  text: '${AppStrings.codeExpired} ',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                                TextSpan(
                                  text: _seconds > 0 ? _formattedTime : AppStrings.timeEnded,
                                  style: TextStyle(
                                    color: _seconds == 0 ? AppColors.primary : AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: _seconds == 0 ? _resend : null,
                            child: const Text(
                              AppStrings.resendCode,
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                            ),
                          ),
                          AuthPrimaryButton(
                            label: AppStrings.confirm,
                            loading: state.isLoading,
                            onPressed: _isComplete
                                ? () => context.read<AuthCubit>().verifyOtp(
                                      phone: widget.phone,
                                      otp: _code,
                                    )
                                : null,
                          ),
                        ],
                      ),
                    ),
                    NumericKeypad(onKey: _append, onBackspace: _backspace),
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

class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(AuthValidators.otpLength, (index) {
          final filled = index < code.length;
          final active = index == code.length;
          return Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.fieldBorder,
                width: active ? 1.5 : 1,
              ),
            ),
            child: switch ((filled, active)) {
              (true, _) => Text(
                  code[index],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              (false, true) => const Text('|', style: TextStyle(color: AppColors.primary, fontSize: 20)),
              (false, false) => const Text('-', style: TextStyle(color: AppColors.textMuted, fontSize: 22)),
            },
          );
        }),
      ),
    );
  }
}
