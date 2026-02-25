import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/wallet_repository.dart';
import 'cashback_state.dart';

/// Cubit managing the cashback wallet balance and operations.
class CashbackCubit extends Cubit<CashbackState> {
  final WalletRepository _walletRepository;

  CashbackCubit({WalletRepository? walletRepository})
    : _walletRepository = walletRepository ?? WalletRepository(),
      super(const CashbackState());

  /// Safe emit that checks if the cubit is still open.
  void _safeEmit(CashbackState newState) {
    if (!isClosed) emit(newState);
  }

  /// Load the current cashback balance from the backend.
  Future<void> loadBalance() async {
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final result = await _walletRepository.getWallet();
      if (isClosed) return;

      if (result.success && result.data != null) {
        final wallet = result.data!;
        _safeEmit(
          state.copyWith(
            balance: wallet.balance,
            currency: wallet.currency,
            totalEarned: wallet.totalEarned,
            totalTransferred: wallet.totalTransferred,
            isLoading: false,
          ),
        );
      } else {
        _safeEmit(
          state.copyWith(
            isLoading: false,
            errorMessage: result.error ?? 'Failed to load balance',
          ),
        );
      }
    } catch (e) {
      _safeEmit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load balance: $e',
        ),
      );
    }
  }

  /// Add cashback to the wallet balance (local update after successful API call).
  void addCashback(double amount) {
    final newBalance = state.balance + amount;
    _safeEmit(
      state.copyWith(
        balance: newBalance,
        lastAddedAmount: amount,
        errorMessage: null,
      ),
    );
  }

  /// Update balance from a new wallet balance value (e.g., after receipt verify).
  void updateBalance(double newBalance) {
    _safeEmit(state.copyWith(balance: newBalance, errorMessage: null));
  }

  /// Transfer the entire wallet balance to the user's card.
  Future<void> transferToCard({String cardLastFour = '0000'}) async {
    if (state.balance <= 0) {
      _safeEmit(state.copyWith(errorMessage: 'No balance to transfer'));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final result = await _walletRepository.transferToCard(
        amount: state.balance,
        cardLastFour: cardLastFour,
      );
      if (isClosed) return;

      if (result.success && result.data != null) {
        _safeEmit(
          state.copyWith(
            balance: result.data!.newBalance,
            isLoading: false,
            lastAddedAmount: 0,
          ),
        );
      } else {
        _safeEmit(
          state.copyWith(
            isLoading: false,
            errorMessage: result.error ?? 'Transfer failed',
          ),
        );
      }
    } catch (e) {
      _safeEmit(
        state.copyWith(isLoading: false, errorMessage: 'Transfer failed: $e'),
      );
    }
  }
}
