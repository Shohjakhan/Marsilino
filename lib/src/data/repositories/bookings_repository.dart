import 'package:dio/dio.dart';
import '../api_client.dart';
import '../models/booking_request_model.dart';
import '../models/booking_response_model.dart';

/// Result for booking creation.
class BookingResult {
  final bool success;
  final BookingResponse? booking;
  final String? error;

  const BookingResult({required this.success, this.booking, this.error});
}

/// Repository for booking operations.
class BookingsRepository {
  final ApiClient _client;

  BookingsRepository({ApiClient? client})
    : _client = client ?? ApiClient.instance;

  /// Create a new booking.
  Future<BookingResult> createBooking(BookingRequest request) async {
    try {
      final response = await _client.post('/bookings/', data: request.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final booking = BookingResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        return BookingResult(success: true, booking: booking);
      }

      // Handle unexpected success status codes
      return BookingResult(
        success: false,
        error: 'Failed to create booking (${response.statusCode})',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return BookingResult(
        success: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  BookingResult _handleDioError(DioException e) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timeout. Please check your internet.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Unable to connect to server. Please try again.';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _getErrorMessageFromResponse(e.response);
        break;
      default:
        errorMessage = 'Network error. Please try again.';
    }

    return BookingResult(success: false, error: errorMessage);
  }

  String _getErrorMessageFromResponse(Response? response) {
    final statusCode = response?.statusCode;

    // Try to extract error message from response body
    String? extractedError;
    final data = response?.data;
    if (data is Map) {
      extractedError =
          data['error']?.toString() ??
          data['message']?.toString() ??
          data['detail']?.toString();
    }

    // Return specific error messages based on status code
    switch (statusCode) {
      case 400:
        return extractedError ??
            'Invalid booking data. Please check your input.';
      case 401:
        return 'Please login to make a booking.';
      case 404:
        return extractedError ?? 'Restaurant not found.';
      case 409:
        return extractedError ??
            'This time slot is no longer available. Please select another time.';
      case 422:
        return extractedError ??
            'Invalid data. Please check your booking details.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return extractedError ?? 'Failed to create booking ($statusCode)';
    }
  }
}
