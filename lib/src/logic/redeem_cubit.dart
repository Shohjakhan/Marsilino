import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/transactions_repository.dart';

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
  final double discountPercent;
  final double sumAfterDiscount;
  final double savedAmount;
  final double originalAmount;

  RedeemSuccess({
    required this.discountPercent,
    required this.sumAfterDiscount,
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

/// Cubit for managing redeem/transaction creation.
class RedeemCubit extends Cubit<RedeemState> {
  final TransactionsRepository _repository;
  static const _networkTimeout = Duration(seconds: 10);

  RedeemCubit({TransactionsRepository? repository})
    : _repository = repository ?? TransactionsRepository(),
      super(RedeemInitial());

  /// Submit a redeem transaction.
  Future<void> submitRedeem({
    required String restaurantId,
    required double amount,
    required String cashierCode,
  }) async {
    // Validate input
    if (amount <= 0) {
      emit(
        RedeemFailure(
          reason: RedeemFailureReason.generic,
          message: 'Please enter a valid amount greater than 0',
        ),
      );
      return;
    }

    if (cashierCode.isEmpty) {
      emit(
        RedeemFailure(
          reason: RedeemFailureReason.generic,
          message: 'Please enter the cashier code',
        ),
      );
      return;
    }

    emit(RedeemLoading());

    try {
      final result = await _repository
          .createTransaction(
            restaurantId: restaurantId,
            sumBeforeDiscount: amount,
            cashierCode: cashierCode,
          )
          .timeout(
            _networkTimeout,
            onTimeout: () {
              throw TimeoutException('Request timed out');
            },
          );

      if (result.success) {
        emit(
          RedeemSuccess(
            discountPercent: result.discountPercent ?? 0,
            sumAfterDiscount: result.sumAfterDiscount ?? amount,
            savedAmount: result.savedAmount ?? 0,
            originalAmount: amount,
          ),
        );
      } else {
        _emitFailure(result.errorCode, result.error);
      }
    } on TimeoutException {
      print('[RedeemCubit] Request timed out after $_networkTimeout');
      emit(
        RedeemFailure(
          reason: RedeemFailureReason.timeout,
          message:
              'Request timed out. Please check your connection and try again.',
        ),
      );
    } catch (e) {
      print('[RedeemCubit] submitRedeem error: $e');
      emit(
        RedeemFailure(
          reason: RedeemFailureReason.generic,
          message: 'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }

  /// Map error code to failure reason and emit.
  void _emitFailure(String? errorCode, String? errorMessage) {
    final reason = _mapErrorCode(errorCode);
    final message = _getMessageForReason(reason, errorMessage);

    emit(RedeemFailure(reason: reason, message: message));
  }

  /// Map API error_code to RedeemFailureReason.
  RedeemFailureReason _mapErrorCode(String? errorCode) {
    if (errorCode == null) return RedeemFailureReason.generic;

    switch (errorCode.toLowerCase()) {
      case 'code_expired':
      case 'expired_code':
        return RedeemFailureReason.expired;
      case 'invalid_code':
        return RedeemFailureReason.invalid;
      case 'cashier_mismatch':
        return RedeemFailureReason.cashierMismatch;
      default:
        return RedeemFailureReason.generic;
    }
  }

  /// Get user-friendly message for each failure reason.
  String _getMessageForReason(
    RedeemFailureReason reason,
    String? serverMessage,
  ) {
    switch (reason) {
      case RedeemFailureReason.expired:
        return 'This code has expired. Please ask for a new code from the cashier.';
      case RedeemFailureReason.invalid:
        return 'Invalid code. Please check the code and try again.';
      case RedeemFailureReason.cashierMismatch:
        return 'This code does not match this restaurant. Please verify you\'re at the right location.';
      case RedeemFailureReason.timeout:
        return 'Request timed out. Please check your connection and try again.';
      case RedeemFailureReason.generic:
        return serverMessage ??
            'Transaction failed. Please try again or contact support.';
    }
  }

  /// Reset to initial state for another transaction.
  void reset() {
    emit(RedeemInitial());
  }
}
