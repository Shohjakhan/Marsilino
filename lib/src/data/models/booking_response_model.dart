/// Response model for booking creation.
class BookingResponse {
  final String btid; // BTID from API (can be int or UUID string)
  final String user; // User ID (can be int or UUID string)
  final String restaurant;
  final String customerPhoneNumber;
  final int numberOfPeople;
  final String date; // ISO format: "YYYY-MM-DD"
  final String time; // 24-hour format: "HH:MM"
  final String? comment;

  const BookingResponse({
    required this.btid,
    required this.user,
    required this.restaurant,
    required this.customerPhoneNumber,
    required this.numberOfPeople,
    required this.date,
    required this.time,
    this.comment,
  });

  /// Create from JSON response.
  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      btid: json['BTID'].toString(),
      user: json['user'].toString(),
      restaurant: json['restaurant'] as String,
      customerPhoneNumber: json['customer_phone_number'] as String,
      numberOfPeople: _parseInt(json['number_of_people']),
      date: json['date'] as String,
      time: json['time'] as String,
      comment: json['comment'] as String?,
    );
  }

  /// Safely parse int from dynamic (handles both int and String).
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'BTID': btid,
      'user': user,
      'restaurant': restaurant,
      'customer_phone_number': customerPhoneNumber,
      'number_of_people': numberOfPeople,
      'date': date,
      'time': time,
      if (comment != null) 'comment': comment,
    };
  }

  @override
  String toString() {
    return 'BookingResponse(btid: $btid, user: $user, restaurant: $restaurant, numberOfPeople: $numberOfPeople, date: $date, time: $time, comment: $comment)';
  }
}
