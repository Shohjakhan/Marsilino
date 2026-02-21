import 'package:equatable/equatable.dart';

/// Parsed receipt data from a QR code scan.
class ReceiptModel extends Equatable {
  /// Total amount paid on the receipt.
  final double totalAmount;

  /// Restaurant name from the receipt.
  final String restaurantName;

  /// Receipt number / fiscal ID.
  final String receiptNumber;

  /// Date of the transaction.
  final DateTime date;

  const ReceiptModel({
    required this.totalAmount,
    required this.restaurantName,
    required this.receiptNumber,
    required this.date,
  });

  @override
  List<Object?> get props => [totalAmount, restaurantName, receiptNumber, date];
}

/// Immutable state for the QR scan feature.
class QrState extends Equatable {
  /// Whether the camera/scanner is actively scanning.
  final bool isScanning;

  /// Whether a receipt is being fetched from the API.
  final bool isLoadingReceipt;

  /// Parsed receipt data, if available.
  final ReceiptModel? receipt;

  /// Calculated cashback amount based on receipt total and percentage.
  final double calculatedCashback;

  /// Error message from the last failed operation, if any.
  final String? error;

  /// Whether cashback was successfully redeemed.
  final bool redeemed;

  const QrState({
    this.isScanning = false,
    this.isLoadingReceipt = false,
    this.receipt,
    this.calculatedCashback = 0,
    this.error,
    this.redeemed = false,
  });

  QrState copyWith({
    bool? isScanning,
    bool? isLoadingReceipt,
    ReceiptModel? receipt,
    double? calculatedCashback,
    String? error,
    bool? redeemed,
  }) {
    return QrState(
      isScanning: isScanning ?? this.isScanning,
      isLoadingReceipt: isLoadingReceipt ?? this.isLoadingReceipt,
      receipt: receipt ?? this.receipt,
      calculatedCashback: calculatedCashback ?? this.calculatedCashback,
      error: error,
      redeemed: redeemed ?? this.redeemed,
    );
  }

  @override
  List<Object?> get props => [
    isScanning,
    isLoadingReceipt,
    receipt,
    calculatedCashback,
    error,
    redeemed,
  ];
}
