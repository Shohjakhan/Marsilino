import '../../src/data/repositories/transactions_repository.dart';

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
