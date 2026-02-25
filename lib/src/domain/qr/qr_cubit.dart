import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/wallet_repository.dart';
import '../cashback/cashback_cubit.dart';
import 'qr_state.dart';

/// Cubit managing QR code scanning, receipt fetching, and cashback redemption.
///
/// When opened from a restaurant page, [restaurantId], [restaurantName],
/// and [cashbackPercent] are provided — the cubit uses that cashback rate.
/// When opened from the navbar (standalone), no restaurant context is passed
/// and the cashback rate will be looked up from the receipt/server.
class QrCubit extends Cubit<QrState> {
  final CashbackCubit _cashbackCubit;
  final WalletRepository _walletRepository;
  final String? restaurantId;
  final String? restaurantName;
  final int? cashbackPercent;

  QrCubit({
    required CashbackCubit cashbackCubit,
    WalletRepository? walletRepository,
    this.restaurantId,
    this.restaurantName,
    this.cashbackPercent,
  }) : _cashbackCubit = cashbackCubit,
       _walletRepository = walletRepository ?? WalletRepository(),
       super(const QrState());

  /// Whether this cubit was opened with restaurant context.
  bool get hasRestaurantContext => restaurantId != null;

  /// Called when a QR code is scanned. Triggers receipt fetching.
  Future<void> onQrScanned(String qrData) async {
    emit(state.copyWith(isScanning: false, error: null, redeemed: false));
    await fetchReceipt(qrData);
  }

  /// Fetch and verify receipt data from the backend via `POST /v1/receipt/verify`.
  Future<void> fetchReceipt(String qrData) async {
    emit(state.copyWith(isLoadingReceipt: true, error: null));

    try {
      final result = await _walletRepository.verifyReceipt(
        qrCodeUrl: qrData,
        restaurantId: restaurantId != null ? int.tryParse(restaurantId!) : null,
      );

      if (result.success && result.data != null) {
        final receipt = result.data!;

        // Use cashback from server response, fallback to restaurant context
        final cashback =
            receipt.cashbackEarned ??
            calculateCashback(
              receipt.totalAmount,
              (cashbackPercent ?? 0).toDouble(),
            );

        emit(
          state.copyWith(
            isLoadingReceipt: false,
            receipt: receipt,
            calculatedCashback: cashback,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoadingReceipt: false,
            error: result.error ?? 'Failed to verify receipt',
          ),
        );
      }
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

  /// Redeem the calculated cashback into the wallet via `POST /v1/wallet/add`.
  Future<void> redeemCashback() async {
    if (state.calculatedCashback <= 0 || state.receipt == null) {
      emit(state.copyWith(error: 'No cashback to redeem'));
      return;
    }

    try {
      final receipt = state.receipt!;
      final result = await _walletRepository.addCashback(
        receiptId: receipt.receiptId ?? receipt.receiptNumber,
        totalPaid: receipt.totalPaid ?? receipt.totalAmount,
        cashbackPercentage: (cashbackPercent ?? 0).toDouble(),
        cashbackAmount: state.calculatedCashback,
        restaurantId: restaurantId ?? '',
      );

      if (result.success && result.data != null) {
        // Update the wallet balance in the cashback cubit
        _cashbackCubit.updateBalance(result.data!.newBalance);
        emit(state.copyWith(redeemed: true, error: null));
      } else {
        emit(
          state.copyWith(error: result.error ?? 'Failed to redeem cashback'),
        );
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to redeem cashback: $e'));
    }
  }

  /// Reset the QR state to initial.
  void reset() {
    emit(const QrState());
  }
}
