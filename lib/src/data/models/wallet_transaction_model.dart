/// A single wallet transaction from `GET /v1/wallet/transactions`.
class WalletTransaction {
  final String id;
  final String type; // 'cashback_add' or 'transfer_out'
  final double amount;
  final double balanceAfter;
  final String? description;
  final String? restaurantName;
  final String? receiptId;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.balanceAfter = 0,
    this.description,
    this.restaurantName,
    this.receiptId,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      balanceAfter: (json['balance_after'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      restaurantName: json['restaurant_name'] as String?,
      receiptId: json['receipt_id'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Whether this is a cashback earning transaction.
  bool get isCashback => type == 'cashback_add';

  /// Whether this is a transfer/withdrawal transaction.
  bool get isTransfer => type == 'transfer_out';
}

/// Paginated result for wallet transactions.
class TransactionsPage {
  final List<WalletTransaction> transactions;
  final int total;
  final int page;
  final int pages;

  const TransactionsPage({
    required this.transactions,
    this.total = 0,
    this.page = 1,
    this.pages = 1,
  });

  factory TransactionsPage.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List? ?? [];
    return TransactionsPage(
      transactions: dataList
          .whereType<Map<String, dynamic>>()
          .map((t) => WalletTransaction.fromJson(t))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pages: json['pages'] as int? ?? 1,
    );
  }
}
