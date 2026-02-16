import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import '../../logic/auth_cubit.dart';
import '../../theme/app_theme.dart';
import '../common/primary_button.dart';
import '../main_shell.dart';
import '../onboarding/complete_profile_page.dart';

/// OTP Entry page with 6-digit input and resend cooldown.
class OtpPage extends StatefulWidget {
  /// Phone number that the code was sent to.
  final String phoneNumber;

  const OtpPage({
    super.key,
    required this.phoneNumber,
    required String fullName,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const int _otpLength = 6;
  static const int _cooldownSeconds = 60;

  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  Timer? _cooldownTimer;
  int _remainingCooldown = _cooldownSeconds;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and focus nodes
    for (int i = 0; i < _otpLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
    // Start cooldown timer
    _startCooldown();
    // Focus first box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _remainingCooldown = _cooldownSeconds;
      _canResend = false;
    });

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingCooldown > 0) {
        setState(() {
          _remainingCooldown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  String get _formattedCooldown {
    final minutes = _remainingCooldown ~/ 60;
    final seconds = _remainingCooldown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _fullOtp {
    return _controllers.map((c) => c.text).join();
  }

  void _verifyOtp() {
    final otp = _fullOtp;
    if (otp.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterAllDigits)),
      );
      return;
    }
    context.read<AuthCubit>().verifyOtp(widget.phoneNumber, otp);
  }

  void _showNameEntryDialog() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CompleteProfilePage()),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainShell()),
      (route) => false,
    );
  }

  void _clearOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _handleResend() {
    if (!_canResend) return;

    context.read<AuthCubit>().requestOtp(widget.phoneNumber);

    // Optimistic cooldown restart as per previous logic (or wait for success?)
    // User's previous logic had it restart immediately. I'll listen to state for toast.
    _startCooldown();
    _clearOtp();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _navigateToHome();
        } else if (state is AuthNewUser) {
          // If new user, logic might differ but assuming current flow:
          _showNameEntryDialog();
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        } else if (state is AuthOtpRequested) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.codeSentSuccess),
              backgroundColor: kPrimary,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: kBackground,
          appBar: AppBar(
            title: Text(l10n.verification, style: kTitleStyle),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: kTextPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    l10n.otpEnterCode,
                    style: kTitleStyle.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.sentCodeTo,
                    style: kBodyStyle.copyWith(color: kTextSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.phoneNumber,
                    style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  // OTP Boxes
                  _buildOtpBoxes(isLoading, state is AuthFailure),
                  const SizedBox(height: 16),
                  // Error message from state if we want to show it inline too
                  if (state is AuthFailure)
                    Text(
                      state.message,
                      style: kBodyStyle.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 24),
                  // Waiting indicator
                  if (isLoading)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.verifying,
                          style: kBodyStyle.copyWith(color: kTextSecondary),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.waitingTelegram,
                          style: kBodyStyle.copyWith(color: kTextSecondary),
                        ),
                      ],
                    ),
                  const SizedBox(height: 40),
                  _buildResendSection(l10n),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: l10n.verify,
                    onPressed: isLoading ? null : _verifyOtp,
                    isLoading: isLoading,
                    enabled: _fullOtp.length == _otpLength && !isLoading,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtpBoxes(bool isLoading, bool hasError) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_otpLength, (index) {
        return SizedBox(
          width: 48,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            enabled: !isLoading,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: kTitleStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: kCardBg,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: hasError
                      ? Colors.red
                      : kTextSecondary.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kPrimary, width: 2),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (value) => _onOtpChanged(index, value),
          ),
        );
      }),
    );
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    }
  }

  Widget _buildResendSection(AppLocalizations l10n) {
    if (_canResend) {
      return GestureDetector(
        onTap: _handleResend,
        child: Text(
          l10n.resendCode,
          style: kSubtitleStyle.copyWith(
            color: kPrimary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Text(
      '${l10n.resendCodeIn} $_formattedCooldown',
      style: kBodyStyle.copyWith(color: kTextSecondary),
      textAlign: TextAlign.center,
    );
  }
}
