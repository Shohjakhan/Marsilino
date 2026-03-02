import 'package:dio/dio.dart';
import '../api_client.dart';
import '../models/receipt_model.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';

/// Result wrapper for wallet operations.
class WalletResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? errorCode;

  const WalletResult({
    required this.success,
    this.data,
    this.error,
    this.errorCode,
  });
}

/// Repository for wallet, cashback, and receipt verification operations.
///
/// Endpoints:
/// - `GET /v1/wallet` — Get wallet info
/// - `GET /v1/wallet/transactions` — Get transaction history (paginated)
/// - `POST /v1/wallet/add` — Add cashback
/// - `POST /v1/wallet/transfer` — Transfer to card
/// - `POST /v1/receipt/verify` — Verify Soliq receipt
class WalletRepository {
  final ApiClient _client;

  WalletRepository({ApiClient? client})
    : _client = client ?? ApiClient.instance;

  /// Get current wallet information.
  Future<WalletResult<WalletInfo>> getWallet() async {
    try {
      final response = await _client.get('v1/wallet');

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          final wallet = WalletInfo.fromJson(
            body['data'] as Map<String, dynamic>,
          );
          return WalletResult(success: true, data: wallet);
        }
        return WalletResult(
          success: false,
          error: body['message'] as String? ?? 'Failed to load wallet',
        );
      }

      return WalletResult(
        success: false,
        error: 'Failed to load wallet (${response.statusCode})',
      );
    } on DioException catch (e) {
      return WalletResult(success: false, error: _getDioErrorMessage(e));
    } catch (e) {
      return WalletResult(success: false, error: 'Unexpected error: $e');
    }
  }

  /// Get wallet transaction history (paginated).
  Future<WalletResult<TransactionsPage>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        'v1/wallet/transactions',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        if (body['success'] == true) {
          final txPage = TransactionsPage.fromJson(body);
          return WalletResult(success: true, data: txPage);
        }
        return WalletResult(
          success: false,
          error: body['message'] as String? ?? 'Failed to load transactions',
          errorCode: body['error_code'] as String?,
        );
      }

      return WalletResult(
        success: false,
        error: 'Failed to load transactions (${response.statusCode})',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return WalletResult(success: false, error: 'Unexpected error: $e');
    }
  }

  /// Add cashback to wallet after receipt verification.
  Future<WalletResult<CashbackAddResult>> addCashback({
    required String receiptId,
    required double totalPaid,
    required double cashbackPercentage,
    required double cashbackAmount,
    required String restaurantId,
  }) async {
    try {
      final response = await _client.post(
        'v1/wallet/add',
        data: {
          'receipt_id': receiptId,
          'total_paid': totalPaid,
          'cashback_percentage': cashbackPercentage,
          'cashback_amount': cashbackAmount,
          'restaurant_id': restaurantId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          final result = CashbackAddResult.fromJson(
            body['data'] as Map<String, dynamic>,
          );
          return WalletResult(success: true, data: result);
        }
        return WalletResult(
          success: false,
          error: body['message'] as String? ?? 'Failed to add cashback',
          errorCode: body['error_code'] as String?,
        );
      }

      return WalletResult(
        success: false,
        error: 'Failed to add cashback (${response.statusCode})',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return WalletResult(success: false, error: 'Unexpected error: $e');
    }
  }

  /// Transfer wallet balance to a bank card.
  Future<WalletResult<TransferResult>> transferToCard({
    required double amount,
    required String cardLastFour,
  }) async {
    try {
      final response = await _client.post(
        'v1/wallet/transfer',
        data: {'amount': amount, 'card_last_four': cardLastFour},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          final result = TransferResult.fromJson(
            body['data'] as Map<String, dynamic>,
          );
          return WalletResult(success: true, data: result);
        }
        return WalletResult(
          success: false,
          error: body['message'] as String? ?? 'Transfer failed',
          errorCode: body['error'] as String?,
        );
      }

      return WalletResult(
        success: false,
        error: 'Transfer failed (${response.statusCode})',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return WalletResult(success: false, error: 'Unexpected error: $e');
    }
  }

  /// Verify a Soliq receipt via QR code.
  Future<WalletResult<ReceiptModel>> verifyReceipt({
    required String qrCodeUrl,
    int? restaurantId,
  }) async {
    try {
      final data = <String, dynamic>{'qr_code_url': qrCodeUrl};
      if (restaurantId != null) {
        data['restaurant_id'] = restaurantId;
      }

      final response = await _client.post('v1/receipt/verify/', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          final receipt = ReceiptModel.fromJson(
            body['data'] as Map<String, dynamic>,
          );
          return WalletResult(success: true, data: receipt);
        }
        return WalletResult(
          success: false,
          error: body['message'] as String? ?? 'Receipt verification failed',
          errorCode: body['error'] as String?,
        );
      }

      return WalletResult(
        success: false,
        error: 'Receipt verification failed (${response.statusCode})',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return WalletResult(success: false, error: 'Unexpected error: $e');
    }
  }

  WalletResult<T> _handleDioError<T>(DioException e) {
    final errorMessage = _getDioErrorMessage(e);
    String? errorCode;

    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      errorCode = data['error_code']?.toString();
    }

    return WalletResult(
      success: false,
      error: errorMessage,
      errorCode: errorCode,
    );
  }

  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to server. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        if (data is Map) {
          return data['message']?.toString() ??
              data['error']?.toString() ??
              'Server error ($statusCode)';
        }
        return 'Server error ($statusCode)';
      default:
        return 'Network error. Please try again.';
    }
  }
}
