import 'package:equatable/equatable.dart';

/// Immutable state for the cashback wallet.
class CashbackState extends Equatable {
  /// Current cashback balance in UZS.
  final double balance;

  /// Currency code (e.g., 'UZS').
  final String currency;

  /// Total cashback ever earned.
  final double totalEarned;

  /// Total amount ever transferred out.
  final double totalTransferred;

  /// Whether a wallet operation is in progress.
  final bool isLoading;

  /// Error message from the last failed operation, if any.
  final String? errorMessage;

  /// The amount added in the most recent addCashback call.
  final double lastAddedAmount;

  const CashbackState({
    this.balance = 0,
    this.currency = 'UZS',
    this.totalEarned = 0,
    this.totalTransferred = 0,
    this.isLoading = false,
    this.errorMessage,
    this.lastAddedAmount = 0,
  });

  CashbackState copyWith({
    double? balance,
    String? currency,
    double? totalEarned,
    double? totalTransferred,
    bool? isLoading,
    String? errorMessage,
    double? lastAddedAmount,
  }) {
    return CashbackState(
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      totalEarned: totalEarned ?? this.totalEarned,
      totalTransferred: totalTransferred ?? this.totalTransferred,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastAddedAmount: lastAddedAmount ?? this.lastAddedAmount,
    );
  }

  @override
  List<Object?> get props => [
    balance,
    currency,
    totalEarned,
    totalTransferred,
    isLoading,
    errorMessage,
    lastAddedAmount,
  ];
}
