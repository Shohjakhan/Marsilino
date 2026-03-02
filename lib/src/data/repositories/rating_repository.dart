import '../api_client.dart';

/// Result wrapper for rating operations.
class RatingResult {
  final bool success;
  final double? averageRating;
  final int? totalRatings;
  final String? error;

  const RatingResult({
    required this.success,
    this.averageRating,
    this.totalRatings,
    this.error,
  });
}

/// Repository for restaurant rating operations.
///
/// ## Backend API Requirements
///
/// ### Submit Rating
/// ```
/// POST /api/v1/restaurants/{restaurant_id}/rate/
/// Authorization: Bearer <token>
/// Content-Type: application/json
///
/// { "rating": 4 }   // integer 1-5
/// ```
/// Response:
/// ```json
/// { "success": true, "average_rating": 4.2, "total_ratings": 58 }
/// ```
///
/// ### Get Rating
/// Rating is included in the restaurant detail response:
/// ```
/// GET /api/v1/restaurants/{id}/
/// ```
/// Response includes:
/// ```json
/// { "average_rating": 4.2, "total_ratings": 58 }
/// ```
class RatingRepository {
  final ApiClient _client;

  RatingRepository({ApiClient? client})
    : _client = client ?? ApiClient.instance;

  /// Submit a star rating (1-5) for a restaurant.
  Future<RatingResult> submitRating({
    required String restaurantId,
    required int rating,
  }) async {
    try {
      final response = await _client.post(
        'v1/restaurants/$restaurantId/rate/',
        data: {'rating': rating},
      );

      final body = response.data;
      if (body is Map<String, dynamic> && body['success'] == true) {
        return RatingResult(
          success: true,
          averageRating: (body['average_rating'] as num?)?.toDouble(),
          totalRatings: body['total_ratings'] as int?,
        );
      }
      return RatingResult(
        success: false,
        error:
            (body as Map?)?['message']?.toString() ?? 'Failed to submit rating',
      );
    } catch (e) {
      return RatingResult(success: false, error: e.toString());
    }
  }
}
