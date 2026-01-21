import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/auth_repository.dart';
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
  final _authRepository = AuthRepository();

  Timer? _cooldownTimer;
  int _remainingCooldown = _cooldownSeconds;
  bool _canResend = false;
  bool _isVerifying = false;
  String? _errorMessage;

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

  Future<void> _verifyOtp() async {
    final otp = _fullOtp;

    if (otp.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final result = await _authRepository.verifyOtp(widget.phoneNumber, otp);

      if (!mounted) return;

      setState(() {
        _isVerifying = false;
      });

      if (result.success) {
        if (result.isNewUser) {
          _showNameEntryDialog();
        } else {
          _navigateToHome();
        }
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Verification failed';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isVerifying = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _showNameEntryDialog() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CompleteProfilePage()),
    );
  }

  void _navigateToHome() {
    // Navigate to MainShell and clear the navigation stack
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

  Future<void> _handleResend() async {
    if (!_canResend) return;

    setState(() => _canResend = false);

    try {
      await _authRepository.requestOtp(widget.phoneNumber);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Code resent'),
          backgroundColor: kPrimary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      // Restart cooldown
      _startCooldown();
      _clearOtp();
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceAll('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      // Let user try again sooner if failed? Or keep cooldown?
      // Keeping cooldown to prevent spam even on errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text('Verification', style: kTitleStyle),
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
              // Header
              Text('Enter Code', style: kTitleStyle.copyWith(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to',
                style: kBodyStyle.copyWith(color: kTextSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                widget.phoneNumber,
                style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              // OTP Boxes
              _buildOtpBoxes(),
              const SizedBox(height: 16),
              // Error message
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: kBodyStyle.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              // Waiting indicator
              if (_isVerifying)
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
                      'Verifying...',
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
                      'Waiting for Telegram message...',
                      style: kBodyStyle.copyWith(color: kTextSecondary),
                    ),
                  ],
                ),
              const SizedBox(height: 40),
              // Resend / Cooldown
              _buildResendSection(),
              const SizedBox(height: 32),
              // Verify Button
              PrimaryButton(
                label: 'Verify',
                onPressed: _isVerifying ? null : _verifyOtp,
                isLoading: _isVerifying,
                enabled: _fullOtp.length == _otpLength && !_isVerifying,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_otpLength, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          // Removed KeyboardListener to fix the exception.
          // FocusNode now handles the key events directly.
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
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
                  color: _errorMessage != null
                      ? Colors.red
                      : kTextSecondary.withOpacity(0.3),
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

  Widget _buildResendSection() {
    if (_canResend) {
      return GestureDetector(
        onTap: _handleResend,
        child: Text(
          'Resend code',
          style: kSubtitleStyle.copyWith(
            color: kPrimary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Text(
      'Resend code in $_formattedCooldown',
      style: kBodyStyle.copyWith(color: kTextSecondary),
      textAlign: TextAlign.center,
    );
  }
}
