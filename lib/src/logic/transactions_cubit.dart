import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/transactions_repository.dart';

/// Transactions state.
sealed class TransactionsState {}

/// Initial state - no transactions loaded.
class TransactionsInitial extends TransactionsState {}

/// Loading transactions.
class TransactionsLoading extends TransactionsState {
  final List<Transaction> cachedTransactions;
  final bool isRefreshing;

  TransactionsLoading({
    this.cachedTransactions = const [],
    this.isRefreshing = false,
  });
}

/// Transactions loaded successfully.
class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;

  TransactionsLoaded({required this.transactions});
}

/// Error loading transactions.
class TransactionsError extends TransactionsState {
  final String message;
  final List<Transaction> cachedTransactions;

  TransactionsError({
    required this.message,
    this.cachedTransactions = const [],
  });
}

/// Cubit for managing transaction history.
class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionsRepository _repository;
  static const _networkTimeout = Duration(seconds: 8);

  // In-memory cache
  List<Transaction> _cachedTransactions = [];

  TransactionsCubit({TransactionsRepository? repository})
    : _repository = repository ?? TransactionsRepository(),
      super(TransactionsInitial());

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
      emit(TransactionsLoading());
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

  /// Internal fetch logic.
  Future<void> _fetchTransactions() async {
    try {
      final result = await _repository.getTransactions().timeout(
        _networkTimeout,
        onTimeout: () {
          print('[TransactionsCubit] Network timeout after $_networkTimeout');
          throw TimeoutException('Network request timed out');
        },
      );

      if (result.success) {
        _cachedTransactions = result.transactions;
        // Sort by date descending (newest first)
        _cachedTransactions.sort((a, b) => b.date.compareTo(a.date));
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
      print('[TransactionsCubit] loadTransactions error: $e');
      emit(
        TransactionsError(
          message: 'Failed to load transactions: ${e.toString()}',
          cachedTransactions: _cachedTransactions,
        ),
      );
    }
  }

  /// Get cached transactions.
  List<Transaction> get cachedTransactions =>
      List.unmodifiable(_cachedTransactions);

  /// Check if there are any transactions.
  bool get hasTransactions => _cachedTransactions.isNotEmpty;
}
