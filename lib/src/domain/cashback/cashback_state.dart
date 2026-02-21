import 'package:equatable/equatable.dart';

/// Immutable state for the cashback wallet.
class CashbackState extends Equatable {
  /// Current cashback balance in UZS.
  final double balance;

  /// Whether a wallet operation is in progress.
  final bool isLoading;

  /// Error message from the last failed operation, if any.
  final String? errorMessage;

  /// The amount added in the most recent addCashback call.
  final double lastAddedAmount;

  const CashbackState({
    this.balance = 0,
    this.isLoading = false,
    this.errorMessage,
    this.lastAddedAmount = 0,
  });

  CashbackState copyWith({
    double? balance,
    bool? isLoading,
    String? errorMessage,
    double? lastAddedAmount,
  }) {
    return CashbackState(
      balance: balance ?? this.balance,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastAddedAmount: lastAddedAmount ?? this.lastAddedAmount,
    );
  }

  @override
  List<Object?> get props => [
    balance,
    isLoading,
    errorMessage,
    lastAddedAmount,
  ];
}
