import 'package:equatable/equatable.dart';
import '../../data/models/wallet_transaction_model.dart';

/// Transactions state.
sealed class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no transactions loaded.
class TransactionsInitial extends TransactionsState {
  const TransactionsInitial();
}

/// Loading transactions.
class TransactionsLoading extends TransactionsState {
  final List<WalletTransaction> cachedTransactions;
  final bool isRefreshing;

  const TransactionsLoading({
    this.cachedTransactions = const [],
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [cachedTransactions, isRefreshing];
}

/// Transactions loaded successfully.
class TransactionsLoaded extends TransactionsState {
  final List<WalletTransaction> transactions;

  const TransactionsLoaded({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}

/// Error loading transactions.
class TransactionsError extends TransactionsState {
  final String message;
  final List<WalletTransaction> cachedTransactions;

  const TransactionsError({
    required this.message,
    this.cachedTransactions = const [],
  });

  @override
  List<Object?> get props => [message, cachedTransactions];
}
