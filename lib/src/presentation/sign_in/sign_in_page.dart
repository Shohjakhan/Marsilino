import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/auth_repository.dart';
import '../../theme/app_theme.dart';
import '../common/primary_button.dart';
import 'otp_page.dart';

/// Sign In page with phone input only.
/// Allows user to request OTP via Telegram.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    // Remove formatting characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 12) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  Future<void> _handleSendCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _authRepository.requestOtp(_phoneController.text);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Code sent successfully'),
          backgroundColor: kPrimary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OtpPage(phoneNumber: _phoneController.text, fullName: ''),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to send code'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text('Sign In', style: kTitleStyle),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Header
                Text('Welcome Back', style: kTitleStyle.copyWith(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone number to sign in',
                  style: kBodyStyle.copyWith(color: kTextSecondary),
                ),
                const SizedBox(height: 48),
                // Phone Number Field
                _buildLabel('Phone Number'),
                const SizedBox(height: 8),
                _buildPhoneField(),
                const SizedBox(height: 32),
                // Info text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: kPrimary.withValues(alpha: 0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "We'll send a 6-digit code via Telegram to verify your phone number.",
                          style: kBodyStyle.copyWith(
                            color: kPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Send Code Button
                PrimaryButton(
                  label: 'Send code via Telegram',
                  onPressed: _isLoading ? null : _handleSendCode,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: kBodyStyle.copyWith(
        fontWeight: FontWeight.w500,
        color: kTextSecondary,
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      validator: _validatePhone,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+]')),
        _PhoneInputFormatter(),
      ],
      style: kBodyStyle.copyWith(fontSize: 16, color: kTextPrimary),
      decoration: InputDecoration(
        hintText: '+998 __ ___ __ __',
        hintStyle: kBodyStyle.copyWith(fontSize: 16, color: kTextSecondary),
        prefixIcon: const Icon(
          Icons.phone_outlined,
          color: kTextSecondary,
          size: 20,
        ),
        filled: true,
        fillColor: kCardBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: kTextSecondary.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: kTextSecondary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

/// Phone input formatter for Uzbekistan format: +998 XX XXX XX XX
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Get only digits
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Ensure it starts with 998 for Uzbekistan
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '+998 ',
        selection: TextSelection.collapsed(offset: 5),
      );
    }

    // Remove leading 998 if present to avoid duplication
    if (digitsOnly.startsWith('998')) {
      digitsOnly = digitsOnly.substring(3);
    }

    // Limit to 9 digits after country code
    if (digitsOnly.length > 9) {
      digitsOnly = digitsOnly.substring(0, 9);
    }

    // Format: +998 XX XXX XX XX
    final buffer = StringBuffer('+998 ');

    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 5 || i == 7) {
        buffer.write(' ');
      }
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
