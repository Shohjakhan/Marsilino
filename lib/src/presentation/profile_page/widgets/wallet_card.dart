import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/l10n/gen/app_localizations.dart';
import '../../../domain/cashback/cashback_cubit.dart';
import '../../../domain/cashback/cashback_state.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../theme/app_theme.dart';

/// Cashback wallet card with balance display and transfer-to-card functionality.
class WalletCard extends StatelessWidget {
  final CashbackCubit cashbackCubit;
  final String userName;
  final UserRepository userRepository;
  final Future<UserModel> userFuture;

  const WalletCard({
    super.key,
    required this.cashbackCubit,
    required this.userName,
    required this.userRepository,
    required this.userFuture,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cashbackCubit,
      child: BlocBuilder<CashbackCubit, CashbackState>(
        bloc: cashbackCubit,
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return Column(
            children: [
              // Wallet card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimaryBold, kPrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(kCardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryBold.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.cashbackWallet(
                            userName.isNotEmpty ? userName : 'You',
                          ),
                          style: kSubtitleStyle.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.balance,
                      style: kBodyStyle.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'UZS ${_formatBalance(state.balance)}',
                      style: kTitleStyle.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (state.lastAddedAmount > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.recentCashback(
                            _formatBalance(state.lastAddedAmount),
                          ),
                          style: kBodyStyle.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Transfer button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading || state.balance <= 0
                      ? null
                      : () => _showTransferDialog(context, l10n),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBold,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: kTextSecondary.withValues(
                      alpha: 0.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kButtonRadius),
                    ),
                    elevation: 0,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          l10n.transferToCard,
                          style: kSubtitleStyle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  style: kBodyStyle.copyWith(color: kError, fontSize: 13),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _formatBalance(double number) {
    final intValue = number.round();
    final text = intValue.toString();
    final buffer = StringBuffer();
    final len = text.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buffer.write(',');
      buffer.write(text[i]);
    }
    return buffer.toString();
  }

  void _showTransferDialog(BuildContext context, AppLocalizations l10n) {
    final TextEditingController cardController = TextEditingController();
    bool isLoading = false;
    String? errorText;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: kCardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kCardRadius),
            ),
            title: Text(l10n.transferToCard, style: kTitleStyle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.enterCardNumber,
                  style: kBodyStyle.copyWith(color: kTextSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cardController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                  ],
                  decoration: InputDecoration(
                    hintText: '0000 0000 0000 0000',
                    errorText: errorText,
                    prefixIcon: const Icon(Icons.credit_card, color: kPrimary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kButtonRadius),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: kBodyStyle.copyWith(color: kTextSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final card = cardController.text.trim();
                        if (card.length != 16) {
                          setStateDialog(() {
                            errorText = l10n.cardNumberLengthError;
                          });
                          return;
                        }

                        setStateDialog(() {
                          isLoading = true;
                          errorText = null;
                        });

                        try {
                          final user = await userFuture;
                          final phone = user.phoneNumber;

                          if (phone.isEmpty) {
                            throw Exception("Missing phone number");
                          }

                          await userRepository.addCard(
                            phoneNumber: phone,
                            cardNumber: card,
                          );

                          final lastFour = card.substring(12);
                          final initialBalance = cashbackCubit.state.balance;

                          await cashbackCubit.transferToCard(
                            cardLastFour: lastFour,
                          );

                          if (context.mounted) {
                            final state = cashbackCubit.state;

                            if (state.errorMessage == null &&
                                state.balance < initialBalance) {
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.transferSuccess),
                                  backgroundColor: kSuccess,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            } else {
                              setStateDialog(() {
                                errorText =
                                    state.errorMessage ?? l10n.transferFailed;
                                isLoading = false;
                              });
                            }
                          }
                        } catch (e) {
                          setStateDialog(() {
                            String errTxt = e.toString();
                            if (errTxt.startsWith('Exception: ')) {
                              errTxt = errTxt.substring('Exception: '.length);
                            }
                            errorText = errTxt;
                            isLoading = false;
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kButtonRadius),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        l10n.transferToCard,
                        style: kSubtitleStyle.copyWith(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
