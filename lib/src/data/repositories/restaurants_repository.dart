import 'package:dio/dio.dart';
import '../api_client.dart';
import '../models/restaurant.dart';

/// Result for restaurants list.
class RestaurantsListResult {
  final bool success;
  final List<Restaurant> restaurants;
  final String? error;

  const RestaurantsListResult({
    required this.success,
    this.restaurants = const [],
    this.error,
  });
}

/// Result for single restaurant detail.
class RestaurantDetailResult {
  final bool success;
  final Restaurant? restaurant;
  final String? error;

  const RestaurantDetailResult({
    required this.success,
    this.restaurant,
    this.error,
  });
}

/// Repository for restaurant operations.
class RestaurantsRepository {
  final ApiClient _client;

  RestaurantsRepository({ApiClient? client})
    : _client = client ?? ApiClient.instance;

  /// Get list of all restaurants.
  Future<RestaurantsListResult> getRestaurants() async {
    try {
      final response = await _client.get('/restaurants/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        final restaurants = data
            .map((json) => Restaurant.fromJson(json as Map<String, dynamic>))
            .toList();

        return RestaurantsListResult(success: true, restaurants: restaurants);
      }

      return RestaurantsListResult(
        success: false,
        error: 'Failed to load restaurants',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return RestaurantsListResult(
        success: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get nearby restaurants based on location.
  Future<RestaurantsListResult> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double? radiusKm,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'nearby': 'true',
        'lat': latitude.toString(),
        'lng': longitude.toString(),
      };
      if (radiusKm != null) {
        queryParams['radius'] = radiusKm.toString();
      }

      final response = await _client.get(
        '/restaurants/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        final restaurants = data
            .map((json) => Restaurant.fromJson(json as Map<String, dynamic>))
            .toList();

        return RestaurantsListResult(success: true, restaurants: restaurants);
      }

      return RestaurantsListResult(
        success: false,
        error: 'Failed to load nearby restaurants',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return RestaurantsListResult(
        success: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get restaurant detail by ID.
  Future<RestaurantDetailResult> getRestaurantDetail(int id) async {
    try {
      final response = await _client.get('/restaurants/$id/');

      if (response.statusCode == 200) {
        final restaurant = Restaurant.fromJson(
          response.data as Map<String, dynamic>,
        );

        return RestaurantDetailResult(success: true, restaurant: restaurant);
      }

      return RestaurantDetailResult(
        success: false,
        error: 'Failed to load restaurant details',
      );
    } on DioException catch (e) {
      return _handleDetailDioError(e);
    } catch (e) {
      return RestaurantDetailResult(
        success: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  RestaurantsListResult _handleDioError(DioException e) {
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
        final statusCode = e.response?.statusCode;
        errorMessage = 'Server error ($statusCode)';
        break;
      default:
        errorMessage = 'Network error. Please try again.';
    }

    return RestaurantsListResult(success: false, error: errorMessage);
  }

  RestaurantDetailResult _handleDetailDioError(DioException e) {
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
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          errorMessage = 'Restaurant not found.';
        } else {
          errorMessage = 'Server error ($statusCode)';
        }
        break;
      default:
        errorMessage = 'Network error. Please try again.';
    }

    return RestaurantDetailResult(success: false, error: errorMessage);
  }

  /// Like a restaurant.
  Future<LikeResult> likeRestaurant(int restaurantId) async {
    try {
      final response = await _client.post(
        '/me/liked-restaurants/$restaurantId/add/',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const LikeResult(success: true);
      }

      return LikeResult(
        success: false,
        error: response.data?['error'] ?? 'Failed to like restaurant',
      );
    } on DioException catch (e) {
      return _handleLikeDioError(e);
    } catch (e) {
      return LikeResult(
        success: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Unlike a restaurant.
  Future<LikeResult> unlikeRestaurant(int restaurantId) async {
    try {
      final response = await _client.post(
        '/me/liked-restaurants/$restaurantId/remove/',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const LikeResult(success: true);
      }

      return LikeResult(
        success: false,
        error: response.data?['error'] ?? 'Failed to unlike restaurant',
      );
    } on DioException catch (e) {
      return _handleLikeDioError(e);
    } catch (e) {
      return LikeResult(
        success: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get list of liked restaurant IDs.
  Future<LikedIdsResult> getLikedRestaurantIds() async {
    try {
      final response = await _client.get('/me/liked-restaurants/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        final ids = data
            .map((item) => item['id'] as int? ?? item['restaurant'] as int?)
            .whereType<int>()
            .toList();
        return LikedIdsResult(success: true, ids: ids);
      }

      return const LikedIdsResult(
        success: false,
        error: 'Failed to load liked restaurants',
      );
    } on DioException catch (e) {
      return LikedIdsResult(success: false, error: _getLikeErrorMessage(e));
    } catch (e) {
      return LikedIdsResult(
        success: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Get list of liked restaurants with full details.
  Future<RestaurantsListResult> getLikedRestaurants() async {
    try {
      final response = await _client.get('/me/liked-restaurants/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        final restaurants = data
            .map((json) => Restaurant.fromJson(json as Map<String, dynamic>))
            .toList();

        return RestaurantsListResult(success: true, restaurants: restaurants);
      }

      return const RestaurantsListResult(
        success: false,
        error: 'Failed to load liked restaurants',
      );
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return RestaurantsListResult(
        success: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  LikeResult _handleLikeDioError(DioException e) {
    return LikeResult(success: false, error: _getLikeErrorMessage(e));
  }

  String _getLikeErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to server. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return 'Please login to like restaurants.';
        }
        return e.response?.data?['error'] ?? 'Failed ($statusCode)';
      default:
        return 'Network error. Please try again.';
    }
  }
}

/// Result for like/unlike operations.
class LikeResult {
  final bool success;
  final String? error;

  const LikeResult({required this.success, this.error});
}

/// Result for getting liked restaurant IDs.
class LikedIdsResult {
  final bool success;
  final List<int> ids;
  final String? error;

  const LikedIdsResult({
    required this.success,
    this.ids = const [],
    this.error,
  });
}
