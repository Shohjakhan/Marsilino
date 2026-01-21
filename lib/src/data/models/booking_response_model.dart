/// Response model for booking creation.
class BookingResponse {
  final String id;
  final String restaurantId;
  final int people;
  final String date; // ISO format: "YYYY-MM-DD"
  final String time; // 24-hour format: "HH:MM"
  final String status;
  final String reference;
  final String? comments;

  const BookingResponse({
    required this.id,
    required this.restaurantId,
    required this.people,
    required this.date,
    required this.time,
    required this.status,
    required this.reference,
    this.comments,
  });

  /// Create from JSON response.
  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      people: json['people'] as int,
      date: json['date'] as String,
      time: json['time'] as String,
      status: json['status'] as String,
      reference: json['reference'] as String,
      comments: json['comments'] as String?,
    );
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'people': people,
      'date': date,
      'time': time,
      'status': status,
      'reference': reference,
      if (comments != null) 'comments': comments,
    };
  }

  @override
  String toString() {
    return 'BookingResponse(id: $id, restaurantId: $restaurantId, people: $people, date: $date, time: $time, status: $status, reference: $reference, comments: $comments)';
  }
}
