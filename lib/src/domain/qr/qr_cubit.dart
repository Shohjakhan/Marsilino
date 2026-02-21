import 'package:flutter_bloc/flutter_bloc.dart';
import '../cashback/cashback_cubit.dart';
import 'qr_state.dart';

/// Cubit managing QR code scanning, receipt fetching, and cashback redemption.
class QrCubit extends Cubit<QrState> {
  final CashbackCubit _cashbackCubit;

  QrCubit({required CashbackCubit cashbackCubit})
    : _cashbackCubit = cashbackCubit,
      super(const QrState());

  /// Called when a QR code is scanned. Triggers receipt fetching.
  Future<void> onQrScanned(String qrData) async {
    emit(state.copyWith(isScanning: false, error: null, redeemed: false));
    await fetchReceipt(qrData);
  }

  /// Fetch and parse receipt data from the Soliq API.
  Future<void> fetchReceipt(String qrData) async {
    emit(state.copyWith(isLoadingReceipt: true, error: null));

    try {
      // TODO: Replace with real Soliq API call
      // final response = await SoliqApiService.fetchReceipt(qrData);
      await Future.delayed(const Duration(seconds: 1));

      // Mock receipt data
      final receipt = ReceiptModel(
        totalAmount: 250000,
        restaurantName: 'Central Plov Center',
        receiptNumber: 'FN-${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
      );

      // Calculate cashback (mock 10% for now)
      final cashback = calculateCashback(receipt.totalAmount, 10);

      emit(
        state.copyWith(
          isLoadingReceipt: false,
          receipt: receipt,
          calculatedCashback: cashback,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingReceipt: false,
          error: 'Failed to fetch receipt: $e',
        ),
      );
    }
  }

  /// Calculate cashback amount from total paid and percentage.
  double calculateCashback(double totalPaid, double percentage) {
    return totalPaid * percentage / 100;
  }

  /// Redeem the calculated cashback into the wallet.
  Future<void> redeemCashback() async {
    if (state.calculatedCashback <= 0 || state.receipt == null) {
      emit(state.copyWith(error: 'No cashback to redeem'));
      return;
    }

    try {
      _cashbackCubit.addCashback(state.calculatedCashback);
      emit(state.copyWith(redeemed: true, error: null));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to redeem cashback: $e'));
    }
  }

  /// Reset the QR state to initial.
  void reset() {
    emit(const QrState());
  }
}
