import 'package:equatable/equatable.dart';

/// Model representing a fiscal receipt from the Soliq (tax) system.
///
/// ## Expected QR Code Format
/// The QR code scanned from a Soliq receipt typically contains a URL
/// pointing to the Soliq fiscal server, e.g.:
/// ```
/// https://ofd.soliq.uz/check?t=UZ123456789&r=1&c=20250221120000&s=150000.00
/// ```
/// Parameters:
/// - `t` — Taxpayer TIN (INN)
/// - `r` — Receipt/register number
/// - `c` — Timestamp (yyyyMMddHHmmss)
/// - `s` — Total sum
///
/// ## Expected Soliq API Response
/// ```json
/// {
///   "success": true,
///   "data": {
///     "receipt_number": "0001-0042",
///     "total_amount": 150000.0,
///     "restaurant_name": "Premium Restaurant",
///     "created_at": "2025-02-21T12:00:00Z",
///     "tin": "123456789",
///     "items": [...]
///   }
/// }
/// ```
class ReceiptModel extends Equatable {
  /// Unique receipt ID from the backend.
  final String? receiptId;

  /// Unique receipt number from the fiscal system.
  final String receiptNumber;

  /// Total amount on the receipt in UZS.
  final double totalAmount;

  /// Name of the establishment that issued the receipt.
  final String restaurantName;

  /// Timestamp when the receipt was created.
  final DateTime createdAt;

  /// Taxpayer Identification Number.
  final String? tin;

  /// Whether this receipt has already been redeemed for cashback.
  final bool alreadyRedeemed;

  /// Total amount paid (from verify response).
  final double? totalPaid;

  /// Cashback earned from this receipt.
  final double? cashbackEarned;

  /// User's new wallet balance after cashback.
  final double? newWalletBalance;

  const ReceiptModel({
    this.receiptId,
    required this.receiptNumber,
    required this.totalAmount,
    required this.restaurantName,
    required this.createdAt,
    this.tin,
    this.alreadyRedeemed = false,
    this.totalPaid,
    this.cashbackEarned,
    this.newWalletBalance,
  });

  /// Parse from backend API JSON response (`POST /v1/receipt/verify`).
  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      receiptId: json['receipt_id'] as String?,
      receiptNumber: json['receipt_number'] as String? ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      restaurantName: json['restaurant_name'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      tin: json['tin'] as String?,
      alreadyRedeemed: json['already_redeemed'] as bool? ?? false,
      totalPaid: (json['total_paid'] as num?)?.toDouble(),
      cashbackEarned: (json['cashback_earned'] as num?)?.toDouble(),
      newWalletBalance: (json['new_wallet_balance'] as num?)?.toDouble(),
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (receiptId != null) 'receipt_id': receiptId,
      'receipt_number': receiptNumber,
      'total_amount': totalAmount,
      'restaurant_name': restaurantName,
      'created_at': createdAt.toIso8601String(),
      if (tin != null) 'tin': tin,
      'already_redeemed': alreadyRedeemed,
      if (totalPaid != null) 'total_paid': totalPaid,
      if (cashbackEarned != null) 'cashback_earned': cashbackEarned,
      if (newWalletBalance != null) 'new_wallet_balance': newWalletBalance,
    };
  }

  @override
  List<Object?> get props => [
    receiptId,
    receiptNumber,
    totalAmount,
    restaurantName,
    createdAt,
    tin,
    alreadyRedeemed,
    totalPaid,
    cashbackEarned,
    newWalletBalance,
  ];
}
