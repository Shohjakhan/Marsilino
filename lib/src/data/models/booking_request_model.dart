import 'package:intl/intl.dart';
import '../../utils/validation/booking_validator.dart';

/// Request model for creating a booking.
class BookingRequest {
  final String restaurant;
  final String customerPhoneNumber;
  final int numberOfPeople;
  final String date; // ISO format: "YYYY-MM-DD"
  final String time; // 24-hour format: "HH:MM"
  final String? comment;

  const BookingRequest({
    required this.restaurant,
    required this.customerPhoneNumber,
    required this.numberOfPeople,
    required this.date,
    required this.time,
    this.comment,
  });

  /// Create from BookingData validation model.
  factory BookingRequest.fromBookingData({
    required String restaurantId,
    required String phoneNumber,
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
      restaurant: restaurantId,
      customerPhoneNumber: phoneNumber,
      numberOfPeople: bookingData.people,
      date: dateStr,
      time: timeStr,
      comment: bookingData.comments,
    );
  }

  /// Convert to JSON for API request.
  Map<String, dynamic> toJson() {
    return {
      'restaurant': restaurant,
      'customer_phone_number': customerPhoneNumber,
      'number_of_people': numberOfPeople,
      'date': date,
      'time': time,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
    };
  }

  @override
  String toString() {
    return 'BookingRequest(restaurant: $restaurant, customerPhoneNumber: $customerPhoneNumber, numberOfPeople: $numberOfPeople, date: $date, time: $time, comment: $comment)';
  }
}
