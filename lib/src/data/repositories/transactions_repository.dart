import 'package:dio/dio.dart';
import '../api_client.dart';

class Transaction {
  final int id;
  final String restaurantId;
  final String restaurantName;
  final double amount;
  final double discountAmount;
  final double finalAmount;
  final double discountPercent;
  final DateTime date;
  final String status;

  Transaction({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.amount,
    required this.discountAmount,
    required this.finalAmount,
    required this.discountPercent,
    required this.date,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      restaurantId: json['restaurant']?.toString() ?? '',
      // The API might return nested restaurant object or just ID/Name
      // Assuming specific fields for list view based on typical response
      restaurantName:
          json['restaurant_name'] as String? ?? 'Unknown Restaurant',
      amount: (json['sum_before_discount'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['saved_amount'] as num?)?.toDouble() ?? 0,
      finalAmount: (json['sum_after_discount'] as num?)?.toDouble() ?? 0,
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0,
      date: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String? ?? 'completed',
    );
  }
}

class TransactionsListResult {
  final bool success;
  final List<Transaction> transactions;
  final String? error;

  TransactionsListResult({
    required this.success,
    this.transactions = const [],
    this.error,
  });
}

class TransactionResult {
  final bool success;
  final double? discountPercent;
  final double? sumAfterDiscount;
  final double? savedAmount;
  final String? error;
  final String? errorCode;

  TransactionResult({
    required this.success,
    this.discountPercent,
    this.sumAfterDiscount,
    this.savedAmount,
    this.error,
    this.errorCode,
  });

  factory TransactionResult.success(Map<String, dynamic> data) {
    return TransactionResult(
      success: true,
      discountPercent: (data['discount_percent'] as num?)?.toDouble(),
      sumAfterDiscount: (data['sum_after_discount'] as num?)?.toDouble(),
      savedAmount: (data['saved_amount'] as num?)?.toDouble(),
    );
  }

  factory TransactionResult.failure(String message, String? code) {
    return TransactionResult(success: false, error: message, errorCode: code);
  }
}

class TransactionsRepository {
  final ApiClient _client;

  TransactionsRepository({ApiClient? client})
    : _client = client ?? ApiClient.instance;

  Future<TransactionResult> createTransaction({
    required String restaurantId,
    required double sumBeforeDiscount,
    required String cashierCode,
  }) async {
    try {
      // final token = await _tokenStorage.getAccessToken(); // Not needed if ApiClient handles it
      final response = await _client.post(
        '/transactions/',
        data: {
          'restaurant_id': restaurantId,
          'sum_before_discount': sumBeforeDiscount,
          'cashier_code': cashierCode,
        },
        // ApiClient typically handles headers if it manages tokens?
        // RestaurantsRepository doesn't set headers manually.
        // Assuming ApiClient handles Authorization if logged in.
        // But if I want to be safe, I can check ApiClient implementation.
        // However, standard ApiClient usage in existing repos implies auto-auth.
      );

      // Verify response structure
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TransactionResult.success(response.data);
      } else {
        return TransactionResult.failure(
          response.data?['detail'] ?? 'Failed to process transaction',
          response.data?['error_code'],
        );
      }
    } on DioException catch (e) {
      String message = 'Failed to process transaction';
      String? errorCode;

      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        message = data['detail'] ?? message;
        errorCode = data['error_code'];
      }

      return TransactionResult.failure(message, errorCode);
    } catch (e) {
      return TransactionResult.failure(e.toString(), null);
    }
  }

  Future<TransactionsListResult> getTransactions() async {
    try {
      final response = await _client.get('/me/transactions/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        final transactions = data
            .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
            .toList();

        return TransactionsListResult(
          success: true,
          transactions: transactions,
        );
      }

      return TransactionsListResult(
        success: false,
        error: 'Failed to load transactions',
      );
    } on DioException catch (e) {
      String errorMessage = 'Network error. Please try again.';
      if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Server error (${e.response?.statusCode})';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      }
      return TransactionsListResult(success: false, error: errorMessage);
    } catch (e) {
      return TransactionsListResult(
        success: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }
}
