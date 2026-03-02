import 'package:dio/dio.dart';
import '../api_client.dart';
import '../models/restaurant.dart';
import '../models/tag_model.dart';

/// Result for restaurants list (supports pagination).
class RestaurantsListResult {
  final bool success;
  final List<Restaurant> restaurants;
  final String? error;
  final int total;
  final int page;
  final int pages;

  const RestaurantsListResult({
    required this.success,
    this.restaurants = const [],
    this.error,
    this.total = 0,
    this.page = 1,
    this.pages = 1,
  });

  bool get hasNextPage => page < pages;
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

  /// Enable mock data for product mockups.
  static const bool kEnableMockData = false;

  List<Restaurant> _getMockRestaurants() {
    return [
      const Restaurant(
        id: 'mock_1',
        name: 'Rayhon National Meals',
        description:
            'Authentic Uzbek cuisine in the heart of Tashkent. Famous for our Plov and Samsa.',
        locationText: 'Amir Temur Avenue 15, Tashkent',
        workingHours: '09:00 - 23:00',
        contactInformation: '+998 71 200 00 01',
        hashtags: 'Uzbek, Plov, Family, Halal',
        cashbackPercentage: 15,
        latitude: 41.3111,
        longitude: 69.2406,
        logo: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        galleryImages: [
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
          'https://images.unsplash.com/photo-1621841957884-1210ee19d6a3',
        ],
        bookingAvailable: true,
        maxPeople: 20,
        availableTimes: ['12:00', '13:00', '18:00', '19:00', '20:00'],
      ),
      const Restaurant(
        id: 'mock_2',
        name: 'Basilic Mediterranean',
        description:
            'Fine dining experience with Italian and French dishes. Perfect for dates.',
        locationText: 'Shota Rustaveli 22, Tashkent',
        workingHours: '11:00 - 00:00',
        contactInformation: '+998 90 123 45 67',
        hashtags: 'Italian, French, Date, Wine',
        latitude: 41.2995,
        longitude: 69.2401,
        logo: 'https://images.unsplash.com/photo-1514362545857-3bc16549766b',
        galleryImages: [
          'https://images.unsplash.com/photo-1514362545857-3bc16549766b',
        ],
        bookingAvailable: true,
        maxPeople: 4,
        availableTimes: ['19:00', '20:00', '21:00'],
      ),
      const Restaurant(
        id: 'mock_3',
        name: 'SATO Fine Dining',
        description: 'Luxury panoramic restaurant with a view of the city.',
        locationText: 'Tashkent City Park, Tashkent',
        workingHours: '12:00 - 02:00',
        contactInformation: '+998 78 555 55 55',
        hashtags: 'Luxury, View, Steak, Cocktails',
        latitude: 41.3140,
        longitude: 69.2480,
        logo: 'https://images.unsplash.com/photo-1552566626-52f8b828add9',
        galleryImages: [
          'https://images.unsplash.com/photo-1552566626-52f8b828add9',
        ],
        bookingAvailable: false,
      ),
      const Restaurant(
        id: 'mock_4',
        name: 'Gulistan Oasis',
        description: 'The best kebab in Gulistan. Outdoor seating available.',
        locationText: 'Saykhun Street 5, Gulistan',
        workingHours: '10:00 - 22:00',
        contactInformation: '+998 67 225 10 10',
        hashtags: 'Kebab, Outdoor, Gulistan, Halal',
        latitude: 40.4851,
        longitude: 68.7845,
        logo: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0',
        galleryImages: [
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0',
        ],
        bookingAvailable: true,
        maxPeople: 50,
        cashbackPercentage: 20,
      ),
      const Restaurant(
        id: 'mock_5',
        name: 'Boyovut Grill',
        description: 'Fast food and grill. Burgers, hot dogs, and more.',
        locationText: 'Boyovut Center, Gulistan',
        workingHours: '24/7',
        contactInformation: '+998 99 999 99 99',
        hashtags: 'Fast Food, Burger, Cheap',
        latitude: 40.4900,
        longitude: 68.7900,
        logo: 'https://images.unsplash.com/photo-1561758033-d89a9ad46330',
        galleryImages: [
          'https://images.unsplash.com/photo-1561758033-d89a9ad46330',
        ],
        bookingAvailable: true,
        maxPeople: 10,
      ),
    ];
  }

  /// Get list of available filter tags.
  /// Returns structured tags from `GET /v1/tags`.
  List<RestaurantTag> _cachedTagObjects = [];

  Future<List<String>> getFilterTags() async {
    if (kEnableMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        'Family',
        'Bars',
        'Korean',
        'Halal',
        'Italian',
        'Fast Food',
        'Vegetarian',
        'Seafood',
        'Desserts',
        'Coffee',
        'Steak',
        'Pizza',
      ];
    }

