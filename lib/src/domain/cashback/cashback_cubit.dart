import 'package:flutter_bloc/flutter_bloc.dart';
import 'cashback_state.dart';

/// Cubit managing the cashback wallet balance and operations.
class CashbackCubit extends Cubit<CashbackState> {
  CashbackCubit() : super(const CashbackState());

  /// Load the current cashback balance from the backend.
  Future<void> loadBalance() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // TODO: Replace with real API call
      await Future.delayed(const Duration(milliseconds: 500));
      final mockBalance = state.balance; // Persist current balance for now

      emit(state.copyWith(balance: mockBalance, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load balance: $e',
        ),
      );
    }
  }

  /// Add cashback to the wallet balance.
  void addCashback(double amount) {
    final newBalance = state.balance + amount;
    emit(
      state.copyWith(
        balance: newBalance,
        lastAddedAmount: amount,
        errorMessage: null,
      ),
    );
  }

  /// Transfer the entire wallet balance to the user's card.
  Future<void> transferToCard() async {
    if (state.balance <= 0) {
      emit(state.copyWith(errorMessage: 'No balance to transfer'));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // TODO: Replace with real API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock: simulate success
      emit(state.copyWith(balance: 0, isLoading: false, lastAddedAmount: 0));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'Transfer failed: $e'),
      );
    }
  }
}
