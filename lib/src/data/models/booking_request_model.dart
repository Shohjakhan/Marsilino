import 'package:intl/intl.dart';
import '../../utils/validation/booking_validator.dart';

/// Request model for creating a booking.
class BookingRequest {
  final String restaurantId;
  final int people;
  final String date; // ISO format: "YYYY-MM-DD"
  final String time; // 24-hour format: "HH:MM"
  final String? comments;

  const BookingRequest({
    required this.restaurantId,
    required this.people,
    required this.date,
    required this.time,
    this.comments,
  });

  /// Create from BookingData validation model.
  factory BookingRequest.fromBookingData({
    required String restaurantId,
    required BookingData bookingData,
  }) {
    // Format date to ISO format
    final dateStr = bookingData.date != null
        ? DateFormat('yyyy-MM-dd').format(bookingData.date!)
        : '';

    // Format time to 24-hour format
    final timeStr = bookingData.time != null
        ? '${bookingData.time!.hour.toString().padLeft(2, '0')}:${bookingData.time!.minute.toString().padLeft(2, '0')}'
        : '';

    return BookingRequest(
      restaurantId: restaurantId,
      people: bookingData.people,
      date: dateStr,
      time: timeStr,
      comments: bookingData.comments,
    );
  }

  /// Convert to JSON for API request.
  Map<String, dynamic> toJson() {
    return {
      'restaurant_id': restaurantId,
      'people': people,
      'date': date,
      'time': time,
      if (comments != null && comments!.isNotEmpty) 'comments': comments,
    };
  }

  @override
  String toString() {
    return 'BookingRequest(restaurantId: $restaurantId, people: $people, date: $date, time: $time, comments: $comments)';
  }
}