    try {
      final response = await _client.get('v1/tags');
      if (response.statusCode == 200) {
        final body = response.data;
        List<dynamic> tagList;

        // Unwrap {success, data} response format
        if (body is Map<String, dynamic> &&
            body['success'] == true &&
            body['data'] is List) {
          tagList = body['data'] as List<dynamic>;
        } else if (body is List) {
          tagList = body;
        } else {
          return [];
        }

        _cachedTagObjects = tagList
            .whereType<Map<String, dynamic>>()
            .map((t) => RestaurantTag.fromJson(t))
            .toList();

        return _cachedTagObjects.map((t) => t.name).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get the cached structured tag objects.
  List<RestaurantTag> get cachedTagObjects => _cachedTagObjects;

  /// Get list of all restaurants (paginated).
  /// Uses `GET /v1/restaurants` with `{success, data, total, page, pages}` wrapper.
  Future<RestaurantsListResult> getRestaurants({
    int page = 1,
    int limit = 20,
  }) async {
    if (kEnableMockData) {
      return RestaurantsListResult(
        success: true,
        restaurants: _getMockRestaurants(),
      );
    }

    try {
      final response = await _client.get(
        'v1/restaurants',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map<String, dynamic> && body['success'] == true) {
          final restaurants = _parseRestaurantsFromList(body['data']);
          return RestaurantsListResult(
            success: true,
            restaurants: restaurants,
            total: body['total'] as int? ?? restaurants.length,
            page: body['page'] as int? ?? page,
            pages: body['pages'] as int? ?? 1,
          );
        }
        // Fallback: raw list
        final restaurants = _parseRestaurantsResponse(body);
        if (restaurants != null) {
          return RestaurantsListResult(success: true, restaurants: restaurants);
        }
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
  /// Uses `GET /v1/restaurants` with query params.
  Future<RestaurantsListResult> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double? radiusKm,
  }) async {
    if (kEnableMockData) {
      return RestaurantsListResult(
        success: true,
        restaurants: _getMockRestaurants(),
      );
    }

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
        'v1/restaurants',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final restaurants = _parseRestaurantsResponse(response.data);
        if (restaurants != null) {
          return RestaurantsListResult(success: true, restaurants: restaurants);
        }
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
  /// Uses `GET /v1/restaurants/$id`.
  Future<RestaurantDetailResult> getRestaurantDetail(String id) async {
    if (kEnableMockData && id.startsWith('mock_')) {
      final mock = _getMockRestaurants().firstWhere(
        (r) => r.id == id,
        orElse: () => throw Exception('Mock not found'),
      );
      return RestaurantDetailResult(success: true, restaurant: mock);
    }

    try {
      final response = await _client.get('v1/restaurants/$id');

      if (response.statusCode == 200) {
        final body = response.data;
        Map<String, dynamic> restaurantJson;

        // Unwrap {success, data} format
        if (body is Map<String, dynamic> &&
            body['success'] == true &&
            body['data'] is Map<String, dynamic>) {
          restaurantJson = body['data'] as Map<String, dynamic>;
        } else if (body is Map<String, dynamic>) {
          restaurantJson = body;
        } else {
          return RestaurantDetailResult(
            success: false,
            error: 'Invalid response format',
          );
        }

        final restaurant = Restaurant.fromJson(restaurantJson);
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

  /// Parse a list of restaurants from a `data` field.
  List<Restaurant> _parseRestaurantsFromList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => Restaurant.fromJson(json))
          .toList();
    }
    return [];
  }

  /// Parse restaurants list from either `{success, data: [...]}` or raw `[...]`.
  List<Restaurant>? _parseRestaurantsResponse(dynamic responseData) {
    List<dynamic> list;

    if (responseData is Map<String, dynamic> &&
        responseData['success'] == true &&
        responseData['data'] is List) {
      list = responseData['data'] as List<dynamic>;
    } else if (responseData is List) {
      list = responseData;
    } else {
      return null;
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map((json) => Restaurant.fromJson(json))
        .toList();
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
  Future<LikeResult> likeRestaurant(String restaurantId) async {
    try {
      final response = await _client.post(
        'v1/me/liked-restaurants/$restaurantId/add/',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const LikeResult(success: true);
      }

      String? errorMsg;
      if (response.data is Map && response.data['error'] != null) {
        errorMsg = response.data['error'].toString();
      }
      return LikeResult(
        success: false,
        error: errorMsg ?? 'Failed to like restaurant',
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
  Future<LikeResult> unlikeRestaurant(String restaurantId) async {
    try {
      final response = await _client.post(
        'v1/me/liked-restaurants/$restaurantId/remove/',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const LikeResult(success: true);
      }

      String? errorMsg;
      if (response.data is Map && response.data['error'] != null) {
        errorMsg = response.data['error'].toString();
      }
      return LikeResult(
        success: false,
        error: errorMsg ?? 'Failed to unlike restaurant',
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
  /// Uses GET /v1/me/liked-restaurants/ → {success, data: [...]}
  Future<LikedIdsResult> getLikedRestaurantIds() async {
    try {
      final response = await _client.get('v1/me/liked-restaurants/');

      if (response.statusCode == 200) {
        final body = response.data;
        final list = _extractDataList(body);

        final ids = list
            .map((item) {
              if (item is String) return item;
              if (item is Map) return item['id']?.toString();
              return null;
            })
            .whereType<String>()
            .where((id) => id.isNotEmpty)
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
  /// Uses GET /v1/me/liked-restaurants/ → {success, data: [...]}
  Future<RestaurantsListResult> getLikedRestaurants() async {
    try {
      final response = await _client.get('v1/me/liked-restaurants/');

      if (response.statusCode == 200) {
        final list = _extractDataList(response.data);
        final restaurants = list
            .whereType<Map<String, dynamic>>()
            .map((json) => Restaurant.fromJson(json))
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

  /// Extracts a `List` from a `{success, data: [...]}` API response.
  /// Handles both the wrapped format and a bare List fallback.
  List<dynamic> _extractDataList(dynamic body) {
    if (body is Map<String, dynamic> &&
        body['success'] == true &&
        body['data'] is List) {
      return body['data'] as List<dynamic>;
    }
    if (body is List) return body;
    return [];
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
        final data = e.response?.data;
        if (data is Map && data['error'] != null) {
          return data['error'].toString();
        }
        return 'Failed ($statusCode)';
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
  final List<String> ids;
  final String? error;

  const LikedIdsResult({
    required this.success,
    this.ids = const [],
    this.error,
  });
}
