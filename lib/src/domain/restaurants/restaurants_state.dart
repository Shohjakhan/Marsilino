import '../../data/models/restaurant.dart';

/// Restaurants state.
sealed class RestaurantsState {}

/// Initial state - no data loaded yet.
class RestaurantsInitial extends RestaurantsState {}

/// Loading state.
class RestaurantsLoading extends RestaurantsState {
  /// If true, showing cached data while refreshing.
  final List<Restaurant> cachedRestaurants;
  final bool isRefreshing;

  RestaurantsLoading({
    this.cachedRestaurants = const [],
    this.isRefreshing = false,
  });
}

/// Restaurants loaded successfully.
class RestaurantsLoaded extends RestaurantsState {
  final List<Restaurant> restaurants;
  final List<Restaurant> filteredRestaurants;
  final String searchQuery;
  final Set<String> activeFilters;
  final bool hasMore;
  final List<String> availableTags;
  final String? currentLocationName;

  RestaurantsLoaded({
    required this.restaurants,
    required this.filteredRestaurants,
    this.searchQuery = '',
    this.activeFilters = const {},
    this.hasMore = false,
    List<String>? availableTags,
    this.currentLocationName,
  }) : availableTags = availableTags ?? const [];

  RestaurantsLoaded copyWith({
    List<Restaurant>? restaurants,
    List<Restaurant>? filteredRestaurants,
    String? searchQuery,
    Set<String>? activeFilters,
    bool? hasMore,
    List<String>? availableTags,
    String? currentLocationName,
  }) {
    return RestaurantsLoaded(
      restaurants: restaurants ?? this.restaurants,
      filteredRestaurants: filteredRestaurants ?? this.filteredRestaurants,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilters: activeFilters ?? this.activeFilters,
      hasMore: hasMore ?? this.hasMore,
      availableTags: availableTags ?? this.availableTags,
      currentLocationName: currentLocationName ?? this.currentLocationName,
    );
  }
}

/// Error state with retry capability.
class RestaurantsError extends RestaurantsState {
  final String message;
  final List<Restaurant> cachedRestaurants;

  RestaurantsError({required this.message, this.cachedRestaurants = const []});
}
