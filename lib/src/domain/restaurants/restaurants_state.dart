import 'package:equatable/equatable.dart';
import '../../data/models/restaurant.dart';

/// Restaurants state.
sealed class RestaurantsState extends Equatable {
  const RestaurantsState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no data loaded yet.
class RestaurantsInitial extends RestaurantsState {
  const RestaurantsInitial();
}

/// Loading state.
class RestaurantsLoading extends RestaurantsState {
  final List<Restaurant> cachedRestaurants;
  final bool isRefreshing;

  const RestaurantsLoading({
    this.cachedRestaurants = const [],
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [cachedRestaurants, isRefreshing];
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

  const RestaurantsLoaded({
    required this.restaurants,
    required this.filteredRestaurants,
    this.searchQuery = '',
    this.activeFilters = const {},
    this.hasMore = false,
    this.availableTags = const [],
    this.currentLocationName,
  });

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

  @override
  List<Object?> get props => [
    restaurants,
    filteredRestaurants,
    searchQuery,
    activeFilters,
    hasMore,
    availableTags,
    currentLocationName,
  ];
}

/// Error state with retry capability.
class RestaurantsError extends RestaurantsState {
  final String message;
  final List<Restaurant> cachedRestaurants;

  const RestaurantsError({
    required this.message,
    this.cachedRestaurants = const [],
  });

  @override
  List<Object?> get props => [message, cachedRestaurants];
}
