import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Input field mode for different styling and behavior.
enum InputFieldMode {
  /// Standard text input.
  text,

  /// Numeric input with optional thousand separators.
  numeric,

  /// OTP single box styled input.
  otp,
}

/// A reusable input field component with customizable styling.
/// Supports text, numeric (with thousand separators), and OTP modes.
class InputField extends StatelessWidget {
  /// Placeholder/hint text.
  final String? placeholder;

  /// Label text displayed above the input.
  final String? label;

  /// Icon displayed at the start of the input.
  final IconData? icon;

  /// Suffix icon displayed at the end of the input.
  final Widget? suffixIcon;

  /// Keyboard type for the input.
  final TextInputType? keyboardType;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when editing is complete.
  final VoidCallback? onEditingComplete;

  /// Text controller for the input.
  final TextEditingController? controller;

  /// Input field mode (text, numeric, otp).
  final InputFieldMode mode;

  /// Whether to format numeric input with thousand separators.
  final bool useThousandSeparators;

  /// Whether the input is obscured (for passwords).
  final bool obscureText;

  /// Whether the input is enabled.
  final bool enabled;

  /// Maximum length for the input.
  final int? maxLength;

  /// Focus node for the input.
  final FocusNode? focusNode;

  /// Text alignment.
  final TextAlign textAlign;

  /// Border radius override (default 14px).
  final double borderRadius;

  /// Maximum lines for the input.
  final int? maxLines;

  /// Text input action.
  final TextInputAction? textInputAction;

  const InputField({
    super.key,
    this.placeholder,
    this.label,
    this.icon,
    this.suffixIcon,
    this.keyboardType,
    this.onChanged,
    this.onEditingComplete,
    this.controller,
    this.mode = InputFieldMode.text,
    this.useThousandSeparators = false,
    this.obscureText = false,
    this.enabled = true,
    this.maxLength,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.borderRadius = 14.0,
    this.maxLines = 1,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == InputFieldMode.otp) {
      return _buildOtpField();
    }
    return _buildStandardField();
  }

  Widget _buildStandardField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: kBodyStyle.copyWith(
              fontWeight: FontWeight.w500,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          obscureText: obscureText,
          textAlign: textAlign,
          maxLines: maxLines,
          textInputAction: textInputAction,
          keyboardType: _getKeyboardType(),
          inputFormatters: _getInputFormatters(),
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          style: kBodyStyle.copyWith(fontSize: 16, color: kTextPrimary),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: kBodyStyle.copyWith(fontSize: 16, color: kTextSecondary),
            prefixIcon: icon != null
                ? Icon(icon, color: kTextSecondary, size: 20)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: kCardBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: kTextSecondary, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: kTextSecondary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: kPrimary, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: kTextSecondary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpField() {
    return SizedBox(
      width: 56,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: onChanged,
        style: kTitleStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: kCardBg,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: kTextSecondary, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: kTextSecondary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: kPrimary, width: 2),
          ),
        ),
      ),
    );
  }

  TextInputType _getKeyboardType() {
    if (keyboardType != null) return keyboardType!;
    switch (mode) {
      case InputFieldMode.numeric:
      case InputFieldMode.otp:
        return TextInputType.number;
      case InputFieldMode.text:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    final formatters = <TextInputFormatter>[];

    if (mode == InputFieldMode.numeric) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
      if (useThousandSeparators) {
        formatters.add(_ThousandSeparatorFormatter());
      }
    }

    if (maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(maxLength));
    }

    return formatters;
  }
}

/// Formatter that adds thousand separators to numeric input.
class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove existing separators
    final cleanText = newValue.text.replaceAll(',', '');

    // Parse and format
    final number = int.tryParse(cleanText);
    if (number == null) {
      return oldValue;
    }

    // Format with thousand separators
    final formatted = _formatWithSeparators(number);

    // Calculate new cursor position
    final oldCursorPos = newValue.selection.end;
    final oldCommaCount =
        newValue.text.substring(0, oldCursorPos).split(',').length - 1;
    final newCommaCount =
        formatted
            .substring(0, formatted.length.clamp(0, oldCursorPos + 1))
            .split(',')
            .length -
        1;
    final newCursorPos = oldCursorPos + (newCommaCount - oldCommaCount);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: newCursorPos.clamp(0, formatted.length),
      ),
    );
  }

  String _formatWithSeparators(int number) {
    final text = number.toString();
    final buffer = StringBuffer();
    final len = text.length;

    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(text[i]);
    }

    return buffer.toString();
  }
}
