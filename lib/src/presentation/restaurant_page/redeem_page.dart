import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/transactions_repository.dart';
import '../../theme/app_theme.dart';
import '../common/primary_button.dart';
import '../common/rounded_card.dart';

/// Result state for redemption.
enum RedeemResult { success, expired, invalid, cashierMismatch }

/// Redeem Discount page for applying restaurant discounts.
class RedeemPage extends StatefulWidget {
  /// Restaurant ID
  final String restaurantId;

  /// Restaurant name.
  final String restaurantName;

  /// Restaurant logo URL.
  final String? logoUrl;

  /// Discount percentage.
  final int discountPercent;

  const RedeemPage({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    this.logoUrl,
    this.discountPercent = 10,
  });

  @override
  State<RedeemPage> createState() => _RedeemPageState();
}

class _RedeemPageState extends State<RedeemPage> {
  final _transactionsRepository = TransactionsRepository();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _cashierCodeController = TextEditingController();

  bool _isLoading = false;
  RedeemResult? _result;
  double? _originalAmount;
  double? _discountAmount;
  double? _finalAmount;

  @override
  void dispose() {
    _amountController.dispose();
    _cashierCodeController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the bill amount';
    }
    final cleanValue = value.replaceAll(',', '').replaceAll(' ', '');
    final amount = double.tryParse(cleanValue);
    if (amount == null || amount <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  String? _validateCashierCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the cashier code';
    }
    if (value.length != 4) {
      return 'Code must be 4 digits';
    }
    if (!RegExp(r'^\d{4}$').hasMatch(value)) {
      return 'Code must contain only digits';
    }
    return null;
  }

  Future<void> _handleRedeem() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final cleanAmount = _amountController.text
          .replaceAll(',', '')
          .replaceAll(' ', '');
      _originalAmount = double.parse(cleanAmount);

      final result = await _transactionsRepository.createTransaction(
        restaurantId: widget.restaurantId,
        sumBeforeDiscount: _originalAmount!,
        cashierCode: _cashierCodeController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (result.success) {
          _result = RedeemResult.success;
          _finalAmount = result.sumAfterDiscount;
          _discountAmount =
              result.savedAmount ?? (_originalAmount! - (_finalAmount ?? 0));
        } else {
          _mapErrorToResult(result.errorCode);
          if (_result == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.error ?? 'Transaction failed'),
                backgroundColor: kError,
              ),
            );
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: kError,
        ),
      );
    }
  }

  void _mapErrorToResult(String? errorCode) {
    switch (errorCode) {
      case 'expired_code':
        _result = RedeemResult.expired;
        break;
      case 'invalid_code':
        _result = RedeemResult.invalid;
        break;
      case 'cashier_mismatch':
        _result = RedeemResult.cashierMismatch;
        break;
      default:
        _result = null;
    }
  }

  void _tryAgain() {
    setState(() {
      _result = null;
      _isLoading = false;
    });
  }

  void _reportIssue() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Report submitted (simulation)'),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text('Redeem Discount', style: kTitleStyle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _result != null ? _buildResultView() : _buildFormView(),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Restaurant header
            _buildRestaurantHeader(),
            const SizedBox(height: 32),
            // Amount input
            _buildLabel('Amount (UZS)'),
            const SizedBox(height: 8),
            _buildAmountField(),
            const SizedBox(height: 24),
            // Cashier code input
            _buildLabel('Cashier Code'),
            const SizedBox(height: 8),
            _buildCashierCodeField(),
            const SizedBox(height: 16),
            // Help text
            Text(
              'Ask your cashier for the 4-digit verification code',
              style: kBodyStyle.copyWith(color: kTextSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Preview
            _buildDiscountPreview(),
            const SizedBox(height: 32),
            // Redeem button
            PrimaryButton(
              label: 'Redeem Discount',
              onPressed: _handleRedeem,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            // Demo hint
            RoundedCard(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Demo: Use code 0000 for expired, 1111 for invalid, 2222 for cashier mismatch, any other for success.',
                style: kBodyStyle.copyWith(
                  fontSize: 12,
                  color: kTextSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantHeader() {
    return RoundedCard(
      child: Row(
        children: [
          // Logo
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kBackground,
              border: Border.all(color: kTextSecondary.withValues(alpha: 0.2)),
            ),
            child: ClipOval(
              child: widget.logoUrl != null
                  ? Image.network(
                      widget.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.restaurant, color: kTextSecondary),
                    )
                  : const Icon(Icons.restaurant, color: kTextSecondary),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.restaurantName,
                  style: kSubtitleStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kSecondaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.discountPercent}% off',
                    style: const TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      validator: _validateAmount,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _ThousandSeparatorFormatter(),
      ],
      style: kBodyStyle.copyWith(fontSize: 18, color: kTextPrimary),
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: kBodyStyle.copyWith(fontSize: 18, color: kTextSecondary),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 16, right: 8),
          child: Text(
            'UZS',
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: kCardBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
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
          borderSide: const BorderSide(color: kError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kError, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildCashierCodeField() {
    return TextFormField(
      controller: _cashierCodeController,
      validator: _validateCashierCode,
      keyboardType: TextInputType.number,
      maxLength: 4,
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      style: kTitleStyle.copyWith(fontSize: 28, letterSpacing: 16),
      decoration: InputDecoration(
        counterText: '',
        hintText: '____',
        hintStyle: kTitleStyle.copyWith(
          fontSize: 28,
          letterSpacing: 16,
          color: kTextSecondary.withValues(alpha: 0.3),
        ),
        filled: true,
        fillColor: kCardBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
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
          borderSide: const BorderSide(color: kError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kError, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDiscountPreview() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _amountController,
      builder: (context, value, child) {
        final amountText = value.text;
        final cleanAmount = amountText.replaceAll(',', '').replaceAll(' ', '');
        final amount = double.tryParse(cleanAmount) ?? 0;
        final discount = amount * widget.discountPercent / 100;
        final final_ = amount - discount;

        if (amount <= 0) return const SizedBox.shrink();

        return RoundedCard(
          child: Column(
            children: [
              _buildPreviewRow('Bill Amount', 'UZS ${_formatNumber(amount)}'),
              const SizedBox(height: 8),
              _buildPreviewRow(
                'Discount (${widget.discountPercent}%)',
                '-UZS ${_formatNumber(discount)}',
                isDiscount: true,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              _buildPreviewRow(
                'Final Amount',
                'UZS ${_formatNumber(final_)}',
                isFinal: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isFinal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: kBodyStyle.copyWith(
            color: kTextSecondary,
            fontWeight: isFinal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: kBodyStyle.copyWith(
            color: isDiscount
                ? kSuccess
                : isFinal
                ? kTextPrimary
                : kTextSecondary,
            fontWeight: isFinal ? FontWeight.bold : FontWeight.w500,
            fontSize: isFinal ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _result == RedeemResult.success
          ? _buildSuccessView()
          : _buildErrorView(),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Success icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: kSuccess.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, size: 64, color: kSuccess),
        ),
        const SizedBox(height: 24),
        Text('Discount Applied!', style: kTitleStyle.copyWith(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          'Your discount has been successfully applied',
          style: kBodyStyle.copyWith(color: kTextSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        // Summary card
        RoundedCard(
          child: Column(
            children: [
              _buildSummaryRow(
                'Original Amount',
                'UZS ${_formatNumber(_originalAmount ?? 0)}',
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                'Discount (${widget.discountPercent}%)',
                '-UZS ${_formatNumber(_discountAmount ?? 0)}',
                isDiscount: true,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              _buildSummaryRow(
                'Final Amount',
                'UZS ${_formatNumber(_finalAmount ?? 0)}',
                isFinal: true,
              ),
              const SizedBox(height: 16),
              // Saved amount
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'You Saved',
                      style: kBodyStyle.copyWith(color: Colors.green),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'UZS ${_formatNumber(_discountAmount ?? 0)}',
                      style: kTitleStyle.copyWith(
                        color: Colors.green,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Back to home button
        PrimaryButton(
          label: 'Back to Home',
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isFinal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: kBodyStyle.copyWith(
            color: kTextSecondary,
            fontSize: isFinal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            color: isDiscount
                ? kSuccess
                : isFinal
                ? kTextPrimary
                : kTextSecondary,
            fontWeight: isFinal ? FontWeight.bold : FontWeight.w500,
            fontSize: isFinal ? 20 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    final errorData = _getErrorData();

    return Column(
      children: [
        const SizedBox(height: 40),
        // Error icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: kError.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline, size: 64, color: kError),
        ),
        const SizedBox(height: 24),
        Text(
          errorData['title']!,
          style: kTitleStyle.copyWith(fontSize: 24, color: kError),
        ),
        const SizedBox(height: 32),
        // Error card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kError.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(kCardRadius),
            border: Border.all(color: kError.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(
                _getErrorIcon(),
                size: 48,
                color: kError.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                errorData['message']!,
                style: kBodyStyle.copyWith(color: kTextPrimary, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Try again button
        PrimaryButton(label: 'Try Again', onPressed: _tryAgain),
        const SizedBox(height: 16),
        // Report issue link
        GestureDetector(
          onTap: _reportIssue,
          child: Text(
            'Report Issue',
            style: kSubtitleStyle.copyWith(
              color: kPrimary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Map<String, String> _getErrorData() {
    switch (_result) {
      case RedeemResult.expired:
        return {
          'title': 'Expired Code',
          'message':
              'The code has expired. Ask the cashier to generate a new one.',
        };
      case RedeemResult.invalid:
        return {
          'title': 'Invalid Code',
          'message': 'The code is invalid. Check the digits and try again.',
        };
      case RedeemResult.cashierMismatch:
        return {
          'title': 'Cashier Mismatch',
          'message':
              'This code was issued for a different cashier. Please ask the cashier for the correct code.',
        };
      default:
        return {'title': 'Error', 'message': 'An unknown error occurred.'};
    }
  }

  IconData _getErrorIcon() {
    switch (_result) {
      case RedeemResult.expired:
        return Icons.timer_off_outlined;
      case RedeemResult.invalid:
        return Icons.cancel_outlined;
      case RedeemResult.cashierMismatch:
        return Icons.person_off_outlined;
      default:
        return Icons.error_outline;
    }
  }

  String _formatNumber(double number) {
    final intValue = number.round();
    final text = intValue.toString();
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

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
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
