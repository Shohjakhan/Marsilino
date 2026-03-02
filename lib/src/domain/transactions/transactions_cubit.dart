import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/wallet_transaction_model.dart';
import '../../data/repositories/wallet_repository.dart';
import 'transactions_state.dart';

export 'transactions_state.dart';

/// Cubit for managing wallet transaction history.
class TransactionsCubit extends Cubit<TransactionsState> {
  final WalletRepository _walletRepository;
  static const _networkTimeout = Duration(seconds: 8);

  // In-memory cache
  List<WalletTransaction> _cachedTransactions = [];

  TransactionsCubit({WalletRepository? walletRepository})
    : _walletRepository = walletRepository ?? WalletRepository(),
      super(const TransactionsInitial());

  /// Load transactions (shows cache while loading if available).
  Future<void> loadTransactions() async {
    // Show cached data while loading if available
    if (_cachedTransactions.isNotEmpty) {
      emit(
        TransactionsLoading(
          cachedTransactions: _cachedTransactions,
          isRefreshing: true,
        ),
      );
    } else {
      emit(const TransactionsLoading());
    }

    await _fetchTransactions();
  }

  /// Force refresh transactions.
  Future<void> refreshTransactions() async {
    emit(
      TransactionsLoading(
        cachedTransactions: _cachedTransactions,
        isRefreshing: true,
      ),
    );

    await _fetchTransactions();
  }

  /// Internal fetch logic — calls GET /v1/wallet/transactions.
  Future<void> _fetchTransactions() async {
    try {
      final result = await _walletRepository.getTransactions().timeout(
        _networkTimeout,
        onTimeout: () {
          throw TimeoutException('Network request timed out');
        },
      );

      if (result.success && result.data != null) {
        _cachedTransactions = result.data!.transactions;
        // Sort by date descending (newest first)
        _cachedTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        emit(TransactionsLoaded(transactions: _cachedTransactions));
      } else {
        emit(
          TransactionsError(
            message: result.error ?? 'Failed to load transactions',
            cachedTransactions: _cachedTransactions,
          ),
        );
      }
    } on TimeoutException {
      emit(
        TransactionsError(
          message: 'Connection timed out. Please check your internet.',
          cachedTransactions: _cachedTransactions,
        ),
      );
    } catch (e) {
      emit(
        TransactionsError(
          message: 'Failed to load transactions: ${e.toString()}',
          cachedTransactions: _cachedTransactions,
        ),
      );
    }
  }

  /// Get cached transactions.
  List<WalletTransaction> get cachedTransactions =>
      List.unmodifiable(_cachedTransactions);

  /// Check if there are any transactions.
  bool get hasTransactions => _cachedTransactions.isNotEmpty;
}
