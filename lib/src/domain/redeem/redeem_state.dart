/// Failure reason for redeem operation.
enum RedeemFailureReason { expired, invalid, cashierMismatch, generic, timeout }

/// Redeem state.
sealed class RedeemState {}

/// Initial state - ready for input.
class RedeemInitial extends RedeemState {}

/// Loading state - submitting transaction.
class RedeemLoading extends RedeemState {}

/// Transaction succeeded.
class RedeemSuccess extends RedeemState {
  final double cashbackPercent;
  final double amountPaid;
  final double savedAmount;
  final double originalAmount;

  RedeemSuccess({
    required this.cashbackPercent,
    required this.amountPaid,
    required this.savedAmount,
    required this.originalAmount,
  });
}

/// Transaction failed with specific reason.
class RedeemFailure extends RedeemState {
  final RedeemFailureReason reason;
  final String message;

  RedeemFailure({required this.reason, required this.message});
}
