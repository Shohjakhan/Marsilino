/// Wallet information from `GET /v1/wallet`.
class WalletInfo {
  final String userId;
  final double balance;
  final String currency;
  final double totalEarned;
  final double totalTransferred;
  final DateTime? lastUpdated;

  const WalletInfo({
    required this.userId,
    required this.balance,
    this.currency = 'UZS',
    this.totalEarned = 0,
    this.totalTransferred = 0,
    this.lastUpdated,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      userId: json['user_id']?.toString() ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'UZS',
      totalEarned: (json['total_earned'] as num?)?.toDouble() ?? 0,
      totalTransferred: (json['total_transferred'] as num?)?.toDouble() ?? 0,
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'] as String)
          : null,
    );
  }
}

/// Result of `POST /v1/wallet/add` (cashback add).
class CashbackAddResult {
  final String transactionId;
  final double newBalance;
  final double cashbackAmount;
  final String receiptId;

  const CashbackAddResult({
    required this.transactionId,
    required this.newBalance,
    required this.cashbackAmount,
    required this.receiptId,
  });

  factory CashbackAddResult.fromJson(Map<String, dynamic> json) {
    return CashbackAddResult(
      transactionId: json['transaction_id'] as String? ?? '',
      newBalance: (json['new_balance'] as num?)?.toDouble() ?? 0,
      cashbackAmount: (json['cashback_amount'] as num?)?.toDouble() ?? 0,
      receiptId: json['receipt_id'] as String? ?? '',
    );
  }
}

/// Result of `POST /v1/wallet/transfer`.
class TransferResult {
  final String transactionId;
  final double transferredAmount;
  final double newBalance;
  final String cardLastFour;
  final DateTime? estimatedArrival;

  const TransferResult({
    required this.transactionId,
    required this.transferredAmount,
    required this.newBalance,
    required this.cardLastFour,
    this.estimatedArrival,
  });

  factory TransferResult.fromJson(Map<String, dynamic> json) {
    return TransferResult(
      transactionId: json['transaction_id'] as String? ?? '',
      transferredAmount: (json['transferred_amount'] as num?)?.toDouble() ?? 0,
      newBalance: (json['new_balance'] as num?)?.toDouble() ?? 0,
      cardLastFour: json['card_last_four'] as String? ?? '',
      estimatedArrival: json['estimated_arrival'] != null
          ? DateTime.tryParse(json['estimated_arrival'] as String)
          : null,
    );
  }
}
