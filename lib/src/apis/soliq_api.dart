import 'package:dio/dio.dart';
import '../data/api_client.dart';
import '../data/models/receipt_model.dart';

/// API service for fetching fiscal receipt data via the backend proxy.
///
/// ## Overview
/// This service sends scanned QR code URLs to the backend, which proxies
/// the request to the Soliq OFD API and returns parsed receipt data.
///
/// ## Backend Endpoint
/// ```
/// POST /api/v1/receipt/verify
/// Content-Type: application/json
///
/// Request:
///   { "qr_code_url": "https://ofd.soliq.uz/check?t=...&r=...&c=...&s=..." }
///
/// Response:
///   {
///     "success": true,
///     "data": {
///       "receipt_id": "123456789",
///       "receipt_number": "987",
///       "total_amount": 100000.0,
///       "restaurant_name": "Burger King",
///       "created_at": "2026-02-24T18:00:00Z",
///       "tin": "123456789",
///       "already_redeemed": false,
///       "total_paid": 100000.0,
///       "cashback_earned": 5000.0,
///       "new_wallet_balance": 20000.0
///     }
///   }
/// ```
class SoliqApi {
  final ApiClient _client;

  SoliqApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  /// Fetch receipt details from a scanned QR code via backend proxy.
  ///
  /// [qrCode] — The raw string content extracted from the QR code scan.
  /// [restaurantId] — Optional restaurant ID for validation.
  ///
  /// Returns a [ReceiptModel] with parsed receipt data.
  ///
  /// Throws [SoliqApiException] on failure with a user-friendly message.
  Future<ReceiptModel> fetchReceipt({
    required String qrCode,
    int? restaurantId,
  }) async {
    if (qrCode.isEmpty) {
      throw const SoliqApiException(message: 'QR code cannot be empty.');
    }

    try {
      final data = <String, dynamic>{'qr_code_url': qrCode};
      if (restaurantId != null) {
        data['restaurant_id'] = restaurantId;
      }

      final response = await _client.post('/v1/receipt/verify/', data: data);

      final responseData = response.data;

      if (responseData is! Map<String, dynamic>) {
        throw const SoliqApiException(
          message: 'Invalid response format from server.',
        );
      }

      final success = responseData['success'] as bool? ?? false;
      if (!success) {
        final errorMsg =
            responseData['message'] as String? ??
            responseData['error'] as String? ??
            'Receipt verification failed.';
        throw SoliqApiException(message: errorMsg);
      }

      final receiptData = responseData['data'] as Map<String, dynamic>?;
      if (receiptData == null) {
        throw const SoliqApiException(
          message: 'No receipt data returned from server.',
        );
      }

      return ReceiptModel.fromJson(receiptData);
    } on DioException catch (e) {
      throw SoliqApiException.fromDioException(e);
    } on SoliqApiException {
      rethrow;
    } catch (e) {
      throw SoliqApiException(message: 'Unexpected error: ${e.toString()}');
    }
  }
}

/// Exception thrown by [SoliqApi] operations.
class SoliqApiException implements Exception {
  final String message;

  const SoliqApiException({required this.message});

  /// Create from a [DioException] with user-friendly messages.
  factory SoliqApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const SoliqApiException(
          message: 'Connection timed out. Please check your internet.',
        );
      case DioExceptionType.connectionError:
        return const SoliqApiException(
          message: 'Unable to connect to server. Please try again.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return const SoliqApiException(
            message: 'Receipt not found. Please check the QR code.',
          );
        }
        if (statusCode == 429) {
          return const SoliqApiException(
            message: 'Too many requests. Please wait and try again.',
          );
        }
        if (statusCode != null && statusCode >= 500) {
          return const SoliqApiException(
            message: 'Server error. Please try again later.',
          );
        }
        // Try to extract error from response body
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          final msg = data['message'] as String? ?? data['error'] as String?;
          if (msg != null) return SoliqApiException(message: msg);
        }
        return SoliqApiException(
          message: 'Request failed (status $statusCode).',
        );
      default:
        return SoliqApiException(
          message: e.message ?? 'An unknown network error occurred.',
        );
    }
  }

  @override
  String toString() => 'SoliqApiException: $message';
}
